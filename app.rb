require 'sinatra'
require 'json'
require_relative 'models/person.rb'

# Configuration Sharing Web Service
class BabyOwlAPI < Sinatra::Base
  

  get '/?' do
    'BabyOwl web service is up and running at /api/v1'
  end

  get '/api/v1/?' do
    # TODO: show all routes as json with links
  end

  get '/api/v1/projects/?' do
    content_type 'application/json'

    JSON.pretty_generate(data: Project.all)
  end

end