class CreateStages < ActiveRecord::Migration[7.1]
  def change
    create_table :stages, id: :uuid do |t|
      t.references :job, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.integer :pipeline_version, null: false, default: 1
      t.boolean :active, null: false, default: true
      t.jsonb :metadata, default: {}
      t.timestamps
    end

    add_index :stages, [:job_id, :pipeline_version, :position]
    add_index :stages, [:job_id, :active]
  end
end
