class Team < ApplicationRecord
  has_many :team_memberships, dependent: :destroy
  has_many :users, through: :team_memberships
  has_many :jobs, dependent: :destroy
  has_many :candidates, dependent: :destroy
  has_many :activity_logs, dependent: :destroy
  has_many :attachments, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9\-]+\z/ }

  before_validation :generate_slug, on: :create

  private

  def generate_slug
    self.slug ||= name&.parameterize
  end
end
