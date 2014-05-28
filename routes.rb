require 'sinatra'
require 'erubis'
require_relative 'models/rubadi'

get '/campaigns/:campaign_id' do
  campaign_id = params[:campaign_id]
  if campaign_id[/^\d+$/] and not campaign_id.to_i.zero?
    model = Model::Rubadi.new campaign_id, Time.now.min
    cache = Model::Cache.new
    if model.valid_campaign
      key = build_key(request, campaign_id)
      visited = cache.get key
      banner_id = model.get_banner exclude=visited
      cache.set key, banner_id
      model.save_impression banner_id
      erb :index, :locals => {:banner => url("/images/image_#{banner_id}.png") }
    else
      status 404
    end
  else
    status 404
  end
end

# Builds a key to store the banner_id in cache.
# Params:
# +request+: HTTP request
# +campaing_id+: campaign_id
def build_key(request, campaign_id)
  "#{request.host}__#{request.ip}__#{request.user_agent}__#{campaign_id}"
end
