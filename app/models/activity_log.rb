class ActivityLog < ApplicationRecord
  belongs_to :team
  belongs_to :user, optional: true
  belongs_to :trackable, polymorphic: true, optional: true

  validates :action, presence: true

  scope :chronological, -> { order(created_at: :desc) }
  scope :for_trackable, ->(trackable) {
    where(trackable_type: trackable.class.name, trackable_id: trackable.id)
  }

  def self.record!(team:, user:, trackable:, action:, metadata: {}, changes_snapshot: {})
    create!(
      team: team,
      user: user,
      trackable: trackable,
      action: action,
      metadata: metadata,
      changes_snapshot: changes_snapshot
    )
  end
end
