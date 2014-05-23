require_relative '../main'
require 'rack/test'
require 'rspec'

ENV['RACK_ENV'] = 'test'

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false


RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end
