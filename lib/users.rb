require "mongoid"

class User
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  include Mongoid::Timestamps::Created

  field :name, type: String
  field :mail, type: String
  field :employee_number, type: String
  field :icon, type: String

  belongs_to :book, inverse_of: :user
end

