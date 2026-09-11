class Collection
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String

  has_and_belongs_to_many :shares, class_name: "User", inverse_of: nil
  belongs_to :user
  has_and_belongs_to_many :notes

  validates :title, presence: true
  validates :user, presence: true

  # Mirrors Note's indexes: same owned/shared scopes and search pattern in
  # CollectionsOwnedController and ApplicationController.
  index({ user_id: 1 })
  index({ share_ids: 1 })
  index({ title: 1 })
end
