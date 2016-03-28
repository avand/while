class RenameLastRequestAt < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :last_request_at, :last_visited_at
  end
end
