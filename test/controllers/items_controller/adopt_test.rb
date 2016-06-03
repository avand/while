require File.expand_path("../../../test_helper.rb", __FILE__)

class ItemsControllerTest < ActionController::TestCase

  test "PATCH to adopt raises an exception if user is not signed in" do
    assert_raises ApplicationController::AuthorizationRequired do
      patch :adopt, params: { hashid: "a1" }
    end
  end

  test "PATCH to adopt raises an exception if the item can't be found" do
    session[:current_user_id] = users(:avand).id

    assert_raises ActiveRecord::RecordNotFound do
      patch :adopt, params: { hashid: "a1", item: {} }
    end
  end

  test "PATCH to adopt raises an exception if the parent can't be found" do
    session[:current_user_id] = users(:avand).id

    assert_raises ActiveRecord::RecordNotFound do
      patch :adopt, params: { hashid: "a1" }
    end
  end

  test "PATCH to adopt raises an exception if the child can't be found" do
    session[:current_user_id] = users(:avand).id

    assert_raises ActiveRecord::RecordNotFound do
      patch :adopt, params: {
        hashid: items(:groceries).to_param,
        child_hashid: "a1"
      }
    end
  end

  test "PATCH to adopt changes the child's parent" do
    session[:current_user_id] = users(:avand).id

    underwear = users(:avand).items.create name: "Underwear", order: 2

    patch :adopt, params: {
      hashid: items(:pack).to_param,
      child_hashid: underwear.to_param
    }

    assert_equal underwear.reload.parent, items(:pack)
    assert_equal 0, underwear.order
  end

  test "PATCH to adopt makes the child last in the new list" do
    session[:current_user_id] = users(:avand).id

    bananas = users(:avand).items.create name: "Bananas", order: 1

    patch :adopt, params: {
      hashid: items(:groceries).to_param,
      child_hashid: bananas.to_param
    }

    assert_equal 3, bananas.reload.order
  end

  test "PATCH to adopt moves a child to the root if no ID is supplied" do
    session[:current_user_id] = users(:avand).id

    patch :adopt, params: { child_hashid: items(:avocados).to_param }

    assert_nil items(:avocados).reload.parent
  end

end
