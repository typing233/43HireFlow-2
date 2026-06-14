class ActivityLogSerializer < ActiveModel::Serializer
  attributes :id, :action, :metadata, :changes_snapshot, :created_at

  belongs_to :user, serializer: UserCompactSerializer

  attribute :trackable_type do
    object.trackable_type
  end

  attribute :trackable_id do
    object.trackable_id
  end
end
