require 'sinatra'
require './models/rubadi'
require 'erubis'

get '/campaigns/:campaign_id' do
  campaign_id = params[:campaign_id].to_i
  model = Rubadi.new campaign_id, Time.now.min
  banner = url "/images/image_#{model.get_banner}.png"
  erb :index, :locals => {:banner => banner}
end
