require 'koala'
class FacebookAPI
	attr_accessor :oauth_access_token
	APP_ID = '1585877488392822'
	APP_SECRET = '842ac938f5cab333b09cacf7fa769e83'


	def initialize(cookies)
		@oauth ||= Koala::Facebook::OAuth.new(APP_ID, APP_SECRET)
		values = @oauth.get_user_info_from_cookies(cookies)
		oauth_access_token = 'asfasdfasdfsd'
	end

	def my_friends
		@graph = Koala::Facebook::API.new(oauth_access_token)
	end


end