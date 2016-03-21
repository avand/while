class AddAncestryToItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :items, :parent_item_id, :integer
    add_column :items, :ancestry, :string
    add_index :items, :ancestry
  end
end
