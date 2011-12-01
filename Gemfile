source :rubygems

gem "mail"
# gem "resque", "1.15.0"
gem "resque", :github => 'hone/resque', :branch => 'heroku'
gem "rake"
gem "clockwork"
gem "warden-googleapps"
gem "sinatra"
gem "haml"
gem "oauth"
gem "yajl-ruby", :require => 'yajl'
gem "couchrest"
gem "gmail_xoauth"

group :production do
  gem "thin"
end

group :development do
  gem 'rspec-core',        '2.3.0'
  gem 'rspec-expectations', '2.3.0'
  gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'shotgun'
end
