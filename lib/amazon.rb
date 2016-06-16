require "amazon/ecs"

class AmazonAPI

  def self.search(code)

    Amazon::Ecs.options = {
      associate_tag: ENV['ASSOCIATE_TAG'],
      AWS_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      AWS_secret_key: ENV['AWS_SECRET_KEY'],
      SearchIndex: "All",
      response_group: "Medium",
      country: "jp",
    }

    book = Amazon::Ecs.item_lookup(code, IdType: "ISBN")
    return book unless book.has_error?

    Amazon::Ecs.item_lookup(code, IdType: "EAN")
  end
end
