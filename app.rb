require 'sinatra'
require 'json'
require_relative 'models/person.rb'
#require_relative 'controllers/facebook_api.rb'
require_relative 'controllers/facebook_scrapper.rb'
require 'logger'
require 'pusher'



# Configuration Sharing Web Service
class BabyOwlAPI < Sinatra::Base
  enable  :sessions, :logging
  set :public_folder, File.expand_path('../public', __FILE__)

  pusher_client = Pusher::Client.new(
      app_id: ENV['pusher_app_id'],
      key: ENV['pusher_key'],
      secret: ENV['pusher_secret'],
      encrypted: true
    )

  get '/?' do
    'BabyOwl web service is up and running at /api/v1'
    erb :index
  end

  post '/socialnetwork' do
    token = params['token']
    arr_friends = Array.new
    me = Person.new

    fb = FacebookScapper.new(params["email"],params["password"])
    puts 'params'
    puts params

    fb.authenticate
    me = fb.me
    fb.to_neo4j
  end

  # This method is linked to pusher to create a better user experience
  def facebook_sn_extraction
    fb = FacebookScapper.new(email, password)
    fb.authenticate
    fb.me
    fb.to_neo4j
  end

  get '/auth/:provider/callback' do
    content_type 'application/json'
    cookies = MultiJson.encode(request.env)
    token = JSON.parse(cookies)["omniauth.auth"]["credentials"]["token"]
    redirect "/socialnetwork?token=#{token}"
  end

end