class CreateActions < ActiveRecord::Migration[5.0]
  def change
    create_table :actions do |t|
      t.string :name
      t.integer :user_id
      t.datetime :occurred_at
    end

    add_index :actions, :user_id
    add_index :actions, :occurred_at
  end
end
