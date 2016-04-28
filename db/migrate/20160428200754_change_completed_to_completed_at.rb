class ChangeCompletedToCompletedAt < ActiveRecord::Migration[5.0]
  def up
    add_column :items, :completed_at, :datetime
    add_index :items, :completed_at
    Item.reset_column_information
    Item.where(completed: true).update_all completed_at: Time.now
    remove_column :items, :completed
  end

  def down
    add_column :items, :completed, :boolean
    Item.reset_column_information
    Item.where("completed_at is not null").update_all completed: true
    remove_column :items, :completed_at
  end
end
