require "amazon/ecs"

Amazon::Ecs.options = {
  associate_tag: "mostlyfine-22",
  AWS_access_key_id: "AKIAJ63UZ7N72M37WMJA",
  AWS_secret_key: "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",
  SearchIndex: "All",
  response_group: "Large",
  country: "jp",
}

res = Amazon::Ecs.item_lookup("4959241714725", IdType: "JAN", SearchIndex: "DVD")
puts res.marshal_dump
res = Amazon::Ecs.item_lookup("9784091874313", IdType: "ISBN")
puts res.marshal_dump
