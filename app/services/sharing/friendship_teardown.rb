module Sharing
  # Removes every trace of a friendship: each side loses the shares it held
  # on the other's notes and collections (including dropping a note from a
  # collection it only stayed in because of that share), and the friendship
  # itself is removed. Used both when a user explicitly unfriends someone
  # (FriendsController) and, one-directionally against a soon-to-be-destroyed
  # account, when an account is deleted (Sharing::AccountTransfer).
  class FriendshipTeardown
    def self.call(user_a, user_b)
      new(user_a, user_b).call
    end

    def initialize(user_a, user_b)
      @user_a = user_a
      @user_b = user_b
    end

    def call
      strip_shares(content_owner: @user_a, removed_person: @user_b)
      strip_shares(content_owner: @user_b, removed_person: @user_a)

      @user_a.friend_ids.delete(@user_b.id)
      @user_b.friend_ids.delete(@user_a.id)
      @user_a.save
      @user_b.save
    end

    private

    def strip_shares(content_owner:, removed_person:)
      strip_note_shares(content_owner, removed_person)
      strip_collection_shares(content_owner, removed_person)
    end

    def strip_note_shares(content_owner, removed_person)
      content_owner.notes.each do |note|
        note.shares.delete(removed_person) if (note.share_ids || []).include?(removed_person.id)
      end
    end

    def strip_collection_shares(content_owner, removed_person)
      content_owner.collections.each do |collection|
        next unless (collection.share_ids || []).include?(removed_person.id)

        collection.notes.each do |note|
          note.collections.delete(collection) if note.user_id == removed_person.id
        end
        collection.shares.delete(removed_person)
      end
    end
  end
end
