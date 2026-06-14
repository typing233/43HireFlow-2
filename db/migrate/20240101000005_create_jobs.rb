class CreateJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :jobs, id: :uuid do |t|
      t.references :team, null: false, foreign_key: true, type: :uuid
      t.references :creator, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.string :title, null: false
      t.text :description
      t.string :department
      t.string :location
      t.string :employment_type
      t.string :status, null: false, default: "draft"
      t.integer :pipeline_version, null: false, default: 1
      t.datetime :published_at
      t.datetime :closed_at
      t.datetime :archived_at
      t.timestamps
    end

    add_index :jobs, [:team_id, :status]
    add_index :jobs, :creator_id
    add_index :jobs, :status
  end
end
