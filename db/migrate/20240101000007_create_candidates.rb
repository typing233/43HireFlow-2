class CreateCandidates < ActiveRecord::Migration[7.1]
  def change
    create_table :candidates, id: :uuid do |t|
      t.references :job, null: false, foreign_key: true, type: :uuid
      t.references :team, null: false, foreign_key: true, type: :uuid
      t.references :stage, null: false, foreign_key: true, type: :uuid
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :source
      t.string :status, null: false, default: "active"
      t.integer :pipeline_version, null: false, default: 1
      t.jsonb :custom_fields, default: {}
      t.integer :lock_version, null: false, default: 0
      t.timestamps
    end

    add_index :candidates, [:job_id, :stage_id]
    add_index :candidates, [:team_id, :email]
    add_index :candidates, :status
    add_index :candidates, :lock_version
  end
end
