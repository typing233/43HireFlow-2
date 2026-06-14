class PipelineUpgradeService
  attr_reader :new_stages

  def initialize(job, user)
    @job = job
    @user = user
    @new_stages = []
    @stage_id_mapping = {} # old_stage_id => new_stage_id
  end

  def add_stage!(new_stage)
    @job.transaction do
      new_version = @job.pipeline_version + 1

      @job.current_stages.each do |stage|
        @new_stages << stage.dup.tap do |s|
          s.pipeline_version = new_version
          s.save!
          @stage_id_mapping[stage.id] = s.id
        end
      end

      new_stage.pipeline_version = new_version
      new_stage.save!
      @new_stages << new_stage

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
        @new_stages << dup
        @stage_id_mapping[s.id] = dup.id
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
        @new_stages << s.dup.tap do |dup|
          dup.pipeline_version = new_version
          dup.save!
          @stage_id_mapping[s.id] = dup.id
        end
      end

      stage.update!(active: false)
      @job.update!(pipeline_version: new_version)
      migrate_candidates!(new_version, removed_stage: stage)
      log_upgrade!(new_version, "stage_removed", { stage_name: stage.name })
    end
  end

  def reorder!(stage_positions)
    @job.transaction do
      new_version = @job.pipeline_version + 1
      position_map = stage_positions.index_by { |sp| sp[:id].to_s }

      @job.current_stages.each do |s|
        dup = s.dup
        dup.pipeline_version = new_version
        if position_map[s.id.to_s]
          dup.position = position_map[s.id.to_s][:position].to_i
        end
        dup.save!
        @new_stages << dup
        @stage_id_mapping[s.id] = dup.id
      end

      @job.update!(pipeline_version: new_version)
      migrate_candidates!(new_version)
      log_upgrade!(new_version, "stages_reordered", {})
    end
  end

  private

  def migrate_candidates!(new_version, removed_stage: nil)
    fallback_stage = @job.stages.where(pipeline_version: new_version, active: true)
                         .order(:position).first

    @job.candidates.find_each do |candidate|
      if removed_stage && candidate.stage_id == removed_stage.id
        target_id = fallback_stage.id
      else
        # Use the explicit mapping: old stage → its corresponding new version stage
        target_id = @stage_id_mapping[candidate.stage_id]
        target_id ||= fallback_stage.id
      end

      candidate.update_columns(stage_id: target_id, pipeline_version: new_version)
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
