require 'sinatra'
require 'sinatra/reloader' if development?
require 'pg'
require 'connection_pool'
require_relative 'routes'
require_relative 'models/import'
require_relative 'conf'

$conn = ConnectionPool.new(size: 20, timeout: 5) {
  PGconn.connect(
    :dbname => CONFIG_DBNAME,
    :user => CONFIG_DBUSER,
    :password => CONFIG_DBPWD,
    :host => CONFIG_DBHOST)
}

configure :development? do
  set :public_folder => File.dirname(__FILE__) + '/static'
  set :logging => true
end
