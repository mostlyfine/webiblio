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
      user = User.where(employee_number: params[:number].to_i).first or redirect "/login"
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
        AmazonAPI.search(params[:isbn]).items.each do |item|
          book ||= Book.create_by_amazon(item)
        end
      end
      json book
    end

    get "/loanout" do
      slim :loanout
    end

    post "/loanout" do
      book = Book.where(isbn: params[:isbn], loaned_at: nil).first
      halt 404 unless book
      book.update_attributes!(user: @user, loaned_at: Time.now)
      json book
    end

    get "/putback" do
      slim :putback
    end

    post "/putback" do
      book = Book.where(:isbn => params[:isbn], :loaned_at.ne => nil).first
      halt 404 unless book
      book.update_attributes!(user: nil, loaned_at: nil)
      json book
    end
  end
end
