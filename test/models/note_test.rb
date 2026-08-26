require "test_helper"

class NoteTest < ActiveSupport::TestCase
  test "should not save note without title" do
    note = Note.new(content: "Content", user: users(:one))
    assert_not note.save
  end

  test "should not save note without user" do
    note = Note.new(title: "Title", content: "Content")
    assert_not note.save
  end

  test "should save valid note" do
    note = Note.new(title: "Valid Note", content: "Content", user: users(:one))
    assert note.save
  end

  test "should belong to user" do
    assert_respond_to notes(:one), :user
    assert_equal users(:one), notes(:one).user
  end

  test "should have many collections" do
    assert_respond_to notes(:one), :collections
  end

  test "should have shares" do
    assert_respond_to notes(:one), :shares
  end
end
