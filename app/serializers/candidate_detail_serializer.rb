class CandidateDetailSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :phone,
             :source, :status, :pipeline_version, :custom_fields,
             :lock_version, :created_at, :updated_at

  belongs_to :stage, serializer: StageSerializer
  belongs_to :job, serializer: JobSerializer

  attribute :notes_count do
    object.notes.count
  end

  attribute :attachments_count do
    object.attachments.count
  end
end
