require "test_helper"

class CollectionNoteSyncTest < ActiveSupport::TestCase
  setup do
    @owner = users(:one)
    @friend = users(:two)
    @collection = Collection.create!(title: "Trip", user: @owner, share_ids: [@friend.id])
    @note = Note.create!(title: "Itinerary", user: @owner)
  end

  test "adding a note to a shared collection gives it the collection's shares" do
    Sharing::CollectionNoteSync.new(
      collection: @collection, note_ids: [@note.id], shared_with: [@friend]
    ).call

    assert_includes @note.reload.share_ids, @friend.id
  end

  test "a note already in the collection is left alone" do
    @collection.update!(note_ids: [@note.id])
    @note.update!(share_ids: [])

    Sharing::CollectionNoteSync.new(
      collection: @collection, note_ids: [@note.id], shared_with: [@friend]
    ).call

    assert_empty @note.reload.share_ids
  end

  test "removing a note from the collection drops the shares it inherited" do
    @collection.update!(note_ids: [@note.id])
    @note.update!(share_ids: [@friend.id])

    Sharing::CollectionNoteSync.new(
      collection: @collection, note_ids: [], shared_with: [@friend]
    ).call

    assert_empty @note.reload.share_ids
  end

  test "the collection owner is never added as a share on their own note" do
    other_owner = users(:admin)
    note_owned_by_other = Note.create!(title: "Someone else's note", user: other_owner)

    Sharing::CollectionNoteSync.new(
      collection: @collection, note_ids: [note_owned_by_other.id], shared_with: [other_owner]
    ).call

    assert_empty note_owned_by_other.reload.share_ids
  end
end
