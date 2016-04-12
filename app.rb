require 'sinatra'
require 'json'
require_relative 'models/person.rb'
require_relative 'controllers/facebook_api.rb'
require 'logger'



# Configuration Sharing Web Service
class BabyOwlAPI < Sinatra::Base
  enable  :sessions, :logging
  set :public_folder, File.expand_path('../public', __FILE__)

  @fb = nil

  get '/?' do
    'BabyOwl web service is up and running at /api/v1'
    erb :index
  end

  get '/socialnetwork' do
    puts 'Receiving token'
    token = params['token']
    fb = FacebookAPI.new(token)
  end

  get '/auth/:provider/callback' do
    content_type 'application/json'
    cookies = MultiJson.encode(request.env)
    token = JSON.parse(cookies)["omniauth.auth"]["credentials"]["token"]
    redirect "/socialnetwork?token=#{token}"
  end

end