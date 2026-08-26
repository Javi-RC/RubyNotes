require "test_helper"

class CollectionTest < ActiveSupport::TestCase
  test "should not save collection without title" do
    collection = Collection.new(user: users(:one))
    assert_not collection.save
  end

  test "should not save collection without user" do
    collection = Collection.new(title: "Title")
    assert_not collection.save
  end

  test "should save valid collection" do
    collection = Collection.new(title: "Valid Collection", user: users(:one))
    assert collection.save
  end

  test "should belong to user" do
    assert_respond_to collections(:one), :user
    assert_equal users(:one), collections(:one).user
  end

  test "should have many notes" do
    assert_respond_to collections(:one), :notes
  end

  test "should have shares" do
    assert_respond_to collections(:one), :shares
  end
end
