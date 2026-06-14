class AttachmentSerializer < ActiveModel::Serializer
  attributes :id, :file_name, :content_type, :file_size, :category, :created_at

  belongs_to :user, serializer: UserCompactSerializer

  attribute :download_url do
    Rails.application.routes.url_helpers.rails_blob_path(object.file, only_path: true) if object.file.attached?
  end
end
