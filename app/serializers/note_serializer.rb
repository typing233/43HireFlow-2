class NoteSerializer < ActiveModel::Serializer
  attributes :id, :body, :private, :created_at, :updated_at

  belongs_to :user, serializer: UserCompactSerializer
end
