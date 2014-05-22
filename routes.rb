require 'sinatra'
require './models/rubadi'
require 'erubis'

get '/campaigns/:campaign_id' do
  model = Rubadi.new params[:campaign_id], Time.now.min
  banners = model.get_banners.collect { |banner|
    url "/images/image_#{banner}.png" }
  erb :index, :locals => {:banners => banners}
end
