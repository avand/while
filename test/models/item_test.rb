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

    assert_equal deleted_at, grandparent.reload.deleted_at
    assert_equal deleted_at, parent.reload.deleted_at
    assert_equal deleted_at, child.reload.deleted_at
    assert_equal previously_deleted_at, previously_deleted_child.reload.deleted_at
  end

end
