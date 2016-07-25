require File.expand_path("../../../test_helper.rb", __FILE__)

class ItemsControllerTest < ActionController::TestCase

  test "GET to index raises an exception if user is not signed in" do
    assert_raises ApplicationController::AuthorizationRequired do
      get :index, params: { hashid: "a1" }
    end
  end

  test "GET to index saves the item ID as a cookie" do
    session[:current_user_id] = users(:avand).id

    get :index, params: { hashid: "gZ" }

    assert_equal "gZ", cookies[:last_viewed_item_hashid]
  end

  test "GET to index redirects to the last viewed item" do
    session[:current_user_id] = users(:avand).id

    cookies[:last_viewed_item_hashid] = "a1"

    get :index

    assert_response :redirect
    assert_redirected_to items_path("a1")
  end

  test "GET to index does not redirect to the last viewed item if there’s a
        HTTP referrer" do
    session[:current_user_id] = users(:avand).id

    cookies[:last_viewed_item_hashid] = "a1"
    request.env["HTTP_REFERER"] = "http://getwhile.com/items/gZ"

    get :index

    assert_response :success
  end

  test "GET to index removes last viewed item cookie when viewing the root" do
    session[:current_user_id] = users(:avand).id

    cookies[:last_viewed_item_hashid] = "a1"

    get :index

    assert_nil cookies[:last_viewed_item_hashid]
  end

end
