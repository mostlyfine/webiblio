require "bundler"
Bundler.require

module Webiblio
  class Application < Sinatra::Application
    enable :sessions, :logging
    set :session_secret, ENV['AWS_SECRET_KEY']
    register Sinatra::Contrib
    register Sinatra::Flash

    configure do
      Amazon::Ecs.options = {
        associate_tag: ENV['ASSOCIATE_TAG'],
        AWS_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        AWS_secret_key: ENV['AWS_SECRET_KEY'],
        SearchIndex: "All",
        response_group: "Large",
        country: "jp",
      }

      Mongoid.logger.level = production? ? Logger::WARN : Logger::DEBUG
      Mongoid.load!(File.expand_path('mongoid.yml'))

      Dir['lib/*.rb'].each {|lib| require_relative lib }
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
      user = User.where(employee_number: params[:number].chop.to_i).first
      unless user
        flash[:notice] = "認証できませんでした。もう一度スキャンして下さい。"
        redirect "/login"
      end
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
      @books = Book.all.asc(:title)
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
      book ||= {message: "書籍が見つかりませんでした。"}
      json book
    end

    get "/loanout" do
      slim :loanout
    end

    post "/loanout" do
      slip = Slip.where(isbn: params[:isbn], returned_at: nil).first
      if slip
        json({message: "すでに貸出されています。"})
      else
        Slip.create(isbn: params[:isbn], employee_number: session[:uid],  checkouted_at: Time.now)
        book = Book.where(isbn: params[:isbn]).first
        json book
      end
    end

    get "/putback" do
      slim :putback
    end

    post "/putback" do
      slip = Slip.where(isbn: params[:isbn], employee_number: session[:uid], returned_at: nil).first
      if slip
        slip.update_attributes!(returned_at: Time.now)
        book = Book.where(isbn: params[:isbn]).first
        json book
      else
        json({message: "すでに返却されているか、登録されていない書籍です。"})
      end
    end
  end
end
