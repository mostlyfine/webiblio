require "amazon/ecs"

class AmazonAPI

  def self.search(code)
    book = Amazon::Ecs.item_lookup(code, IdType: "ISBN")
    return book unless book.has_error?
    Amazon::Ecs.item_lookup(code, IdType: "EAN")
  end
end
