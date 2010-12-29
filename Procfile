web       bundle exec thin start
worker    rake resque:work VERBOSE=* --trace
scheduler bundle exec clockwork ./clock.rb
