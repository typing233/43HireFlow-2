class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :invitable

  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships
  has_many :created_jobs, class_name: "Job", foreign_key: :creator_id, dependent: :nullify
  has_many :notes, dependent: :nullify
  has_many :activity_logs, dependent: :nullify

  validates :first_name, presence: true
  validates :last_name, presence: true

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
