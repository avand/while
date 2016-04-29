require File.expand_path("../../../test_helper.rb", __FILE__)

class ItemsControllerTest < ActionController::TestCase

  test "PATCH to complete raises an exception if the user is not signed in" do
    assert_raises ApplicationController::AuthorizationRequired do
      patch :complete, params: { id: 1 }
    end
  end

  test "PATCH to complete raises an exception if the item cannot be found" do
    session[:current_user_id] = users(:avand).id

    assert_raises ActiveRecord::RecordNotFound do
      patch :complete, params: { id: -1 }
    end
  end

  test "PATCH to complete sets the completed_at for the item to the specified
        date and time" do
    session[:current_user_id] = users(:avand).id

    patch :complete, params: {
      id: items(:groceries).id,
      completed_at: "2016-04-28T22:30:00.000Z"
    }

    expected_completed_at = DateTime.parse "2016-04-28T22:30:00.000Z"
    assert_equal expected_completed_at, items(:groceries).reload.completed_at
  end

  test "PATCH to complete sets the completed_at to nil" do
    session[:current_user_id] = users(:avand).id

    patch :complete, params: { id: items(:groceries).id, completed_at: nil }

    assert_nil items(:groceries).reload.completed_at
  end

end
