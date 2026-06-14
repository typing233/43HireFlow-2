class CreateAttachments < ActiveRecord::Migration[7.1]
  def change
    create_table :attachments, id: :uuid do |t|
      t.references :attachable, polymorphic: true, type: :uuid, null: false
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :team, null: false, foreign_key: true, type: :uuid
      t.string :file_name, null: false
      t.string :content_type
      t.integer :file_size
      t.string :category, default: "general"
      t.timestamps
    end

    add_index :attachments, [:attachable_type, :attachable_id]
    add_index :attachments, :category
  end
end
