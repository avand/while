class AddOrderToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :order, :integer
  end
end
