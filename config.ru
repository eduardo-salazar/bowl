require './app.rb'
require 'omniauth-facebook'
require 'figaro'

APP_ID = '1585877488392822'
APP_SECRET = '842ac938f5cab333b09cacf7fa769e83'

use Rack::Session::Cookie, :secret => 'abc123'

use OmniAuth::Builder do
  provider :facebook, APP_ID, APP_SECRET, :scope => 'email,user_friends'
end

run BabyOwlAPI