class CreateVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :versions, id: :uuid do |t|
      t.string :item_type, null: false
      t.uuid :item_id, null: false
      t.string :event, null: false
      t.string :whodunnit
      t.jsonb :object
      t.jsonb :object_changes
      t.datetime :created_at
    end

    add_index :versions, [:item_type, :item_id]
    add_index :versions, :created_at
  end
end
