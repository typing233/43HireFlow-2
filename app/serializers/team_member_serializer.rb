class TeamMemberSerializer < ActiveModel::Serializer
  attributes :id, :role, :created_at

  attribute :user do
    {
      id: object.user.id,
      first_name: object.user.first_name,
      last_name: object.user.last_name,
      email: object.user.email,
      full_name: object.user.full_name
    }
  end
end
