class AddUserIdToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :user_id, :integer
    add_index :items, :user_id
  end
end
