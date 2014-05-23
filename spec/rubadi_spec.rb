require_relative 'spec_helper'
require 'sinatra'

describe 'Rubadi' do

  def app
    @app ||= Sinatra::Application
  end

  VALID_CAMPAIGN_IDS = Array(1..50)
  INVALID_CAMPAIGN_IDS = Array(51..300)

  it 'should return 404 for invalid campaigns' do
    get "/campaigns/#{(INVALID_CAMPAIGN_IDS.shuffle)[0]}"
    last_response.status.should eq(404)
  end

  it 'should return banner link for valid campaigns' do
    get "/campaigns/#{(VALID_CAMPAIGN_IDS.shuffle)[0]}"
    last_response.should be_ok
    last_response.body.should include 'images'
  end

  it 'should not return duplicate images for valid campaigns' do
    get "/campaigns/#{(VALID_CAMPAIGN_IDS.shuffle)[0]}"
    resp1 = last_response.body
    get "/campaigns/#{(VALID_CAMPAIGN_IDS.shuffle)[0]}"
    resp2 = last_response.body
    get "/campaigns/#{(VALID_CAMPAIGN_IDS.shuffle)[0]}"
    resp3 = last_response.body
    resp1.should_not eq(resp2) or resp1.should_not eq(resp3)
  end

  it 'should return 404 for non-numeric campaigns' do
    get "/campaigns/index.html"
    last_response.status.should eq(404)
  end

  it 'should return 404 for any URL not for "campaigns" resource' do
    get '/foobar'
    last_response.status.should eq(404)
  end

end
