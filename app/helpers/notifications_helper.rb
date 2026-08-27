module NotificationsHelper
  TYPES = {
    "friend_request" => { icon: "user-friends", style: "primary" },
    "friendship_response" => { icon: "user-friends", style: "success" },
    "note_share" => { icon: "sticky-note", style: "primary" },
    "note_accepted" => { icon: "sticky-note", style: "success" },
    "collection_share" => { icon: "folder-open", style: "warning" },
    "collection_accepted" => { icon: "folder-open", style: "success" }
  }.freeze

  # Each status carries an icon as well as a colour, so the state is never
  # conveyed by colour alone.
  STATUSES = {
    "pending" => { badge: "badge-warning", label: "Pending", icon: "hourglass-half" },
    "accepted" => { badge: "badge-success", label: "Accepted", icon: "check" },
    "denied" => { badge: "badge-danger", label: "Denied", icon: "xmark" },
    "read" => { badge: "badge-neutral", label: "Read", icon: "envelope-open" },
    "unread" => { badge: "badge-primary", label: "Unread", icon: "envelope" },
    "revoked" => { badge: "badge-danger", label: "Revoked", icon: "ban" }
  }.freeze

  UNKNOWN_TYPE = { icon: "bell", style: "neutral" }.freeze

  def notification_presentation(notification)
    status = STATUSES.fetch(notification.status) do
      { badge: "badge-neutral", label: notification.status.to_s.humanize, icon: "circle-info" }
    end

    { type: TYPES.fetch(notification.notification_type, UNKNOWN_TYPE), status: status }
  end
end
