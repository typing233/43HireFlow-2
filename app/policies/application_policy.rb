class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

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
    membership&.can_manage_jobs?
  end

  def destroy?
    membership&.can_manage_team?
  end

  private

  def membership
    @membership ||= user.team_memberships.find_by(team: current_team)
  end

  def current_team
    ActsAsTenant.current_tenant
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if current_team
        scope.where(team_id: current_team.id)
      else
        scope.none
      end
    end

    private

    def current_team
      ActsAsTenant.current_tenant
    end

    def membership
      @membership ||= user.team_memberships.find_by(team: current_team)
    end
  end
end
