class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :description, :settings, :created_at

  attribute :members_count do
    object.team_memberships.count
  end
end
