require 'sinatra/reloader' if development?

before do
  logger.datetime_format = "%Y/%m/%d %H:%M:%S "
  logger.level = Logger::WARN
end

configure :development? do
  set :public_folder => File.dirname(__FILE__) + '/../static'
end
