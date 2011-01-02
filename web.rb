require 'sinatra/base'
require 'haml'

class ZomgInboxWeb < Sinatra::Base
  get "/" do
    haml :index
  end
end
