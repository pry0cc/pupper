#!/usr/bin/env ruby
require 'discourse_api'
require 'highline/import'
require 'json'
require 'erb'
require 'launchy'

# Establishes a Discourse API Object with 0x00sec
@client = DiscourseApi::Client.new("https://0x00sec.org/")

## Function to take the data from the article, and render it in a html file
def generate(title, cooked, output)
	# Create 'scope' accessible variables (needed for ERB)
	@title = title
	@cooked = cooked.gsub('src="//','src="https://')

	# Import the post.html template file (its an ERB really)
	template = File.open("post.erb", "r").read()

	# Render the post.html ERB
	result = ERB.new(template).result()

	# Save it to a new file in templates
	File.open("articles/" + output, "w") { |file| file.write(result) }
	puts "[+] File saved to articles/" + output
end

class Articles
	def initialize(dir)
		@dir = dir
		filename = "articles.json"
		@filepath = @dir + "/" + filename

		FileUtils.mkdir_p(@dir) unless Dir.exists?(@dir)
		File.open(@filepath, "w") {|f| f.write('{"articles":[]}')} unless File.file?(@filepath)

		@farticles = File.open(@filepath).read()
		@articles = JSON.parse(@farticles)["articles"]
	end

	def return()
		return @articles
	end

	def save()
		tmp = {}
		tmp["articles"] = @articles

		File.open(@filepath, "w") {|f| f.write(JSON.generate(tmp)) }
	end

	def add(filename)
		@articles.push(filename)
		self.save()
	end

	def delete(filename)
		@articles.delete(filename)
		self.save()
		File.delete(@dir + "/" + filename)
		puts "[-] File Deleted"
	end
end

@articles = Articles.new("articles")

## This function will take the ID of a post, use the API to retrieve it, and then save the article using generate
def save(id)
	# Declare all variables + access data required for html generation
	data = topic(id)
	username = data["post_stream"]["posts"][0]["username"]
	cooked = data["post_stream"]["posts"][0]["cooked"]
	title = data["title"]
	filename = data["slug"] + ".html"

	# Does all the heavy lifting
	@articles.add(filename)
	generate(title, cooked, filename)
end


## This function uses the API to retrieve and output the articles infomation
def topic(id = 0)

	if id == 0
		puts "You have to actually supply an ID..."
	end

	begin
		post_data_raw = @client.topic(id)
	rescue
		puts "Hmm. Doesn\'t seem to exist"
	else
		if post_data_raw.length > 0
			return post_data_raw
		else
			puts "Hm. Nothing..."
		end
	end
end

def print_posts(posts)
	printf "%-5s %-15s %-20s\n", "ID", "Username", "Title"
	for post in posts
		post_data_raw = @client.topic(post["topic_id"])
		post_data = post_data_raw["post_stream"]["posts"][0]
		# puts JSON.generate(post_data)
		printf "%-5s %-15s %-20s\n", post["topic_id"].to_s, post_data["username"], post_data_raw["title"]
	end
end

def print_topics(topics)
	printf "%-5s %-15s %-20s\n", "ID", "Username", "Title"
	for topic in topics
		topic_data_raw = @client.topic(topic["id"])
		topic_data = topic_data_raw["post_stream"]["posts"][0]
		printf "%-5s %-15s %-20s\n", topic["id"].to_s, topic_data["username"], topic_data_raw["title"]
	end
end

def search()
	puts "What would you like to search for kind sir?"
	print ">> "
	query = gets.chomp
	if query != ""
		begin
			data = @client.search(query)
		rescue
			puts "Something went wrong."
		else
			print_posts(data["posts"])
		end
	end
end

def latest()
	data = @client.latest_topics()
	print_topics(data)
end

def downloads()
	for article in @articles.return()
		puts @articles.return().index(article).to_s + ". " + article
	end
end

def prompt()
	print "ID >> "
	id = gets.chomp
	if id != ""
		save(id)
		say("Press enter to return to the main menu")
		gets.chomp
	end
end
trap "SIGINT" do
	puts "\nBye Bye"
	exit
end

loop {
	puts "Welcome to Pupper - Official 0x00sec Download Tool"
	puts "Name courtesy of oaktree"
	puts "Software concieved by pry0cc\n"
	puts "Downloaded Articles: " + @articles.return().to_s

	choose do |menu|
		menu.prompt = "Pick an option, any option..."

		menu.choice(:Search) {
			system("clear")
			say("Alright Mr Searchy Pants...")
			search()
			prompt()
			system("clear")
		}
		menu.choice(:Topic) {
			system("clear")
			say("Please gimme a Topic ID then...")
			prompt()
			system("clear")
		}
		menu.choice(:Latest) {
			system("clear")
			say("Outputting Latest Topics")
			latest()
			prompt()
			system("clear")
		}
		menu.choice(:Read) {
			say("Downloaded Articles")
			downloads()
			print "ID >> "
			id = gets.chomp
			if id != "" && (@articles.return().length > 0) && (@articles.return().length > id.to_i)
				filename = @articles.return()[id.to_i]
				Launchy.open("articles" + "/" + filename)
				say("Press enter to return to the main menu")
				gets.chomp
			end
		}
		menu.choice(:Delete) {
			system("clear")
			say("Downloaded Articles")
			downloads()
			print "ID >> "
			id = gets.chomp
			if id != "" && (@articles.return().length > 0) && (@articles.return().length > id.to_i)
				@articles.delete(@articles.return()[id.to_i])
				say("Press enter to return to the main menu")
				gets.chomp
			elsif @articles.return.length == 0
				say("You don't have any downloaded mate.")
				say("Press enter to return to the main menu")
				gets.chomp
			end
			system("clear")
		}
	end
}