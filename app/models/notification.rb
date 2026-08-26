class Notification
  include Mongoid::Document

  field :type, type: String
  field :status, type: String, default: "pending"
  field :message, type: String
  field :sender_id, type: BSON::ObjectId
  field :receiver_id, type: BSON::ObjectId
  field :share_id, type: BSON::ObjectId, default: nil

  belongs_to :user

  validates :type, presence: true
  validates :status, inclusion: { in: %w(pending accepted denied read unread revoked) }

  TYPES = %w(friend_request friendship_response note_share note_accepted collection_share collection_accepted)

  STATUSES = %w(pending accepted denied read unread revoked)

end