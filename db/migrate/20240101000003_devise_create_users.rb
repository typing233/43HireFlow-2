class DeviseCreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      # Invitable
      t.string :invitation_token
      t.datetime :invitation_created_at
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.integer :invitation_limit
      t.references :invited_by, polymorphic: true, type: :uuid
      t.integer :invitations_count, default: 0

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :invitation_token, unique: true
    add_index :users, :invitations_count
  end
end
