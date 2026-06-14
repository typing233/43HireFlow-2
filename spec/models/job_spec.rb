require "rails_helper"

RSpec.describe Job, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:team) }
    it { is_expected.to belong_to(:creator) }
    it { is_expected.to have_many(:stages).dependent(:destroy) }
    it { is_expected.to have_many(:candidates).dependent(:destroy) }
  end

  describe "state machine" do
    let(:job) { create(:job, :draft) }

    it "transitions from draft to published" do
      expect(job.may_publish?).to be true
      job.publish!
      expect(job.status).to eq("published")
      expect(job.published_at).to be_present
    end

    it "transitions from published to closed" do
      job.publish!
      expect(job.may_close?).to be true
      job.close!
      expect(job.status).to eq("closed")
      expect(job.closed_at).to be_present
    end

    it "transitions from closed to archived" do
      job.publish!
      job.close!
      expect(job.may_archive?).to be true
      job.archive!
      expect(job.status).to eq("archived")
    end

    it "transitions from archived to draft (restore)" do
      job.archive!
      expect(job.may_restore?).to be true
      job.restore!
      expect(job.status).to eq("draft")
    end

    it "cannot transition from published directly to archived" do
      job.publish!
      expect(job.may_archive?).to be false
    end
  end

  describe "#current_stages" do
    let(:job) { create(:job) }

    before do
      create(:stage, job: job, pipeline_version: 1, position: 0, name: "Applied")
      create(:stage, job: job, pipeline_version: 1, position: 1, name: "Interview")
      create(:stage, job: job, pipeline_version: 2, position: 0, name: "Applied")
    end

    it "returns stages for current pipeline version" do
      expect(job.current_stages.count).to eq(2)
      expect(job.current_stages.pluck(:name)).to match_array(["Applied", "Interview"])
    end
  end

  describe "#upgrade_pipeline!" do
    let(:job) { create(:job) }
    let!(:stage1) { create(:stage, job: job, pipeline_version: 1, position: 0, name: "Applied") }
    let!(:stage2) { create(:stage, job: job, pipeline_version: 1, position: 1, name: "Interview") }
    let!(:candidate) { create(:candidate, job: job, stage: stage1, pipeline_version: 1) }

    it "creates new version and migrates candidates" do
      job.upgrade_pipeline!
      expect(job.reload.pipeline_version).to eq(2)
      expect(candidate.reload.pipeline_version).to eq(2)
      expect(candidate.stage.pipeline_version).to eq(2)
    end
  end
end
