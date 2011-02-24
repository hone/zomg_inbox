web:       bundle exec thin -p $PORT -e $RACK_ENV start 
worker:    bundle exec rake resque:work VERBOSE=* --trace
scheduler: bundle exec clockwork ./clock.rb
