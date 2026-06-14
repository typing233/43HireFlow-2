class TeamPolicy < ApplicationPolicy
  def show?
    membership.present?
  end

  def update?
    membership&.can_manage_team?
  end

  def invite_member?
    membership&.can_manage_team?
  end

  def manage_members?
    membership&.can_manage_team?
  end
end
