require 'sinatra'
require 'json'
require_relative 'models/person.rb'
require_relative 'controllers/facebook_api.rb'
require 'logger'



# Configuration Sharing Web Service
class BabyOwlAPI < Sinatra::Base
  enable  :sessions, :logging
  set :public_folder, File.expand_path('../public', __FILE__)

  get '/?' do
    'BabyOwl web service is up and running at /api/v1'
    erb :index
  end

  get '/socialnetwork' do
    fb = FacebookAPI.new(cookies)
    puts cookies
    puts "access toke = #{fb.oauth_access_token}"
  end

  get '/auth/:provider/callback' do
    content_type 'application/json'
    tt= MultiJson.encode(request.env)
    puts "values"
    puts tt
  end

end