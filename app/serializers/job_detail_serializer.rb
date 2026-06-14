class JobDetailSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :department, :location,
             :employment_type, :status, :pipeline_version,
             :published_at, :closed_at, :archived_at,
             :created_at, :updated_at

  belongs_to :creator, serializer: UserCompactSerializer
  has_many :current_stages, key: :stages, serializer: StageSerializer

  attribute :candidates_count do
    object.candidates.count
  end
end
