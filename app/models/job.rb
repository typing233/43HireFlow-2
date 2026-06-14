class Job < ApplicationRecord
  include AASM

  belongs_to :team
  belongs_to :creator, class_name: "User"
  has_many :stages, dependent: :destroy
  has_many :candidates, dependent: :destroy

  has_paper_trail

  validates :title, presence: true
  validates :status, presence: true
  validates :pipeline_version, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(status: %w[draft published]) }
  scope :published, -> { where(status: "published") }

  aasm column: :status do
    state :draft, initial: true
    state :published
    state :closed
    state :archived

    event :publish do
      before { self.published_at = Time.current }
      transitions from: :draft, to: :published
    end

    event :close do
      before { self.closed_at = Time.current }
      transitions from: :published, to: :closed
    end

    event :archive do
      before { self.archived_at = Time.current }
      transitions from: [:draft, :closed], to: :archived
    end

    event :restore do
      transitions from: :archived, to: :draft
    end
  end

  def current_stages
    stages.where(pipeline_version: pipeline_version, active: true).order(:position)
  end

  def upgrade_pipeline!
    transaction do
      new_version = pipeline_version + 1
      current_stages.each do |stage|
        stage.dup.tap do |new_stage|
          new_stage.pipeline_version = new_version
          new_stage.save!
        end
      end
      update!(pipeline_version: new_version)
      migrate_candidates_to_new_pipeline!(new_version)
    end
  end

  private

  def migrate_candidates_to_new_pipeline!(new_version)
    old_stages = stages.where(pipeline_version: new_version - 1)
    new_stages = stages.where(pipeline_version: new_version)

    candidates.find_each do |candidate|
      old_stage = old_stages.find_by(id: candidate.stage_id)
      new_stage = new_stages.find_by(name: old_stage&.name) || new_stages.order(:position).first
      candidate.update_columns(stage_id: new_stage.id, pipeline_version: new_version)
    end
  end
end
