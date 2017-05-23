require File.expand_path("../../test_helper.rb", __FILE__)

class ItemTest < ActiveSupport::TestCase

  test "completed? returns true if completed_at is not nil" do
    assert Item.new(completed_at: 1.day.ago).completed?
    assert Item.new(completed_at: 1.day.from_now).completed?
    refute Item.new(completed_at: nil).completed?
  end

  test "deleted? returns true if deleted_at is not nil" do
    assert Item.new(deleted_at: 1.day.ago).deleted?
    assert Item.new(deleted_at: 1.day.from_now).deleted?
    refute Item.new(deleted_at: nil).deleted?
  end

  test "make_last sets the order to order of the last sibling + 1" do
    item = Item.create

    assert_equal 3, item.order

    Item.create
    item.make_last
    assert_equal 5, item.order
  end

  test "destroying a parent also destroys the descendants" do
    grandparent = Item.create
    parent = grandparent.children.create
    child = parent.children.create

    assert_difference "Item.count", -3 do
      grandparent.destroy
    end
  end

  test "soft_delete sets deleted_at for current item and all descendants" do
    grandparent = Item.create
    parent = grandparent.children.create
    child = parent.children.create

    previously_deleted_at = 2.days.ago
    previously_deleted_child = parent.children.create deleted_at: previously_deleted_at

    deleted_at = Time.now
    grandparent.soft_delete deleted_at

    assert_equal deleted_at.to_i, grandparent.reload.deleted_at.to_i
    assert_equal deleted_at.to_i, parent.reload.deleted_at.to_i
    assert_equal deleted_at.to_i, child.reload.deleted_at.to_i
    assert_equal previously_deleted_at.to_i, previously_deleted_child.reload.deleted_at.to_i
  end

  test "assign_color defaults to the first color" do
    assert_equal Item::COLORS.first, Item.create.color
  end

  test "assign_color ignores items that don’t belong to the same user" do
    users(:avand).items.create(color: Item::COLORS.first)
    assert_equal Item::COLORS.first, users(:jessica).items.create.color
  end

  test "assign_color ignores items without valid color" do
    first_item = users(:avand).items.create
    second_item = users(:avand).items.create

    first_item.update color: nil
    second_item.update color: nil

    assert_equal Item::COLORS.first, users(:avand).items.create.color
  end

  test "assign_color goes back to the first color once it runs out" do
    Item::COLORS.size.times { users(:avand).items.create }    
    assert_equal Item::COLORS.first, users(:avand).items.create.color
  end

end
