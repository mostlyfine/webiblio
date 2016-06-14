require "bundler"
Bundler.require

module Webiblio
  class Application < Sinatra::Application
    enable :sessions, :logging
    set :session_secret, ENV['RAKUTEN_APPLICATION_ID']
    register Sinatra::Contrib

    configure do

      Mongoid.logger.level = production? ? Logger::WARN : Logger::DEBUG
      Mongoid.configure do |config|
        config.load!(File.expand_path 'mongoid.yml')
      end

      Dir['lib/*.rb'].each {|lib| load lib }
    end

    helpers do
      def rakuten
        @rakuten ||= Rakuten.new(ENV['RAKUTEN_APPLICATION_ID'])
      end
    end

    get "/" do
      redirect "/book"
    end

    get "/book" do
      slim :book
    end

    # 書籍登録
    post "/book" do
      book = Book.where(isbn: params[:isbn]).first
      unless book
        rakuten.search(params[:isbn])[:Items].each do |item|
          book ||= Book.create(
            title: item[:title],
            sub_title: item[:subTitle],
            series: item[:seriesName],
            description: item[:contents],
            author: item[:author],
            publisher: item[:publisherName],
            format: item[:size],
            isbn: item[:isbn],
            caption: item[:itemCaption],
            small_image_url: item[:smallImageUrl],
            medium_image_url: item[:mediumImageUrl],
            large_image_url: item[:largeImageUrl]
          )
        end
      end
      json book
    end
  end
end
