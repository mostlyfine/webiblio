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

      def authenticate!
        unless session[:uid]
          session[:path] = request.path_info
          redirect "/login"
        end
        @user ||= User.where(employee_number: session[:uid]).first
      end
    end

    before %r{^/(loanout|putback)} do
      authenticate!
    end

    get "/" do
      slim :index
    end

    get "/login" do
      session[:uid] = nil
      slim :login
    end

    post "/login" do
      user = User.where(employee_number: params[:number]).first or redirect "/login"
      session[:uid] = user.employee_number
      path = session[:path] || "/"
      session[:path] = nil
      redirect path
    end

    get "/logout" do
      session[:path] = session[:uid] = nil
      redirect "/"
    end

    get "/books" do
      @books = Book.all
      slim :books
    end

    get "/book" do
      slim :book
    end

    post "/book" do
      book = Book.where(isbn: params[:isbn]).first
      unless book
        rakuten.search(params[:isbn])[:Items].each do |item|
          book ||= Book.find_or_create_by(
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

    get "/loanout" do
      slim :loanout
    end

    post "/loanout" do
      book = Book.where(isbn: params[:isbn]).first
      halt 404 if !book or book.user
      book.update_attributes!(user: @user)
      json book.as_json
    end

    get "/putback" do
      slim :putback
    end

    post "/putback" do
      book = Book.where(isbn: params[:isbn]).first
      halt 404 if !book or !book.user
      book.update_attributes!(user: nil)
      json book
    end
  end
end
