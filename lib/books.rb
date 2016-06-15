require "mongoid"

class Book
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  include Mongoid::Timestamps::Created

  field :title, type: String
  field :sub_title, type: String
  field :series, type: String
  field :description, type: String
  field :author, type: String
  field :publisher, type: String
  field :format, type: String
  field :isbn, type: String
  field :caption, type: String
  field :small_image_url, type: String
  field :medium_image_url, type: String
  field :large_image_url, type: String

  has_one :user
end
