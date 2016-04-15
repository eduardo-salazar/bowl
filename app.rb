require 'sinatra'
require 'json'
require_relative 'models/person.rb'
#require_relative 'controllers/facebook_api.rb'
require_relative 'controllers/facebook_scrapper.rb'
require 'logger'
require_relative 'config/environments'



# Configuration Sharing Web Service
class BabyOwlAPI < Sinatra::Base
  enable  :sessions, :logging
  set :public_folder, File.expand_path('../public', __FILE__)


  get '/?' do
    'BabyOwl web service is up and running at /api/v1'
    erb :index
  end

  post '/socialnetwork' do
    token = params['token']
    puts params
    facebook_sn_extraction(params["email"],params["password"],params["uid"])
    
  end

  # This method is linked to pusher to create a better user experience
  def facebook_sn_extraction(email, password, uID)
     pusher_client = Pusher::Client.new(
      app_id: ENV['pusher_app_id'],
      key: ENV['pusher_key'],
      secret: ENV['pusher_secret'],
      encrypted: true
    )

    fb = FacebookScapper.new(email, password)
    fb.authenticate
    me = fb.me
    
    pusher_client.trigger("sn_#{uID}", 'update', {message: "Getting list of friends for id #{me.id} (#{me.name})", progress:  1 })
    friends = fb.my_friends
    friends_count = friends.size
    puts "Total Friends found #{friends_count}"
    pusher_client.trigger("sn_#{uID}", 'update', {message: "Total Friends found #{friends_count}", progress:  1 })
    i = 0
    friends = friends.map do |p| 
      puts "Element #{i}/#{friends_count}"
      i += 1
      if i <= 3
        p.mutual_friends = fb.mutual_friends p.id, p.name 
      else
        p.mutual_friends = Array.new
      end
      puts "#{i}/#{friends_count} - Mutual Friend with #{p.name} (#{p.mutual_friends.size})"
      progress = Integer(i)/ Integer(friends_count) * 100 - 1
      progress = (progress < 0 ) ? 0 : progress 
      pusher_client.trigger("sn_#{uID}", 'update', {message: "#{sprintf('%.2f', progress)} % #{i}/#{friends_count} - Mutual Friend with #{p.name} (#{p.mutual_friends.size})", progress:  (i/friends_count)*100 })
      p
    end
    
    pusher_client.trigger("sn_#{uID}", 'update', {message: "99 % Generating files......", progress:  99 })
    output = generate_files(me,friends)
    pusher_client.trigger("sn_#{uID}", 'update', {message: "100 % Process complete.....", progress:  (i/friends_count)*100 })
    output
  end

  def generate_files(me, friends)
    script = "
    //----------------------------------------------------------- <br/>
     Summary of extraction <br/>
     User id: #{me.id} <br/>
     Users name: #{me.name} <br/>
     User profile: <a href='#{me.link}'>#{me.link}</a> <br/>
     Total Friends: #{friends.size} <br/>
     Generated by: Baby Owl - https://github.com/eduardo-salazar/bowl <br/>
     Generated date: #{Time.now.to_s}
    //------------------------------------------------------------ <br/>"


    CSV.open(File.expand_path("../public/exports/#{me.id}_nodes.csv", __FILE__), "wb") do |csv|
      csv << ["id","name","link"]
      csv << [me.id,me.name,me.link]
      friends.map do |person|
        csv << [person.id,person.name,person.link]
      end
    end

    CSV.open(File.expand_path("../public/exports/#{me.id}_edges.csv", __FILE__), "wb") do |csv|
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

    script += "// How to create your social network in Gephi: <br/>"
    script += "/ 1. Download the files <br/>"
    script += "/    1.1 <a href='/#{me.id}_nodes.csv'>Nodes</a> <br/>"
    script += "/    1.2 <a href='/#{me.id}_edges.csv'>Edges</a> <br/><br/>"
    script += "/ 2. Open Gephi (<a href='https://gephi.org/'>https://gephi.org/</a>) <br/>"
    script += "/ 3. Import csv files (nodes, edges) from File -> Import spreadsheet <br/>"
    script += "/    Note: Make sure nodes.csv is imported as Nodes tables and edges.csv as Edges table <br/>"
    script
  end

  get '/auth/:provider/callback' do
    content_type 'application/json'
    cookies = MultiJson.encode(request.env)
    token = JSON.parse(cookies)["omniauth.auth"]["credentials"]["token"]
    redirect "/socialnetwork?token=#{token}"
  end

end