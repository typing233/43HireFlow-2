require "rails_helper"

RSpec.describe Candidate, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:job) }
    it { is_expected.to belong_to(:team) }
    it { is_expected.to belong_to(:stage) }
    it { is_expected.to have_many(:notes).dependent(:destroy) }
    it { is_expected.to have_many(:attachments) }
    it { is_expected.to have_many(:activity_logs) }
  end

  describe "#move_to_stage!" do
    let(:team) { create(:team) }
    let(:user) { create(:user) }
    let(:job) { create(:job, team: team) }
    let(:stage1) { create(:stage, job: job, name: "Applied") }
    let(:stage2) { create(:stage, job: job, name: "Interview") }
    let(:candidate) { create(:candidate, job: job, team: team, stage: stage1) }

    it "moves candidate to new stage" do
      candidate.move_to_stage!(stage2, moved_by: user)
      expect(candidate.reload.stage).to eq(stage2)
    end

    it "creates activity log" do
      expect {
        candidate.move_to_stage!(stage2, moved_by: user)
      }.to change(ActivityLog, :count).by(1)

      log = ActivityLog.last
      expect(log.action).to eq("candidate.stage_moved")
      expect(log.metadata["from_stage_name"]).to eq("Applied")
      expect(log.metadata["to_stage_name"]).to eq("Interview")
    end
  end

  describe "optimistic locking" do
    let(:candidate) { create(:candidate) }

    it "raises StaleObjectError on concurrent update" do
      c1 = Candidate.find(candidate.id)
      c2 = Candidate.find(candidate.id)

      c1.update!(first_name: "Changed1")
      expect { c2.update!(first_name: "Changed2") }.to raise_error(ActiveRecord::StaleObjectError)
    end
  end
end
