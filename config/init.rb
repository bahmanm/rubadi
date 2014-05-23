require 'sinatra/reloader' if development?

before do
  logger           = Logger.new(STDOUT)
  logger.level     = Logger::INFO
end

configure :development? do
  set :public_folder => File.dirname(__FILE__) + '/../static'
end
