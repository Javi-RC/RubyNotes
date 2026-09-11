require "test_helper"

class CollectionsControllerTest < ActionDispatch::IntegrationTest
  def sign_in(user)
    post sessions_url, params: { name: user.name, password: "password123" }
  end

  setup do
    sign_in users(:one)
  end

  test "index is admin only" do
    get collections_url
    assert_redirected_to home_path

    sign_in users(:admin)
    get collections_url
    assert_response :success
  end

  test "should get new" do
    get new_collection_url
    assert_response :success
  end

  test "should create collection" do
    assert_difference("Collection.count") do
      post collections_url, params: { collection: { title: "New Collection" } }
    end
    assert_redirected_to notes_owned_index_path
  end

  test "should show collection" do
    get collection_url(collections(:one))
    assert_response :success
  end

  test "should get edit" do
    get edit_collection_url(collections(:one))
    assert_response :success
  end

  test "cannot view a collection belonging to someone else" do
    get collection_url(collections(:two))
    assert_redirected_to collections_owned_index_path
  end

  test "cannot delete a collection belonging to someone else" do
    assert_no_difference("Collection.count") do
      delete collection_url(collections(:two))
    end
    assert_redirected_to collections_owned_index_path
  end

  test "owner can delete their own collection" do
    assert_difference("Collection.count", -1) do
      delete collection_url(collections(:one))
    end
  end

  test "sharing a collection notifies the friend but does not grant access yet" do
    assert_difference("Notification.count", 1) do
      patch collection_url(collections(:one)), params: { collection: { share_ids: [users(:two).id] } }
    end

    assert_not_includes collections(:one).reload.share_ids, users(:two).id
  end

  test "adding a note to an already-shared collection shares the note too" do
    collection = collections(:one)
    collection.update!(share_ids: [users(:two).id])
    note = Note.create!(title: "New in collection", user: users(:one))

    patch collection_url(collection),
          params: { collection: { note_ids: [note.id.to_s], share_ids: [users(:two).id.to_s] } }

    assert_includes note.reload.share_ids, users(:two).id
  end

  test "removing a note from a shared collection drops the shares it inherited" do
    collection = collections(:one)
    note = Note.create!(title: "Leaving the collection", user: users(:one))
    collection.update!(share_ids: [users(:two).id], note_ids: [note.id])
    note.update!(share_ids: [users(:two).id])

    # No note_ids key at all: check_box_tag omits an unchecked box entirely
    # rather than submitting it empty, so this is what "nothing checked"
    # actually looks like on the wire.
    patch collection_url(collection),
          params: { collection: { share_ids: [users(:two).id.to_s] } }

    assert_empty note.reload.share_ids
  end

  test "visiting a nonexistent collection redirects instead of erroring" do
    get collection_url("000000000000000000000000")
    assert_redirected_to home_path
    assert_equal "That record could not be found.", flash[:alert]
  end

  test "should require login" do
    reset!
    get collections_url
    assert_redirected_to new_session_path
  end
end
