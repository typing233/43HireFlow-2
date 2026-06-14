class UserCompactSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email

  attribute :full_name do
    object.full_name
  end
end
