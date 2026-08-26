require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  def sign_in(user)
    post sessions_url, params: { name: user.name, password: "password123" }
  end

  setup do
    sign_in users(:one)
  end

  test "index is admin only" do
    get notes_url
    assert_redirected_to home_path

    sign_in users(:admin)
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
    assert_redirected_to notes_owned_index_path
  end

  test "should show note" do
    get note_url(notes(:one))
    assert_response :success
  end

  test "should get edit" do
    get edit_note_url(notes(:one))
    assert_response :success
  end

  test "cannot view a note belonging to someone else" do
    get note_url(notes(:two))
    assert_redirected_to notes_owned_index_path
  end

  test "cannot update a note belonging to someone else" do
    patch note_url(notes(:two)), params: { note: { title: "Hijacked" } }
    assert_redirected_to notes_owned_index_path
    assert_equal "Another Note", notes(:two).reload.title
  end

  test "cannot delete a note belonging to someone else" do
    assert_no_difference("Note.count") do
      delete note_url(notes(:two))
    end
    assert_redirected_to notes_owned_index_path
  end

  test "owner can delete their own note" do
    assert_difference("Note.count", -1) do
      delete note_url(notes(:one))
    end
  end

  test "a note shared with you is readable but not deletable" do
    note = notes(:two)
    note.shares << users(:one)
    note.save!

    get note_url(note)
    assert_response :success

    assert_no_difference("Note.count") do
      delete note_url(note)
    end
    assert_redirected_to notes_owned_index_path
  end

  test "should require login" do
    reset_session!
    get notes_url
    assert_redirected_to new_session_path
  end
end
