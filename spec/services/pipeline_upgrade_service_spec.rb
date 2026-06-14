require "rails_helper"

RSpec.describe PipelineUpgradeService, type: :service do
  let(:team) { create(:team) }
  let(:user) { create(:user) }
  let(:job) { create(:job, team: team, creator: user) }
  let!(:stage1) { create(:stage, job: job, name: "Applied", position: 0, pipeline_version: 1) }
  let!(:stage2) { create(:stage, job: job, name: "Interview", position: 1, pipeline_version: 1) }
  let!(:candidate) { create(:candidate, job: job, team: team, stage: stage1, pipeline_version: 1) }

  subject { described_class.new(job, user) }

  describe "#add_stage!" do
    it "creates new pipeline version with the additional stage" do
      new_stage = job.stages.build(name: "Phone Screen", position: 2)
      subject.add_stage!(new_stage)

      expect(job.reload.pipeline_version).to eq(2)
      expect(job.current_stages.count).to eq(3)
      expect(candidate.reload.pipeline_version).to eq(2)
    end
  end

  describe "#remove_stage!" do
    it "removes stage and migrates candidates to first stage" do
      candidate.update_columns(stage_id: stage2.id)
      subject.remove_stage!(stage2)

      expect(job.reload.pipeline_version).to eq(2)
      expect(job.current_stages.pluck(:name)).to eq(["Applied"])
      expect(candidate.reload.stage.name).to eq("Applied")
    end
  end

  describe "#update_stage!" do
    it "updates stage in new pipeline version" do
      subject.update_stage!(stage1, { name: "New Applied" })

      expect(job.reload.pipeline_version).to eq(2)
      new_stage = job.current_stages.find_by(position: 0)
      expect(new_stage.name).to eq("New Applied")
    end
  end
end
