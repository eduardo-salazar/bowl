require 'koala'
class FacebookAPI
	attr_accessor :me
	APP_ID = '1585877488392822'
	APP_SECRET = '842ac938f5cab333b09cacf7fa769e83'

	def initialize(token)
		@oauth_access_token ||= token
	end

	def my_friends
		@graph ||= Koala::Facebook::API.new(oauth_access_token) # 1.2beta and beyond
		@graph.get_connections("me", "invitable_friends?limit=1000")
	end

	def mutual_friends(friend_id)
		@graph.get_connections("me", "mutualfriends/#{friend_id}")
	end

	def to_json
	end

	def oauth_access_token
		@oauth_access_token
	end


end