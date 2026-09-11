module Sharing
  # Diffs a note's or collection's submitted share list against what it
  # already has, notifying every newly-listed friend with a pending share
  # request and every dropped one with a revocation.
  #
  # share_ids intentionally does NOT grow to include the new ids: a share
  # only takes effect once the receiving notification is accepted (see
  # NotificationsController#accept_note_share / #accept_collection_share).
  # It does shrink immediately on revocation, which is why callers persist
  # `share_ids` from here rather than the submitted list.
  class ResourceShareUpdate
    attr_reader :share_ids

    def initialize(resource:, resource_type:, sender:, submitted_share_ids:)
      @resource = resource
      @resource_type = resource_type
      @sender = sender
      @share_ids = (resource.share_ids || []).dup
      @submitted_share_ids = submitted_share_ids
    end

    # Yields each revoked friend (a User) after its notification is created
    # but before it is dropped from share_ids, so a caller can cascade the
    # revocation elsewhere (CollectionsController strips it from every note
    # in the collection too).
    def call
      notify_new_shares
      notify_revoked_shares { |friend| yield friend if block_given? }
      self
    end

    private

    def notify_new_shares
      (@submitted_share_ids - @share_ids).each do |id|
        friend = User.find(id)
        Notifier.share_requested(resource: @resource, resource_type: @resource_type,
                                 sender: @sender, receiver: friend)
      end
    end

    def notify_revoked_shares
      (@share_ids - @submitted_share_ids).each do |id|
        friend = User.find(id)
        Notifier.share_revoked(resource: @resource, resource_type: @resource_type,
                               sender: @sender, receiver: friend)
        yield friend
        @share_ids.delete(id)
      end
    end
  end
end
