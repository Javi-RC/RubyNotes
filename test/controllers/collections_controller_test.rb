require "test_helper"

class CollectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post sessions_url, params: { name: users(:one).name, password: "password123" }
  end

  test "should get index" do
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
    assert_redirected_to notes_owned_path
  end

  test "should show collection" do
    get collection_url(collections(:one))
    assert_response :success
  end

  test "should get edit" do
    get edit_collection_url(collections(:one))
    assert_response :success
  end

  test "should require login" do
    reset_session!
    get collections_url
    assert_redirected_to new_session_path
  end
end
