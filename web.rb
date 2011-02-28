require 'sinatra/base'
require 'haml'
require 'oauth'
require 'yajl'
require File.join(File.dirname(__FILE__), 'lib/couchdb/views')

class ZomgInboxWeb < Sinatra::Base
  enable :sessions

  before do
    @db = CONFIG[:couchdb]

    session[:oauth] ||= {}

    consumer_key    = ENV['CONSUMER_KEY']
    consumer_secret = ENV['CONSUMER_SECRET']

    @consumer ||= OAuth::Consumer.new(consumer_key, consumer_secret,
                                      site:               "https://www.google.com",
                                      request_token_path: '/accounts/OAuthGetRequestToken?scope=https://mail.google.com/%20https://www.googleapis.com/auth/userinfo%23email',
                                      access_token_path:  '/accounts/OAuthGetAccessToken',
                                      authorize_path:     '/accounts/OAuthAuthorizeToken'
                                     )

    if !session[:oauth][:request_token].nil? && !session[:oauth][:request_token_secret].nil?
      @request_token = OAuth::RequestToken.new(@consumer, session[:oauth][:request_token], session[:oauth][:request_token_secret])
    end

    if !session[:oauth][:access_token].nil? && !session[:oauth][:access_token_secret].nil?
      @access_token = OAuth::AccessToken.new(@consumer, session[:oauth][:access_token], session[:oauth][:access_token_secret])
    end
  end

  get "/" do
    if @access_token and @user = get_user(@access_token)
      haml :info
    else
      haml :index
    end
  end

  get "/request" do
    @request_token = @consumer.get_request_token(:oauth_callback => "#{request.scheme}://#{request.host}:#{request.port}/auth")
    session[:oauth][:request_token] = @request_token.token
    session[:oauth][:request_token_secret] = @request_token.secret
    redirect @request_token.authorize_url
  end

  get "/auth" do
    @access_token = @request_token.get_access_token :oauth_verifier => params[:oauth_verifier]
    session[:oauth][:access_token] = @access_token.token
    session[:oauth][:access_token_secret] = @access_token.secret

    user = get_user(@access_token) || { email: get_email(@access_token) }

    user["token"]        = @access_token.token
    user["token_secret"] = @access_token.secret
    @db.save_doc(user)

    redirect "/"
  end

  get "/logout" do
    session[:oauth] = {}
    redirect "/"
  end

  helpers do
    def get_user(access_token)
      user = @db.view('user/email_from_token', key: access_token.token)
      if user['rows'].any? and user['rows'].first['value']['token_secret'] == access_token.secret
        STDOUT.puts "Email read from CouchDB"
        return user['rows'].first['value']
      end
      nil
    end

    def get_email(access_token)
      STDOUT.puts "Email queried from google"
      response = access_token.get('https://www.googleapis.com/userinfo/email?alt=json')
      if response.is_a?(Net::HTTPSuccess)
        Yajl.load(response.body)['data']['email']
      else
        STDERR.puts "could not get email: #{response.inspect}"
        nil
      end
    end
  end
end
