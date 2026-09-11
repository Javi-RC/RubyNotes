require "test_helper"

class ResourceShareUpdateTest < ActiveSupport::TestCase
  setup do
    @owner = users(:one)
    @friend = users(:two)
    @note = notes(:one)
  end

  test "a newly submitted share sends a pending request but does not grant access yet" do
    assert_difference("Notification.count", 1) do
      result = Sharing::ResourceShareUpdate.new(
        resource: @note, resource_type: "note", sender: @owner, submitted_share_ids: [@friend.id]
      ).call

      assert_empty result.share_ids
    end

    notification = Notification.last
    assert_equal "pending", notification.status
    assert_equal "note_share", notification.notification_type
    assert_equal @friend.id, notification.receiver_id
    assert_equal @note.id, notification.share_id
  end

  test "submitting the same id twice does not re-notify" do
    @note.update!(share_ids: [@friend.id])

    assert_no_difference("Notification.count") do
      result = Sharing::ResourceShareUpdate.new(
        resource: @note, resource_type: "note", sender: @owner, submitted_share_ids: [@friend.id]
      ).call

      assert_equal [@friend.id], result.share_ids
    end
  end

  test "dropping an existing share notifies the revocation and removes it immediately" do
    @note.update!(share_ids: [@friend.id])

    assert_difference("Notification.count", 1) do
      result = Sharing::ResourceShareUpdate.new(
        resource: @note, resource_type: "note", sender: @owner, submitted_share_ids: []
      ).call

      assert_empty result.share_ids
    end

    notification = Notification.last
    assert_equal "revoked", notification.status
    assert_equal @friend.id, notification.receiver_id
  end

  test "revoking yields the removed friend so a caller can cascade the change" do
    @note.update!(share_ids: [@friend.id])
    yielded = []

    Sharing::ResourceShareUpdate.new(
      resource: @note, resource_type: "note", sender: @owner, submitted_share_ids: []
    ).call { |friend| yielded << friend }

    assert_equal [@friend], yielded
  end
end
