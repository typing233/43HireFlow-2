require "rails_helper"

RSpec.describe "Api::V1::Stages - Pipeline Versioning", type: :request do
  let(:team) { create(:team) }
  let(:user) { create(:user) }
  let!(:membership) { create(:team_membership, user: user, team: team, role: "admin") }
  let(:job) { create(:job, team: team, creator: user) }
  let!(:stage1) { create(:stage, job: job, name: "Applied", position: 0, pipeline_version: 1) }
  let!(:stage2) { create(:stage, job: job, name: "Interview", position: 1, pipeline_version: 1) }

  before { sign_in user }

  context "with active candidates in pipeline" do
    let!(:candidate) { create(:candidate, job: job, team: team, stage: stage1, pipeline_version: 1) }

    describe "POST /api/v1/jobs/:job_id/stages (add)" do
      it "upgrades pipeline and migrates candidates" do
        post "/api/v1/jobs/#{job.id}/stages",
             params: { team_id: team.id, stage: { name: "Phone Screen", position: 2 } }

        expect(response).to have_http_status(:created)
        expect(job.reload.pipeline_version).to eq(2)
        expect(candidate.reload.pipeline_version).to eq(2)

        json = JSON.parse(response.body)
        stages = json["stages"]
        expect(stages.size).to eq(3)
      end
    end

    describe "PATCH /api/v1/jobs/:job_id/stages/:id (update)" do
      it "upgrades pipeline and returns current version stages" do
        patch "/api/v1/jobs/#{job.id}/stages/#{stage1.id}",
              params: { team_id: team.id, stage: { name: "Application Review" } }

        expect(response).to have_http_status(:ok)
        expect(job.reload.pipeline_version).to eq(2)

        json = JSON.parse(response.body)
        stages = json["stages"]
        expect(stages.map { |s| s["name"] }).to include("Application Review")
        expect(candidate.reload.pipeline_version).to eq(2)
      end
    end

    describe "PATCH /api/v1/jobs/:job_id/stages/reorder" do
      it "upgrades pipeline when reordering with active candidates" do
        patch "/api/v1/jobs/#{job.id}/stages/reorder",
              params: {
                team_id: team.id,
                stages: [
                  { id: stage1.id, position: 1 },
                  { id: stage2.id, position: 0 }
                ]
              }

        expect(response).to have_http_status(:ok)
        expect(job.reload.pipeline_version).to eq(2)
        expect(candidate.reload.pipeline_version).to eq(2)

        json = JSON.parse(response.body)
        stages = json["stages"]
        expect(stages.first["name"]).to eq("Interview")
      end
    end
  end

  context "without candidates" do
    describe "PATCH /api/v1/jobs/:job_id/stages/reorder" do
      it "reorders in place without version upgrade" do
        patch "/api/v1/jobs/#{job.id}/stages/reorder",
              params: {
                team_id: team.id,
                stages: [
                  { id: stage1.id, position: 1 },
                  { id: stage2.id, position: 0 }
                ]
              }

        expect(response).to have_http_status(:ok)
        expect(job.reload.pipeline_version).to eq(1)

        json = JSON.parse(response.body)
        stages = json["stages"]
        expect(stages.first["name"]).to eq("Interview")
      end
    end
  end
end
