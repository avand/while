class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.string :name
      t.integer :parent_item_id
      t.boolean :completed

      t.timestamps
    end
  end
end
