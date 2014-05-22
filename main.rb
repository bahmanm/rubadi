require 'sinatra'
require 'sinatra/reloader' if development?
require 'pg'
require 'connection_pool'
require './routes'
require './models/import'

$conn = ConnectionPool.new(size: 20, timeout: 5) {
  PGconn.connect(
    :dbname => 'advidi',
    :user => 'advidi',
    :password => 'neig2ohS',
    :host => '127.0.0.1')
}

$conn.with do |conn|
  import = Import.new('/tmp/csv')
  import.do(conn)
end

configure :development? do
  set :public_folder => File.dirname(__FILE__) + '/static'
  set :logging => true
end
