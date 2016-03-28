class AddClearedToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :cleared, :boolean
    add_index :items, :cleared
  end
end
