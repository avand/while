require File.expand_path("../../../test_helper.rb", __FILE__)

class ItemsControllerTest < ActionController::TestCase

  test "GET to index raises an exception if user is not signed in" do
    assert_raises ApplicationController::AuthorizationRequired do
      get :index, params: { id: 1 }
    end
  end

  test "GET to index saves the item ID as a cookie" do
    session[:current_user_id] = users(:avand).id

    get :index, params: { id: 1 }

    assert_equal "1", cookies[:last_viewed_item_id]
  end

  test "GET to index redirects to the last viewed item" do
    session[:current_user_id] = users(:avand).id

    cookies[:last_viewed_item_id] = 1

    get :index

    assert_response :redirect
    assert_redirected_to items_path(id: 1)
  end

  test "GET to index does not redirect to the last viewed item if there’s a
        HTTP referrer" do
    session[:current_user_id] = users(:avand).id

    cookies[:last_viewed_item_id] = 1
    request.env["HTTP_REFERER"] = "http://getwhile.com/items/123"

    get :index

    assert_response :success
  end

end
