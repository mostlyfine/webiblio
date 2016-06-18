require "mongoid"

class Slip
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  include Mongoid::Timestamps::Created

  field :isbn, type: String
  field :employee_number, type: String
  field :checkouted_at, type: DateTime
  field :returned_at, type: DateTime
end
