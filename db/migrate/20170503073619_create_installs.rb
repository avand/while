class CreateInstalls < ActiveRecord::Migration[5.0]
  def change
    create_table :installs do |t|
      t.integer :user_id
    end

    add_index :installs, :id
    add_index :installs, :user_id
  end
end
