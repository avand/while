require File.expand_path("../../test_helper.rb", __FILE__)

class CurrentUserTrackingTest < ActionDispatch::IntegrationTest

  setup do
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:default, uid: users(:avand).uid)
  end

  test "last_visited_at timestamp is updated on each authenticated request" do
    users(:avand).update last_visited_at: nil

    original_updated_at = users(:avand).updated_at

    now = Time.now
    two_weeks_from_now = now + 2.weeks

    Timecop.freeze(now) do
      get "/auth/google_oauth2"
      follow_redirect!
      assert_equal now.to_i, users(:avand).reload.last_visited_at.to_i
      assert_equal original_updated_at.to_i, users(:avand).updated_at.to_i
    end

    Timecop.freeze(two_weeks_from_now) do
      get "/items"
      assert_equal two_weeks_from_now.to_i, users(:avand).reload.last_visited_at.to_i
      assert_equal original_updated_at.to_i, users(:avand).updated_at.to_i
    end
  end

  test "request_count increments on each authenticated request" do
    users(:avand).update request_count: nil

    get "/auth/google_oauth2"
    follow_redirect!
    assert_equal 1, users(:avand).reload.request_count

    post "/items", params: { item: { name: "Do something" } }
    assert_equal 2, users(:avand).reload.request_count
  end

end
