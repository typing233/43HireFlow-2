class JobPolicy < ApplicationPolicy
  def index?
    membership.present?
  end

  def show?
    membership.present?
  end

  def create?
    membership&.can_manage_jobs?
  end

  def update?
    can_manage_this_job?
  end

  def destroy?
    membership&.can_manage_team?
  end

  def publish?
    can_manage_this_job?
  end

  def close?
    can_manage_this_job?
  end

  def archive?
    can_manage_this_job?
  end

  def restore?
    membership&.can_manage_team?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if current_team
        scope.where(team_id: current_team.id)
      else
        scope.none
      end
    end
  end

  private

  def can_manage_this_job?
    return false unless membership
    membership.can_manage_team? || (membership.can_manage_jobs? && record.creator_id == user.id)
  end
end
