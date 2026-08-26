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

  test "should require login" do
    reset_session!
    get collections_url
    assert_redirected_to new_session_path
  end
end
