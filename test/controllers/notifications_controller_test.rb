require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post sessions_url, params: { name: users(:two).name, password: "password123" }
  end

  test "should get index" do
    get notifications_url
    assert_response :success
  end

  test "should accept friend request" do
    notification = notifications(:friend_request)
    get accept_notification_url(notification)
    assert_redirected_to notifications_path
  end

  test "should deny notification" do
    notification = notifications(:friend_request)
    get deny_notification_url(notification)
    assert_redirected_to notifications_path
    assert_equal "denied", notification.reload.status
  end

  test "should require login" do
    reset_session!
    get notifications_url
    assert_redirected_to new_session_path
  end
end
