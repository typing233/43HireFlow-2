class BatchMoveCandidatesJob < ApplicationJob
  queue_as :default

  def perform(candidate_ids:, stage_id:, moved_by_id:, team_id:, job_id:)
    stage = Stage.find(stage_id)
    user = User.find(moved_by_id)
    team = Team.find(team_id)
    job = Job.find(job_id)
    failed = []

    # Re-validate: only move candidates that belong to this team AND this job
    safe_candidates = job.candidates.where(team: team, id: candidate_ids)

    safe_candidates.find_each do |candidate|
      candidate.with_lock do
        old_stage = candidate.stage
        candidate.update!(stage: stage)
        ActivityLog.record!(
          team: team,
          user: user,
          trackable: candidate,
          action: "candidate.stage_moved",
          metadata: {
            from_stage_id: old_stage.id,
            from_stage_name: old_stage.name,
            to_stage_id: stage.id,
            to_stage_name: stage.name,
            batch: true
          }
        )
      end
    rescue ActiveRecord::StaleObjectError, ActiveRecord::RecordInvalid => e
      failed << { candidate_id: candidate.id, error: e.message }
    end

    if failed.any?
      Rails.logger.warn("BatchMoveCandidates: #{failed.size} failures: #{failed.to_json}")
    end
  end
end
