require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.default_driver = :poltergeist
Capybara.run_server = false

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs_options: ['--load-images=false', '--disk-cache=false'])
end

class FacebookScapper
	include Capybara::DSL
	HOST = "https://www.facebook.com"
	LOGIN_URL = "/login.php?login_attempt=1&lwv=110"
	FRIENDS_URL = "/friends?source_ref=pb_friends_tl"

	def initialize(username, user_pass)
		@email = username
		@password = user_pass
	end

	def authenticate
		visit(HOST + LOGIN_URL)
		fill_in "email", with: @email
		fill_in "pass", with: @password
		find('button[name="login"]').click
	end

	def me
		if @me == nil
			visit(HOST)
			find("a[title='Profile']").click
			@me = Person.new
			@me.name = find("span[id='fb-timeline-cover-name']").text
			@me.link = HOST + current_path
			puts 'Person me'
			puts @me.to_json
		end
		@me
	end

	def my_friends
		visit(me.link + FRIENDS_URL)
		friend_number = find("a[name='All Friends']").find('span:nth-of-type(2)').text
		puts "Total number of friends #{friend_number}"
		friends_cards = find_all("ul[data-pnref='friends'] > li")
		puts "Elements found #{friends_cards.size}"
		# scroll_exist = find_all("img[class*='async_saving']")
		# puts 'Invented element'
		# puts scroll_exist.size
		end_friends = find_all(".uiHeaderTitle")
		until end_friends.size > 1 do
			page.execute_script "window.scrollBy(0,10000)"
			sleep 0.5
			end_friends = find_all(".uiHeaderTitle")
			friends_cards = find_all("ul[data-pnref='friends'] > li")
			puts "Elements found #{friends_cards.size} - #{end_friends.size}"
		end

	end

	def mutual_friends(friend_id)
	end

	def get(friend)
	end

	def search(friend_name)
	end

	def agent
		@agent
	end

end
