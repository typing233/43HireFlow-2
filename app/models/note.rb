class Note < ApplicationRecord
  belongs_to :candidate
  belongs_to :user

  validates :body, presence: true

  scope :visible_to, ->(user) {
    where(private: false).or(where(user: user))
  }
  scope :chronological, -> { order(created_at: :desc) }
end
