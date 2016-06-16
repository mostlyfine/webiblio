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

Mongoid.logger.level = production? ? Logger::WARN : Logger::DEBUG
Mongoid.configure do |config|
  config.load!(File.expand_path 'mongoid.yml')
end

Dir['lib/*.rb'].each {|lib| load lib }

