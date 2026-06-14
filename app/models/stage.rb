class Stage < ApplicationRecord
  belongs_to :job
  has_many :candidates, dependent: :nullify

  has_paper_trail

  validates :name, presence: true
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :pipeline_version, presence: true

  scope :active, -> { where(active: true) }
  scope :for_version, ->(version) { where(pipeline_version: version) }
  scope :ordered, -> { order(:position) }

  def deactivate!
    update!(active: false)
  end

  def candidates_count
    candidates.where(pipeline_version: pipeline_version).count
  end
end
