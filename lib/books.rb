require "mongoid"

class Book
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  include Mongoid::Timestamps::Created

  field :title, type: String
  field :author, type: String
  field :publisher, type: String
  field :asin, type: String
  field :isbn, type: String
  field :small_image_url, type: String
  field :medium_image_url, type: String
  field :large_image_url, type: String

  def checkout?
    !! Slip.where(isbn: self.isbn, returned_at: nil).first
  end

  def self.create_by_amazon(item)
    image = item.get_elements("ImageSets/ImageSet").last
    Book.find_or_create_by(
      title: item.get("ItemAttributes/Title"),
      author: item.get("ItemAttributes/Author"),
      publisher: item.get("ItemAttributes/Publisher"),
      asin: item.get("ASIN"),
      isbn: item.get("ItemAttributes/EAN") || item.get("ItemAttributes/ISBN"),
      small_image_url: image.get("SmallImage/URL"),
      medium_image_url: image.get("MediumImage/URL"),
      large_image_url: image.get("LargeImage/URL"),
    )
  end

  def self.create_by_rakuten(item)
    Book.find_or_create_by(
      title: item[:title],
      author: item[:author],
      publisher: item[:publisherName],
      isbn: item[:isbn],
      small_image_url: item[:smallImageUrl],
      medium_image_url: item[:mediumImageUrl],
      large_image_url: item[:largeImageUrl]
    )
  end
end
