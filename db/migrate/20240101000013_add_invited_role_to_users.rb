class AddInvitedRoleToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :invited_role, :string
  end
end
