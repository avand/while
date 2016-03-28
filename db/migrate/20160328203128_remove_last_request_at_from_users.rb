class RemoveLastRequestAtFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :first_request_at, :datetime
  end
end
