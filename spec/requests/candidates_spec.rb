require "rails_helper"

RSpec.describe "Api::V1::Candidates", type: :request do
  let(:team) { create(:team) }
  let(:user) { create(:user) }
  let!(:membership) { create(:team_membership, user: user, team: team, role: "recruiter") }
  let(:job) { create(:job, team: team, creator: user) }
  let!(:stage) { create(:stage, job: job, name: "Applied", position: 0) }

  before { sign_in user }

  describe "GET /api/v1/jobs/:job_id/candidates" do
    let!(:candidate) { create(:candidate, job: job, team: team, stage: stage) }

    it "returns job candidates" do
      get "/api/v1/jobs/#{job.id}/candidates", params: { team_id: team.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/v1/jobs/:job_id/candidates" do
    let(:params) do
      {
        team_id: team.id,
        candidate: {
          first_name: "Jane",
          last_name: "Doe",
          email: "jane@example.com",
          source: "LinkedIn"
        }
      }
    end

    it "creates a candidate in the first stage" do
      post "/api/v1/jobs/#{job.id}/candidates", params: params
      expect(response).to have_http_status(:created)
      candidate = Candidate.last
      expect(candidate.stage).to eq(stage)
      expect(candidate.pipeline_version).to eq(job.pipeline_version)
    end
  end

  describe "PATCH /api/v1/jobs/:job_id/candidates/:id/move_stage" do
    let(:stage2) { create(:stage, job: job, name: "Interview", position: 1) }
    let(:candidate) { create(:candidate, job: job, team: team, stage: stage) }

    it "moves candidate to new stage with correct lock_version" do
      patch "/api/v1/jobs/#{job.id}/candidates/#{candidate.id}/move_stage",
            params: { team_id: team.id, stage_id: stage2.id, lock_version: candidate.lock_version }
      expect(response).to have_http_status(:ok)
      expect(candidate.reload.stage).to eq(stage2)
    end

    it "returns 409 conflict with stale lock_version" do
      patch "/api/v1/jobs/#{job.id}/candidates/#{candidate.id}/move_stage",
            params: { team_id: team.id, stage_id: stage2.id, lock_version: candidate.lock_version + 99 }
      expect(response).to have_http_status(:conflict)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Conflict")
      expect(candidate.reload.stage).to eq(stage)
    end

    it "returns 409 when concurrent update happens" do
      # Simulate concurrent update
      Candidate.find(candidate.id).update!(first_name: "ConcurrentChange")

      patch "/api/v1/jobs/#{job.id}/candidates/#{candidate.id}/move_stage",
            params: { team_id: team.id, stage_id: stage2.id, lock_version: candidate.lock_version }
      expect(response).to have_http_status(:conflict)
    end
  end

  describe "PATCH /api/v1/jobs/:job_id/candidates/batch_move" do
    let(:stage2) { create(:stage, job: job, name: "Interview", position: 1) }
    let!(:candidates) { create_list(:candidate, 3, job: job, team: team, stage: stage) }

    it "queues batch move job for valid candidates" do
      patch "/api/v1/jobs/#{job.id}/candidates/batch_move",
            params: { team_id: team.id, stage_id: stage2.id, candidate_ids: candidates.map(&:id) }
      expect(response).to have_http_status(:accepted)
    end

    it "rejects candidate IDs from other teams" do
      other_team = create(:team)
      other_job = create(:job, team: other_team)
      other_stage = create(:stage, job: other_job)
      other_candidate = create(:candidate, job: other_job, team: other_team, stage: other_stage)

      patch "/api/v1/jobs/#{job.id}/candidates/batch_move",
            params: { team_id: team.id, stage_id: stage2.id, candidate_ids: [other_candidate.id] }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "multi-tenant isolation" do
    let(:other_team) { create(:team) }
    let(:other_job) { create(:job, team: other_team) }
    let(:other_stage) { create(:stage, job: other_job) }
    let!(:other_candidate) { create(:candidate, job: other_job, team: other_team, stage: other_stage) }

    it "cannot access candidates from other teams" do
      get "/api/v1/jobs/#{other_job.id}/candidates", params: { team_id: team.id }
      expect(response).to have_http_status(:not_found)
    end
  end
end
