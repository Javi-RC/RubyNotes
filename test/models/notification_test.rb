require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "should not save notification without notification_type" do
    notification = Notification.new(status: "pending", message: "Test", user: users(:one))
    assert_not notification.save
  end

  test "should save valid notification" do
    notification = Notification.new(
      notification_type: "friend_request",
      status: "pending",
      message: "Test",
      sender_id: users(:one).id,
      receiver_id: users(:two).id,
      user: users(:one)
    )
    assert notification.save
  end

  test "should validate status inclusion" do
    notification = Notification.new(
      notification_type: "friend_request",
      status: "invalid_status",
      message: "Test",
      user: users(:one)
    )
    assert_not notification.save
  end

  test "default status should be pending" do
    notification = Notification.new(notification_type: "friend_request", user: users(:one))
    assert_equal "pending", notification.status
  end

  test "should accept all valid statuses" do
    %w[pending accepted denied read unread revoked].each do |status|
      notification = Notification.new(notification_type: "friend_request", status: status, user: users(:one))
      assert notification.valid?, "Status #{status} should be valid"
    end
  end

  test "should belong to user" do
    assert_respond_to notifications(:friend_request), :user
  end
end
