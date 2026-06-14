module Seeds
  class DefaultStages
    DEFAULT_STAGES = [
      { name: "Applied", position: 0 },
      { name: "Phone Screen", position: 1 },
      { name: "Interview", position: 2 },
      { name: "Technical Assessment", position: 3 },
      { name: "Offer", position: 4 },
      { name: "Hired", position: 5 }
    ].freeze

    def self.create_for(job)
      DEFAULT_STAGES.each do |stage_attrs|
        job.stages.create!(
          stage_attrs.merge(pipeline_version: job.pipeline_version)
        )
      end
    end
  end
end
