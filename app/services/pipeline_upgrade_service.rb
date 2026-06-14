class PipelineUpgradeService
  def initialize(job, user)
    @job = job
    @user = user
  end

  def add_stage!(new_stage)
    @job.transaction do
      new_version = @job.pipeline_version + 1

      @job.current_stages.each do |stage|
        stage.dup.tap do |s|
          s.pipeline_version = new_version
          s.save!
        end
      end

      new_stage.pipeline_version = new_version
      new_stage.save!

      @job.update!(pipeline_version: new_version)
      migrate_candidates!(new_version)
      log_upgrade!(new_version, "stage_added", { stage_name: new_stage.name })
    end
  end

  def update_stage!(stage, params)
    @job.transaction do
      new_version = @job.pipeline_version + 1

      @job.current_stages.each do |s|
        dup = s.dup
        dup.pipeline_version = new_version
        dup.assign_attributes(params) if s.id == stage.id
        dup.save!
      end

      @job.update!(pipeline_version: new_version)
      migrate_candidates!(new_version)
      log_upgrade!(new_version, "stage_updated", { stage_name: stage.name })
    end
  end

  def remove_stage!(stage)
    @job.transaction do
      new_version = @job.pipeline_version + 1

      @job.current_stages.where.not(id: stage.id).each do |s|
        s.dup.tap do |dup|
          dup.pipeline_version = new_version
          dup.save!
        end
      end

      stage.update!(active: false)
      @job.update!(pipeline_version: new_version)
      migrate_candidates!(new_version, removed_stage: stage)
      log_upgrade!(new_version, "stage_removed", { stage_name: stage.name })
    end
  end

  private

  def migrate_candidates!(new_version, removed_stage: nil)
    new_stages = @job.stages.where(pipeline_version: new_version, active: true).order(:position)

    @job.candidates.find_each do |candidate|
      if removed_stage && candidate.stage_id == removed_stage.id
        target = new_stages.first
      else
        old_stage = @job.stages.find_by(id: candidate.stage_id)
        target = new_stages.find_by(name: old_stage&.name) || new_stages.first
      end

      candidate.update_columns(stage_id: target.id, pipeline_version: new_version)
    end
  end

  def log_upgrade!(new_version, action_detail, metadata)
    ActivityLog.record!(
      team: @job.team,
      user: @user,
      trackable: @job,
      action: "pipeline.upgraded",
      metadata: metadata.merge(
        from_version: new_version - 1,
        to_version: new_version,
        detail: action_detail
      )
    )
  end
end
