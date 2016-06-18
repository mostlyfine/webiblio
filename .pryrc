require "bundler"
Bundler.require

Amazon::Ecs.options = {
  associate_tag: ENV['ASSOCIATE_TAG'],
  AWS_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  AWS_secret_key: ENV['AWS_SECRET_KEY'],
  SearchIndex: "All",
  response_group: "Large",
  country: "jp",
}

Mongoid.logger.level = Logger::DEBUG
Mongo::Logger.logger.level = Logger::DEBUG
Mongoid.load!(File.expand_path('mongoid.yml'), :development)

Dir['lib/*.rb'].each {|lib| require_relative lib }

