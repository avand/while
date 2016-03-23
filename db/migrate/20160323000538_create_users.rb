class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :uid
      t.string :image
      t.datetime :first_request_at
      t.datetime :last_request_at
      t.integer :request_count

      t.timestamps
    end

    add_index :users, :email
    add_index :users, :uid
  end
end
