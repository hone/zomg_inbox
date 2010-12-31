require 'rspec/core'

RSpec.configure do |config|
  config.mock_with ''
  config.run_all_when_everything_filtered = true
  config.filter_run :focused => true
  config.alias_example_to :fit, :focused => true
end
