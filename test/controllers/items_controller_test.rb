require File.expand_path("../../test_helper.rb", __FILE__)

class ItemsControllerTest < ActionController::TestCase

  test "POST to create raises an exception if user is not signed in" do
    assert_raises ApplicationController::AuthorizationRequired do
      post :create, params: { item: {} }
    end
  end

  test "POST to create creates an item" do
    session[:current_user_id] = users(:avand).id

    assert_difference "users(:avand).items.count" do
      post :create, params: { item: { name: "foo" } }
    end

    item = Item.last
    assert_equal "foo", item.name
    assert_equal 3, item.order
  end

  test "PATCH to adopt raises an exception if user is not signed in" do
    assert_raises ApplicationController::AuthorizationRequired do
      patch :adopt, params: { id: 1 }
    end
  end

  test "PATCH to adopt raises an exception if the parent can't be found" do
    session[:current_user_id] = users(:avand).id

    assert_raises ActiveRecord::RecordNotFound do
      patch :adopt, params: { id: -1 }
    end
  end

  test "PATCH to adopt raises an exception if the child can't be found" do
    session[:current_user_id] = users(:avand).id

    assert_raises ActiveRecord::RecordNotFound do
      patch :adopt, params: { id: items(:groceries).id, child_id: -1 }
    end
  end

  test "PATCH to adopt changes the child's parent" do
    session[:current_user_id] = users(:avand).id

    underwear = users(:avand).items.create name: "Underwear", order: 2

    patch :adopt, params: { id: items(:pack).id, child_id: underwear.id }

    assert_equal underwear.reload.parent, items(:pack)
    assert_equal 0, underwear.order
  end

  test "PATCH to adopt makes the child last in the new list" do
    session[:current_user_id] = users(:avand).id

    bananas = users(:avand).items.create name: "Bananas", order: 1

    patch :adopt, params: { id: items(:groceries).id, child_id: bananas.id }

    assert_equal 3, bananas.reload.order
  end

end
