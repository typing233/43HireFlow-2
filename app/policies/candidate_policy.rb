class CandidatePolicy < ApplicationPolicy
  def index?
    membership.present?
  end

  def show?
    membership.present?
  end

  def create?
    membership&.can_manage_candidates?
  end

  def update?
    membership&.can_manage_candidates?
  end

  def destroy?
    membership&.can_manage_team?
  end

  def move_stage?
    membership&.can_manage_candidates?
  end

  def batch_move?
    membership&.can_manage_candidates?
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
end
