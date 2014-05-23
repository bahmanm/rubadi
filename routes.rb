require 'sinatra'
require 'erubis'
require_relative 'models/rubadi'

get '/campaigns/:campaign_id' do
  campaign_id = params[:campaign_id]
  if campaign_id[/^\d+$/] and not campaign_id.to_i.zero?
    model = Rubadi.new campaign_id, Time.now.min
    if model.valid_campaign
      banner_id = model.get_banner
      model.save_impression banner_id
      erb :index, :locals => {:banner => url("/images/image_#{banner_id}.png") }
    else
      status 404
    end
  else
    status 404
  end
end

