require "test_helper"

class FriendshipTeardownTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @friend = users(:two)
    @user.friends << @friend
    @friend.friends << @user
  end

  test "removes the friendship on both sides" do
    Sharing::FriendshipTeardown.call(@user, @friend)

    assert_not_includes @user.reload.friend_ids, @friend.id
    assert_not_includes @friend.reload.friend_ids, @user.id
  end

  test "strips the friend's share from a note the user owns" do
    note = Note.create!(title: "Shared with friend", user: @user, share_ids: [@friend.id])

    Sharing::FriendshipTeardown.call(@user, @friend)

    assert_not_includes note.reload.share_ids, @friend.id
  end

  test "strips the user's share from a note the friend owns (the other direction)" do
    note = Note.create!(title: "Shared with user", user: @friend, share_ids: [@user.id])

    Sharing::FriendshipTeardown.call(@user, @friend)

    assert_not_includes note.reload.share_ids, @user.id
  end

  test "a note kept in a shared collection only because of the friendship is dropped from it" do
    friend_note = Note.create!(title: "Friend's note in my collection", user: @friend)
    collection = Collection.create!(title: "Shared collection", user: @user,
                                    share_ids: [@friend.id], note_ids: [friend_note.id])

    Sharing::FriendshipTeardown.call(@user, @friend)

    assert_not_includes friend_note.reload.collection_ids, collection.id
    assert_not_includes collection.reload.share_ids, @friend.id
  end
end
