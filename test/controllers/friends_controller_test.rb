require "test_helper"

class FriendsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post sessions_url, params: { name: users(:one).name, password: "password123" }
  end

  test "should get index" do
    get friends_url
    assert_response :success
  end

  test "should get new" do
    get new_friend_url
    assert_response :success
  end

  test "should send friend request" do
    assert_difference("Notification.count") do
      post send_request_path(users(:two))
    end
    assert_redirected_to home_path
  end

  test "sending a request to a nonexistent user redirects instead of erroring" do
    post send_request_path("000000000000000000000000")
    assert_redirected_to home_path
    assert_equal "That record could not be found.", flash[:alert]
  end

  test "should require login" do
    reset!
    get friends_url
    assert_redirected_to new_session_path
  end
end
