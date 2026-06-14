class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :invitable

  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships
  has_many :created_jobs, class_name: "Job", foreign_key: :creator_id, dependent: :nullify
  has_many :notes, dependent: :nullify
  has_many :activity_logs, dependent: :nullify
  belongs_to :invited_team, class_name: "Team", optional: true

  validates :first_name, presence: true, unless: :created_by_invite?
  validates :last_name, presence: true, unless: :created_by_invite?

  private

  def created_by_invite?
    invitation_token.present? && !invitation_accepted_at.present?
  end

  public

  def full_name
    "#{first_name} #{last_name}"
  end

  def role_in(team)
    team_memberships.find_by(team: team)&.role
  end

  def admin_of?(team)
    role_in(team) == "admin"
  end

  def owner_of?(team)
    role_in(team) == "owner"
  end

  def member_of?(team)
    team_memberships.exists?(team: team)
  end
end
