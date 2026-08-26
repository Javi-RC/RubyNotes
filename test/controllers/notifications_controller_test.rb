require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  def sign_in(user)
    post sessions_url, params: { name: user.name, password: "password123" }
  end

  setup do
    # users(:two) is the receiver of the fixture notifications.
    sign_in users(:two)
  end

  test "should get index" do
    get notifications_url
    assert_response :success
  end

  test "should accept friend request" do
    post accept_notification_url(notifications(:friend_request))
    assert_redirected_to notifications_path
    assert_includes users(:two).reload.friend_ids, users(:one).id
  end

  test "should deny notification" do
    notification = notifications(:friend_request)
    post deny_notification_url(notification)
    assert_redirected_to notifications_path
    assert_equal "denied", notification.reload.status
  end

  test "cannot deny a notification addressed to someone else" do
    sign_in users(:one)
    notification = notifications(:friend_request)

    post deny_notification_url(notification)
    assert_redirected_to notifications_path
    assert_equal "pending", notification.reload.status
  end

  test "cannot destroy a notification addressed to someone else" do
    sign_in users(:one)

    assert_no_difference("Notification.count") do
      delete notification_url(notifications(:friend_request))
    end
  end

  test "cannot rewrite the parties on a notification" do
    notification = notifications(:friend_request)
    original_sender = notification.sender_id

    patch notification_url(notification),
          params: { notification: { status: "read", sender_id: users(:two).id } }

    assert_equal original_sender, notification.reload.sender_id
  end

  test "there is no route to create a notification" do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/notifications", method: :post)
    end
  end

  test "should require login" do
    reset!
    get notifications_url
    assert_redirected_to new_session_path
  end
end
