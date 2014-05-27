require 'sinatra'
require 'pg'
require 'connection_pool'
require 'redis'

require_relative 'routes'
require_relative 'models/rubadi'
require_relative 'config/database'
require_relative 'config/init'

# Initialise the connection pool
$conn = ConnectionPool.new(size: 20, timeout: 5) {
  PGconn.connect(
    :dbname => CONFIG_DBNAME,
    :user => CONFIG_DBUSER,
    :password => CONFIG_DBPWD,
    :host => CONFIG_DBHOST)
}
# Initialise Redis cache
$cache = Redis.new(:driver => :hiredis)
