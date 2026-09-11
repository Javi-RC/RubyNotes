require "test_helper"

class AccountTransferTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @friend = users(:two)
  end

  test "a note with no shares is destroyed along with its owner" do
    note = Note.create!(title: "Private note", user: @user)

    Sharing::AccountTransfer.call(@user)

    assert_nil Note.where(id: note.id).first
  end

  test "a shared note is handed to the first person it was shared with, instead of destroyed" do
    note = Note.create!(title: "Shared note", user: @user, share_ids: [@friend.id])

    Sharing::AccountTransfer.call(@user)
    note.reload

    assert_equal @friend.id, note.user_id
    assert_not_includes note.share_ids, @friend.id
  end

  test "a shared collection is handed to the first person it was shared with" do
    collection = Collection.create!(title: "Shared collection", user: @user, share_ids: [@friend.id])

    Sharing::AccountTransfer.call(@user)
    collection.reload

    assert_equal @friend.id, collection.user_id
  end

  test "tears down every friendship the user had" do
    @user.friends << @friend
    @friend.friends << @user

    Sharing::AccountTransfer.call(@user)

    assert_not_includes @friend.reload.friend_ids, @user.id
  end

  test "destroys notifications the user sent or received" do
    Notification.create!(notification_type: "friend_request", status: "pending",
                         message: "hi", sender_id: @user.id, receiver_id: @friend.id, user: @user)
    Notification.create!(notification_type: "friend_request", status: "pending",
                         message: "hi back", sender_id: @friend.id, receiver_id: @user.id, user: @friend)

    Sharing::AccountTransfer.call(@user)

    assert_empty Notification.where(:receiver_id.in => [@user.id]).or(:sender_id.in => [@user.id])
  end
end
