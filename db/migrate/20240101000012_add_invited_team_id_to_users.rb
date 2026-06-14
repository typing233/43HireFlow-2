class AddInvitedTeamIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :invited_team_id, :uuid
    add_index :users, :invited_team_id
  end
end
