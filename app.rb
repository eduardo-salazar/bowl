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
    
    facebook_sn_extraction(params["email"],params["password"])
    
  end

  # This method is linked to pusher to create a better user experience
  def facebook_sn_extraction(email, password)
    fb = FacebookScapper.new(email, password)
    fb.authenticate
    me = fb.me
    i = 1
    friends = fb.my_friends
    friends_count = friends.size
    friends = friends.map do |p| 
      puts "Element #{i}/#{friends_count}"
      i += 1
      if i <= 1
        p.mutual_friends = mutual_friends p.id, p.name 
      else
        p.mutual_friends = Array.new
      end
      Pusher.trigger("sn_#{me.id}", 'update', {message: "#{i}/#{friends_count} - Mutual Friend with #{p.name} (#{p.mutual_friends})", progress:  (i/friends_count)*100 })
      p
    end
    
    generate_files(me,friends)
  end

  def generate_files(me, friends)
    script = "
    //---------------------------- <br/>
     Summary of extraction <br/>
     User id: #{me.id} <br/>
     Users name: #{me.name} <br/>
     User profile: <a href='#{me.link}'>#{me.link}</a> <br/>
     Total Friends: #{friends.size} <br/>
     Generated by: Baby Owl - https://github.com/eduardo-salazar/bowl <br/>
    //---------------------------- <br/>"


    CSV.open(File.expand_path("../../public/#{me.id}_nodes.csv", __FILE__), "wb") do |csv|
      csv << ["id","name","link"]
      csv << [me.id,me.name,me.link]
      friends.map do |person|
        csv << [person.id,person.name,person.link]
      end
    end

    CSV.open(File.expand_path("../../public/#{me.id}_edges.csv", __FILE__), "wb") do |csv|
      csv << ["source","source_name","target","target_name"]
      friends.map do |person|
        csv << [me.id,me.name,person.id,person.name]
      end
      friends.map do |person|
        person.mutual_friends.map do |mutual|
          csv << [person.id,person.name,mutual.id,mutual.name]
        end
      end
    end

    # CSV.open("../public/#{@me.id}_indirect.csv", "wb") do |csv|
    #   csv << ["source","source_name","target","target_name"]
      
    # end

    script += "// How to create your social network in Neo4j <br/>"
    script += "/1. Download the files <br/>"
    script += "/1.1 <a href='/#{me.id}_nodes.csv'>Nodes</a> <br/>"
    script += "/1.1 <a href='/#{me.id}_edges.csv'>Edges</a> <br/><br/>"
    script += "/2. Use the next commands to import"
    script += "/2.1. Import all your friend nodes. (provide_path = file://../Download/1174335342_people.csv)"   
    script += "LOAD CSV WITH HEADERS FROM '[provide_path]' AS csvLine
      CREATE (p:Person { id: toInt(csvLine.id), name: csvLine.name , link: csvLine.link}) "

    script += "// 2.2. Create Link to your friends. (provide_path = file://../Download/1174335342_people.csv)"    

    script
  end

  get '/auth/:provider/callback' do
    content_type 'application/json'
    cookies = MultiJson.encode(request.env)
    token = JSON.parse(cookies)["omniauth.auth"]["credentials"]["token"]
    redirect "/socialnetwork?token=#{token}"
  end

end