class NotePolicy < ApplicationPolicy
  def index?
    membership.present?
  end

  def create?
    membership&.can_manage_candidates?
  end

  def update?
    record.user_id == user.id
  end

  def destroy?
    record.user_id == user.id || membership&.can_manage_team?
  end
end
