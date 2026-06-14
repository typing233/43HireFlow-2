require "rails_helper"

RSpec.describe "Api::V1::Jobs", type: :request do
  let(:team) { create(:team) }
  let(:user) { create(:user) }
  let!(:membership) { create(:team_membership, user: user, team: team, role: "admin") }

  before { sign_in user }

  describe "GET /api/v1/jobs" do
    let!(:job1) { create(:job, team: team, creator: user) }
    let!(:job2) { create(:job, team: team, creator: user) }
    let!(:other_team_job) { create(:job) }

    it "returns only team jobs" do
      get "/api/v1/jobs", params: { team_id: team.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["jobs"].size).to eq(2)
    end

    it "filters by status" do
      job1.publish!
      get "/api/v1/jobs", params: { team_id: team.id, status: "published" }
      json = JSON.parse(response.body)
      expect(json["jobs"].size).to eq(1)
    end
  end

  describe "POST /api/v1/jobs" do
    let(:valid_params) do
      {
        team_id: team.id,
        job: { title: "Software Engineer", department: "Engineering", location: "Remote" }
      }
    end

    it "creates a job with default stages" do
      expect {
        post "/api/v1/jobs", params: valid_params
      }.to change(Job, :count).by(1)

      expect(response).to have_http_status(:created)
      job = Job.last
      expect(job.stages.count).to eq(6)
      expect(job.creator).to eq(user)
    end
  end

  describe "POST /api/v1/jobs/:id/publish" do
    let(:job) { create(:job, team: team, creator: user) }

    it "publishes the job" do
      post "/api/v1/jobs/#{job.id}/publish", params: { team_id: team.id }
      expect(response).to have_http_status(:ok)
      expect(job.reload.status).to eq("published")
    end
  end

  describe "authorization" do
    let(:viewer) { create(:user) }
    let!(:viewer_membership) { create(:team_membership, user: viewer, team: team, role: "viewer") }
    let(:job) { create(:job, team: team, creator: user) }

    it "denies job creation for viewers" do
      sign_in viewer
      post "/api/v1/jobs", params: { team_id: team.id, job: { title: "Test" } }
      expect(response).to have_http_status(:forbidden)
    end
  end
end
