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
end
