require 'koala'
class FacebookAPI
	attr_accessor :me
	APP_ID = '1585877488392822'
	APP_SECRET = '842ac938f5cab333b09cacf7fa769e83'


	def initialize(cookies)
		parse cookies
	end

	def my_friends
		@graph = Koala::Facebook::API.new(oauth_access_token)
	end

	def mutual_friends
	end

	def to_json
	end

	def parse(cookies)
		data = JSON.parse(cookies)
		@oauth_access_token = data["omniauth.auth"]["credentials"]["token"]
	end

	def oauth_access_token
		@oauth_access_token
	end


end