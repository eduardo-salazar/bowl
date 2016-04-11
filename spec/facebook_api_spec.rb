require_relative '../controllers/facebook_api.rb'
require 'minites/autorun'
require 'yaml'

fb = YAML.load_file 'spec/test_access_token.yml'

describe 'Test Facebook API' do
  it 'should return a friend list grated than one' do
    fb['facebook']['access_token'].each do |access_token|
			fb = FacebookAPI.new(access_token)
			fb.my_friends.size.must_be > 0
		end
	end
end
