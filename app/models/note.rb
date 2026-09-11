class Note
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :content, type: String

  has_and_belongs_to_many :shares, class_name: "User", inverse_of: nil
  belongs_to :user
  has_and_belongs_to_many :collections

  validates :title, presence: true
  validates :user, presence: true

  # Backs NotesOwnedController's owned/shared scopes and search, and the
  # authorization checks in ApplicationController that filter by share_ids.
  index({ user_id: 1 })
  index({ share_ids: 1 })
  index({ title: 1 })
end
