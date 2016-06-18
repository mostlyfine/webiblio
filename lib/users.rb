require "mongoid"

class User
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  include Mongoid::Timestamps::Created

  field :name, type: String
  field :mail, type: String
  field :employee_number, type: String

  def self.auth(num)
    self.in(employee_number: [num, num.chop.to_i]).first
  end

  def icon
    self.mail.gsub(/@.+$/, "")
  end
end

