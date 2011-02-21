require 'sinatra/base'
require 'haml'
require 'oauth'
require 'yajl'

class ZomgInboxWeb < Sinatra::Base
  enable :sessions

  before do
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
    if @access_token
      response = @access_token.get('https://www.googleapis.com/userinfo/email?alt=json')
      if response.is_a?(Net::HTTPSuccess)
        @email = Yajl.load(response.body)['data']['email']
      else
        STDERR.puts "could not get email: #{response.inspect}"
      end
      haml :info
    else
      haml :index
    end
  end

  get "/request" do
    STDOUT.puts "#{request.scheme}://#{request.host}:#{request.port}/auth"
    @request_token = @consumer.get_request_token(:oauth_callback => "#{request.scheme}://#{request.host}:#{request.port}/auth")
    session[:oauth][:request_token] = @request_token.token
    session[:oauth][:request_token_secret] = @request_token.secret
    redirect @request_token.authorize_url
  end

  get "/auth" do
    @access_token = @request_token.get_access_token :oauth_verifier => params[:oauth_verifier]
    session[:oauth][:access_token] = @access_token.token
    session[:oauth][:access_token_secret] = @access_token.secret
    redirect "/"
  end

  get "/logout" do
    session[:oauth] = {}
    redirect "/"
  end
end
