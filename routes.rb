require 'sinatra'
require_relative 'models/rubadi'

get '/campaigns/:campaign_id' do
  campaign_id = params[:campaign_id].to_i
  model = Rubadi.new campaign_id, Time.now.min
  if model.valid_campaign then
    banner_id = model.get_banner
    model.save_impression banner_id
    "<img src='#{url "/images/image_#{banner_id}.png"}'>"
  else
    ''
  end
end
