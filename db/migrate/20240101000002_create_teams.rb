class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :teams, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.jsonb :settings, default: {}
      t.timestamps
    end

    add_index :teams, :slug, unique: true
  end
end
