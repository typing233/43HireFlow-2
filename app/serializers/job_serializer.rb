class JobSerializer < ActiveModel::Serializer
  attributes :id, :title, :department, :location, :employment_type,
             :status, :pipeline_version, :published_at, :closed_at,
             :created_at, :updated_at

  belongs_to :creator, serializer: UserCompactSerializer

  attribute :candidates_count do
    object.candidates.count
  end

  attribute :stages_count do
    object.current_stages.count
  end
end
