class RemoveArchivedFromItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :items, :archived, :boolean
  end

  def down
    add_column  :items, :archived, :boolean
    add_index :items, :archived, :boolean
  end
end
