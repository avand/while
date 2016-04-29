class RenameClearedToArchived < ActiveRecord::Migration[5.0]
  def change
    rename_column :items, :cleared, :archived
  end
end
