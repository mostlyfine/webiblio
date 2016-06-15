require "bundler"
Bundler.require
Mongoid.logger.level = production? ? Logger::WARN : Logger::DEBUG
Mongoid.configure do |config|
  config.load!(File.expand_path 'mongoid.yml')
end

Dir['lib/*.rb'].each {|lib| load lib }

