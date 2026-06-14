class StageSerializer < ActiveModel::Serializer
  attributes :id, :name, :position, :pipeline_version, :active, :metadata

  attribute :candidates_count do
    object.candidates_count
  end
end
