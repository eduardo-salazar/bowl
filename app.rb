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
    
    arr_friends.push(*fb.my_friends)
    
    fb.to_neo4j
    # fb = FacebookAPI.new(token)


    # # Get list of friends
    # friends = fb.my_friends
    # friends.each do |friend|
    #   new_person = Person.new
    #   new_person.id = friend["id"]
    #   new_person.name = friend["name"]
    #   new_person.img = friend["picture"]["data"]["url"]
    #   arr_friends << new_person
    #   puts new_person.to_json
    # end


    # # Getting me Object
    # me_data = fb.me
    # me.id = me_data["id"]
    # me.name = me_data["name"]
    
    # # Getting mutual friends
    # puts 'testing mutual'
    # humberto_mutual = fb.mutual_friends('100010454044190')
    # puts 'Humbero mutual friends'
    # puts humberto_mutual
  end

  get '/auth/:provider/callback' do
    content_type 'application/json'
    cookies = MultiJson.encode(request.env)
    token = JSON.parse(cookies)["omniauth.auth"]["credentials"]["token"]
    redirect "/socialnetwork?token=#{token}"
  end

end