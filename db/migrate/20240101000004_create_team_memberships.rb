class CreateTeamMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :team_memberships, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :team, null: false, foreign_key: true, type: :uuid
      t.string :role, null: false, default: "member"
      t.timestamps
    end

    add_index :team_memberships, [:user_id, :team_id], unique: true
    add_index :team_memberships, :role
  end
end
