require 'koala'
class FacebookAPI
	APP_ID = '1585877488392822'
	APP_SECRET = '842ac938f5cab333b09cacf7fa769e83'

	def initialize(token)
		@oauth_access_token ||= token
	end

	def me
		@graph ||= Koala::Facebook::API.new(oauth_access_token) # 1.2beta and beyond
		@graph.get_object("me")
	end

	def my_friends
		@graph ||= Koala::Facebook::API.new(oauth_access_token) # 1.2beta and beyond
		@graph.get_connections("me", "invitable_friends?limit=1000")
	end

	def mutual_friends(friend_id)
		#@graph.get_connections("me", "mutual_friends/#{friend_id}")
		@graph.get_object("#{friend_id}", {fields: ["context.fields(all_mutual_friends)"]})
		#@graph.get_object("#{friend_id}", {fields: ["context"]}) 
	end

	def get(friend)
		@graph ||= Koala::Facebook::API.new(oauth_access_token) # 1.2beta and beyond
		@graph.get_object("#{friend}")
	end

	def search(friend_name)
		@graph ||= Koala::Facebook::API.new(oauth_access_token) # 1.2beta and beyond
		@graph.get_connection('search', "q=Oscar&type=user")
	end

	def to_json
	end

	def oauth_access_token
		@oauth_access_token
	end


end