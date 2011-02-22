require 'couchrest'

CONFIG ||= {}
CONFIG[:couchdb] = CouchRest.database!("#{ENV['CLOUDANT_URL']}/#{ENV['RACK_ENV']}")
