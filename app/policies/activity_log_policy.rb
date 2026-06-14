class ActivityLogPolicy < ApplicationPolicy
  def index?
    membership.present?
  end
end
