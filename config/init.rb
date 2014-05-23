require 'sinatra/reloader' if development?

configure :development? do
  set :public_folder => File.dirname(__FILE__) + '/../static'
  set :logging => true
end
