require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'csv'
require 'pusher'

Capybara.default_driver = :poltergeist
Capybara.run_server = false

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, { phantomjs_options: ['--load-images=false', '--disk-cache=false'] , timeout: 1000})
end

class FacebookScapper
	include Capybara::DSL
	HOST = "https://www.facebook.com"
	LOGIN_URL = "/https://www.facebook.com"
	FRIENDS_URL = "/friends?source_ref=pb_friends_tl"
	MUTUAL_URL = "/friends_mutual"

	def initialize(username, user_pass)
		Capybara.reset_sessions!
		@email = username
		@password = user_pass
	end

	def authenticate
		visit(HOST + LOGIN_URL)
		fill_in "email", with: @email
		fill_in "pass", with: @password
		find('#loginbutton').click
	end

	def me
		if @me == nil
			visit(HOST)
			find("a[title='Profile']").click
			@me = Person.new
			@me.id = JSON(find("#pagelet_timeline_main_column")['data-gt'])["profile_owner"]
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
		friends_cards = find_all("ul[data-pnref='friends'] > li")
		end_friends = find_all(".uiHeaderTitle")
		until end_friends.size > 1 do
			page.execute_script "window.scrollBy(0,10000)"
			sleep 0.5
			end_friends = find_all(".uiHeaderTitle")
			friends_cards = find_all("ul[data-pnref='friends'] > li")
		end
		puts "Friends found #{friends_cards.size}"
		@friends = parse_cards(friends_cards)
	end

	def parse_cards(cards)
		cards.map do |element|
			p = Person.new
			p.id = element.find("[data-flloc='profile_browser']")['data-profileid']
			p.name = element.find('.fcb > a').text
			p.link = element.find('.fcb > a')['href']
			p
		end
	end

	def mutual_friends(friend_id, friend_name)
		visit(HOST + '/' + friend_id + MUTUAL_URL)
		begin
			friend_number = find("a[name='Mutual Friends']").find('span:nth-of-type(2)').text
			friends_cards = find_all("ul[data-pnref='friends'] > li")
			end_friends = find_all(".uiHeaderTitle", :text => "More About #{friend_name}")
			until end_friends.size > 0 do
				page.execute_script "window.scrollBy(0,10000)"
				sleep 0.5
				end_friends = find_all(".uiHeaderTitle", :text => "More About #{friend_name}")
				friends_cards = find_all("ul[data-pnref='friends'] > li")
				puts "Mutual friends found #{friends_cards.size}"
			end
			puts "Mutual friends with #{friend_name} = #{friends_cards.size}"
			parse_cards friends_cards
		rescue Capybara::ElementNotFound => e
			puts "Mutual friends with #{friend_name} = 0"
			Array.new
		end
	end

	def get(friend)
	end

	def search(friend_name)
	end

	def agent
		@agent
	end

end
