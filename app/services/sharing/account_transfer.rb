module Sharing
  # Prepares a user's data for account deletion (UsersController#destroy):
  # every note and collection they own is handed to the first person it was
  # shared with (so a shared item survives its owner's account) or destroyed
  # if nobody had it; every friendship is torn down; every notification they
  # sent or received is removed. Must run before the user itself is
  # destroyed.
  class AccountTransfer
    def self.call(user)
      new(user).call
    end

    def initialize(user)
      @user = user
    end

    def call
      reassign_or_destroy(@user.notes)
      reassign_or_destroy(@user.collections)
      @user.friends.to_a.each { |friend| FriendshipTeardown.call(@user, friend) }
      destroy_notifications
    end

    private

    # #notes/#collections are has_many relations queried live by user_id, the
    # very field reassign_or_destroy below is about to change. Iterating the
    # relation directly re-runs that query mid-loop as soon as the first
    # document's user_id no longer matches, which yielded the same document
    # twice in practice: once to reassign it, once more (now with its shares
    # already cleared) to fall into the destroy branch and delete the note we
    # had just handed to its new owner. Snapshotting to an array first avoids
    # that.
    def reassign_or_destroy(resources)
      resources.to_a.each do |resource|
        if resource.shares.any?
          new_owner = User.find(resource.share_ids.first)
          resource.user = new_owner
          resource.shares.delete(new_owner)
          resource.save
        else
          resource.destroy
        end
      end
    end

    def destroy_notifications
      Notification.where(:receiver_id.in => [@user.id]).or(:sender_id.in => [@user.id]).each(&:destroy)
    end
  end
end
