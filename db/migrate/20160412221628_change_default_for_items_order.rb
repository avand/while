class ChangeDefaultForItemsOrder < ActiveRecord::Migration[5.0]
  def up
    change_column_default :items, :order, 0
    Item.where(order: nil).update_all order: 0
  end

  def down
    change_column_default :items, :order, nil
  end
end
