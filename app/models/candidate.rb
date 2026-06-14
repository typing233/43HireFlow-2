class Candidate < ApplicationRecord
  belongs_to :job
  belongs_to :team
  belongs_to :stage
  has_many :notes, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :activity_logs, as: :trackable, dependent: :destroy

  has_paper_trail

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true

  scope :active, -> { where(status: "active") }
  scope :in_stage, ->(stage_id) { where(stage_id: stage_id) }

  def full_name
    "#{first_name} #{last_name}"
  end

  def move_to_stage!(new_stage, moved_by:)
    transaction do
      old_stage = stage
      lock!
      update!(stage: new_stage)
      ActivityLog.record!(
        team: team,
        user: moved_by,
        trackable: self,
        action: "candidate.stage_moved",
        metadata: {
          from_stage_id: old_stage.id,
          from_stage_name: old_stage.name,
          to_stage_id: new_stage.id,
          to_stage_name: new_stage.name
        }
      )
    end
  end
end
