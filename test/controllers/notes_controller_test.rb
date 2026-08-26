require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    post sessions_url, params: { name: users(:one).name, password: "password123" }
  end

  test "should get index" do
    get notes_url
    assert_response :success
  end

  test "should get new" do
    get new_note_url
    assert_response :success
  end

  test "should create note" do
    assert_difference("Note.count") do
      post notes_url, params: { note: { title: "New Note", content: "Content" } }
    end
    assert_redirected_to notes_owned_path
  end

  test "should show note" do
    get note_url(notes(:one))
    assert_response :success
  end

  test "should get edit" do
    get edit_note_url(notes(:one))
    assert_response :success
  end

  test "should require login" do
    reset_session!
    get notes_url
    assert_redirected_to new_session_path
  end
end
