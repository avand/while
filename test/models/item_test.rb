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

end
