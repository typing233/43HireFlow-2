class CandidateSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :phone,
             :source, :status, :pipeline_version, :lock_version,
             :created_at, :updated_at

  belongs_to :stage, serializer: StageSerializer
end
