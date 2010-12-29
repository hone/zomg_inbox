web       bundle exec thin start
worker    bundle exec rake resque:work VERBOSE=* --trace
scheduler bundle exec clockwork ./clock.rb
