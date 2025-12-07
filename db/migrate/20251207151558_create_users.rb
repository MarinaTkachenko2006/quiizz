class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :nickname, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.timestamp :created_time, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
    add_index :users, :nickname, unique: true
    add_index :users, :email, unique: true
  end
end
