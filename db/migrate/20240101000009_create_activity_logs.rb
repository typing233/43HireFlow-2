class CreateActivityLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :activity_logs, id: :uuid do |t|
      t.references :team, null: false, foreign_key: true, type: :uuid
      t.references :user, foreign_key: true, type: :uuid
      t.references :trackable, polymorphic: true, type: :uuid
      t.string :action, null: false
      t.jsonb :metadata, default: {}
      t.jsonb :changes_snapshot, default: {}
      t.timestamps
    end

    add_index :activity_logs, [:team_id, :created_at]
    add_index :activity_logs, [:trackable_type, :trackable_id, :created_at],
              name: "index_activity_logs_on_trackable_and_created_at"
    add_index :activity_logs, :action
  end
end
