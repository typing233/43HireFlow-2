class StagePolicy < ApplicationPolicy
  def index?
    membership.present?
  end

  def create?
    membership&.can_manage_jobs?
  end

  def update?
    membership&.can_manage_jobs?
  end

  def destroy?
    membership&.can_manage_team?
  end

  def reorder?
    membership&.can_manage_jobs?
  end
end
