web:       bundle exec thin -p $PORT start
worker:    rake resque:work VERBOSE=* --trace
scheduler: bundle exec clockwork ./clock.rb
