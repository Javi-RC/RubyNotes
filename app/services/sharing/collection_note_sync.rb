module Sharing
  # Keeps each note's own share list in step with its collection membership:
  # a note added to a shared collection inherits everyone the collection is
  # already (acceptedly) shared with, plus the collection's owner when they
  # aren't the one editing it; a note dropped from the collection loses those
  # same shares again.
  class CollectionNoteSync
    def initialize(collection:, note_ids:, shared_with:)
      @collection = collection
      @note_ids = note_ids.map { |id| BSON::ObjectId(id) }
      @shared_with = shared_with
    end

    def call
      add_notes_to_shares
      remove_notes_from_shares
    end

    private

    def add_notes_to_shares
      @note_ids.each do |note_id|
        note = Note.find(note_id)
        next if @collection.notes.include?(note)

        @shared_with.each do |user|
          next if note.user_id == user.id

          note.shares.push(user)
          note.save
        end
      end
    end

    def remove_notes_from_shares
      @collection.notes.each do |note|
        next if @note_ids.include?(note.id)

        @shared_with.each do |user|
          note.shares.delete(user)
          note.save
        end
      end
    end
  end
end
