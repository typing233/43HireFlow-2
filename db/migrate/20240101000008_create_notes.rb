class CreateNotes < ActiveRecord::Migration[7.1]
  def change
    create_table :notes, id: :uuid do |t|
      t.references :candidate, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.text :body, null: false
      t.boolean :private, null: false, default: false
      t.timestamps
    end

    add_index :notes, [:candidate_id, :created_at]
  end
end
