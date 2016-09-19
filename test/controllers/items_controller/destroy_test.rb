require File.expand_path("../../../test_helper.rb", __FILE__)

class ItemsControllerTest < ActionController::TestCase

  test "DELETE to destroy raises an exception if the user is not signed in" do
    assert_raises ApplicationController::AuthorizationRequired do
      delete :destroy, params: { hashid: "a1" }
    end
  end

  test "DELETE to destroy raises an exception if the item cannot be found" do
    session[:current_user_id] = users(:avand).id

    assert_raises ActiveRecord::RecordNotFound do
      delete :destroy, params: { hashid: "a1" }
    end
  end

  test "DELETE to destroy sets the deleted_at for the item to the specified
        date and time" do
    session[:current_user_id] = users(:avand).id

    delete :destroy, params: {
      hashid: items(:groceries).to_param,
      deleted_at: "2016-05-1T12:15:00.000Z"
    }

    expected_deleted_at = DateTime.parse "2016-05-1T12:15:00.000Z"
    assert_equal expected_deleted_at, items(:groceries).reload.deleted_at
  end

  test "DELETE to destroy logs an action for the current user" do
    session[:current_user_id] = users(:avand).id

    assert_difference "users(:avand).actions.count" do
      delete :destroy, params: {
        hashid: items(:groceries).to_param,
        deleted_at: "2016-05-1T12:15:00.000Z"
      }
    end

    assert_equal "deleted item #{items(:groceries).id}", Action.last.name
  end

end
