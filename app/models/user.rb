class User
  include Mongoid::Document
  include ActiveModel::SecurePassword

  field :name, type: String
  field :password_digest, type: String
  field :role, type: String, default: "user"

  has_secure_password

  validates :name, presence: true, uniqueness: true
  validates :role, inclusion: { in: %w[user admin] }

  has_and_belongs_to_many :notifications
  has_and_belongs_to_many :friends, class_name: "User", inverse_of: nil
  has_many :notes
  has_many :collections

  def admin?
    role == "admin"
  end
end
