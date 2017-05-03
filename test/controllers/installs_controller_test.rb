require File.expand_path("../../test_helper.rb", __FILE__)

class InstallsControllerTest < ActionController::TestCase

  test "GET to new redirects to items if there is a current user" do
    session[:current_user_id] = users(:avand).id

    get :new, params: { user_hashid: "xxx", install_hashid: "yyy" }

    assert_redirected_to items_path
  end

  test "GET to new with an invalid user hashid raises a not found exception" do
    avand_install = users(:avand).create_install

    get :new, params: { user_hashid: "xxx", install_hashid: avand_install }

    assert_redirected_to root_path
  end

  test "GET to new with an invalid install hashid raises a not found exception" do
    users(:avand).create_install

    get :new, params: { user_hashid: users(:avand), install_hashid: "yyy" }

    assert_redirected_to root_path
  end

  test "GET to new with a mismatched install raises a not found exception" do
    users(:avand).create_install
    jessica_install = users(:jessica).create_install

    get :new, params: { user_hashid: users(:avand), install_hashid: jessica_install }

    assert_redirected_to root_path
  end

  test "POST to create saves the user’s ID in the session, effectively logging them in" do
    avand_install = users(:avand).create_install

    post :create, params: { user_hashid: users(:avand), install_hashid: avand_install }

    assert_equal users(:avand).id, session[:current_user_id]
    assert_response :success
  end

  test "POST to create deletes the install for good measure" do
    avand_install = users(:avand).create_install
    jessica_install = users(:jessica).create_install

    post :create, params: { user_hashid: users(:avand), install_hashid: avand_install }

    assert_nil Install.find_by_id(avand_install.id)
    refute_nil Install.find_by_id(jessica_install.id)
  end

end
