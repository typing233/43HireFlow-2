class Attachment < ApplicationRecord
  belongs_to :attachable, polymorphic: true
  belongs_to :user
  belongs_to :team

  has_one_attached :file

  validates :file_name, presence: true
  validates :file, attached: true,
            content_type: %w[
              application/pdf
              image/png image/jpeg image/gif
              application/msword
              application/vnd.openxmlformats-officedocument.wordprocessingml.document
            ],
            size: { less_than: 10.megabytes }

  CATEGORIES = %w[resume cover_letter portfolio other general].freeze
  validates :category, inclusion: { in: CATEGORIES }

  before_save :set_file_metadata

  private

  def set_file_metadata
    return unless file.attached?

    self.content_type = file.blob.content_type
    self.file_size = file.blob.byte_size
  end
end
