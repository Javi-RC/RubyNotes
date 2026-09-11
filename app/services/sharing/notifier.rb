module Sharing
  # Builds the Notification pair for sharing a note or collection: a pending
  # request when access is offered, an immediate one when it is revoked.
  # NotesController and CollectionsController used to each spell this out by
  # hand with only the noun and notification_type differing.
  class Notifier
    def self.share_requested(resource:, resource_type:, sender:, receiver:)
      Notification.create!(
        notification_type: "#{resource_type}_share",
        status: "pending",
        message: "#{sender.name} wants to share the #{resource_type} #{resource.title} with you.",
        sender_id: sender.id,
        receiver_id: receiver.id,
        share_id: resource.id,
        user: sender
      )
    end

    def self.share_revoked(resource:, resource_type:, sender:, receiver:)
      Notification.create!(
        notification_type: "#{resource_type}_share",
        status: "revoked",
        message: revoked_message(resource_type, sender, resource),
        sender_id: sender.id,
        receiver_id: receiver.id,
        share_id: resource.id,
        user: sender
      )
    end

    # Preserves the original per-resource wording rather than flattening it
    # into one generic sentence.
    def self.revoked_message(resource_type, sender, resource)
      if resource_type == "collection"
        "#{sender.name} has revoked the sharing of the collection #{resource.title} with you."
      else
        "#{sender.name} has removed you from the #{resource_type} #{resource.title}."
      end
    end
  end
end
