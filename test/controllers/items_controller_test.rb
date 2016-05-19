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

  test "POST to create logs an action for the current user" do
    session[:current_user_id] = users(:avand).id

    assert_difference "users(:avand).actions.count" do
      post :create, params: { item: { name: "foo" } }
    end

    assert_equal "created item #{Item.last.id}", Action.last.name
  end

  test "PATCH to update raises an exception if user is not signed in" do
    assert_raises ApplicationController::AuthorizationRequired do
      patch :update, params: { id: 1, item: {} }
    end
  end

  test "PATCH to update updates the item" do
    session[:current_user_id] = users(:avand).id

    patch :update, params: { id: items(:avocados).id, item: { name: "pears" } }

    assert_equal "pears", items(:avocados).reload.name
  end

  test "PATCH to update logs an action for the current user" do
    session[:current_user_id] = users(:avand).id

    assert_difference "users(:avand).actions.count" do
      patch :update, params: { id: items(:avocados).id, item: { name: "foo" } }
    end

    assert_equal "updated item #{items(:avocados).id}", Action.last.name
  end

end
