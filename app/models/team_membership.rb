class TeamMembership < ApplicationRecord
  belongs_to :user
  belongs_to :team

  ROLES = %w[owner admin hiring_manager recruiter member viewer].freeze

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :team_id }

  scope :admins, -> { where(role: %w[owner admin]) }

  def can_manage_team?
    role.in?(%w[owner admin])
  end

  def can_manage_jobs?
    role.in?(%w[owner admin hiring_manager recruiter])
  end

  def can_manage_candidates?
    role.in?(%w[owner admin hiring_manager recruiter])
  end

  def can_view?
    true
  end
end
