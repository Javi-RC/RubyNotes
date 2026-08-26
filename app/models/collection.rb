class Collection
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  
  has_and_belongs_to_many :shares, class_name: 'User',  inverse_of: nil
  belongs_to :user
  has_and_belongs_to_many :notes

end
