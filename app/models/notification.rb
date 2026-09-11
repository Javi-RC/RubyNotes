class Notification
  include Mongoid::Document

  field :notification_type, type: String
  field :status, type: String, default: "pending"
  field :message, type: String
  field :sender_id, type: BSON::ObjectId
  field :receiver_id, type: BSON::ObjectId
  field :share_id, type: BSON::ObjectId, default: nil

  belongs_to :user

  validates :notification_type, presence: true
  validates :status, inclusion: { in: %w[pending accepted denied read unread revoked] }

  TYPES = %w[friend_request friendship_response note_share note_accepted collection_share collection_accepted].freeze
  STATUSES = %w[pending accepted denied read unread revoked].freeze

  # NotificationsController's #index and #own_notifications filter and sort
  # by exactly these fields on every request.
  index({ receiver_id: 1, notification_type: 1 })
  index({ sender_id: 1 })
end
