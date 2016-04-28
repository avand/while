require File.expand_path("../../test_helper.rb", __FILE__)

class ActionsControllerTest < ActionController::TestCase

  test "POST to log raises an exception if user is not signed in" do
    assert_raises ApplicationController::AuthorizationRequired do
      post :log, params: { name: "foo" }
    end
  end

  test "POST to log logs an action for the current user" do
    session[:current_user_id] = users(:avand).id

    assert_difference "users(:avand).actions.count" do
      post :log, params: { name: "did something" }
    end

    assert action = Action.last
    assert_equal "did something", action.name
  end

end
