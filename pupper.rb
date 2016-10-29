#!/usr/bin/env ruby
require 'discourse_api'
require 'highline/import'
require 'json'
require 'erb'

# Establishes a Discourse API Object with 0x00sec
@client = DiscourseApi::Client.new("https://0x00sec.org/")

## Function to take the data from the article, and render it in a html file
def generate(title, cooked, output)
	# Create 'scope' accessible variables (needed for ERB)
	@title = title
	@cooked = cooked.sub('src="//','src="https://')

	# Import the post.html template file (its an ERB really)
	template = File.open("post.erb", "r").read()

	# Render the post.html ERB
	result = ERB.new(template).result()

	# Save it to a new file in templates
	FileUtils.mkdir_p("articles/") unless Dir.exists?("articles/")
	File.open("articles/" + output, "w") { |file| file.write(result) }
	puts "[+] File saved to articles/" + output
end

class Articles
	def initialize(dir)
		@dir = dir
		filename = "articles.json"
		@filepath = @dir + "/" + filename

		if ! File.file?(@filepath)
			File.open(@filepath, "w") {|f| f.write('{"articles":[]}') }
		end

		@articles = self.loadarticles()
		puts @articles
	end

	def loadarticles()
		farticles = File.open(@filepath).read()
		return JSON.parse(farticles)["articles"]
	end
end

## This function will take the ID of a post, use the API to retrieve it, and then save the article using generate
def save(id)
	# Declare all variables + access data required for html generation
	data = topic(id)
	username = data["post_stream"]["posts"][0]["username"]
	cooked = data["post_stream"]["posts"][0]["cooked"]
	title = data["title"]
	filename = data["slug"] + ".html"

	# Does all the heavy lifting
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
	begin
		data = @client.search(query)
	rescue
		puts "Something went wrong."
	else
		print_posts(data["posts"])
		puts "Which would you like to save? (id)"
		print ">> "
		topic_id_to_save = gets.chomp
		save(topic_id_to_save)
	end
end

def latest()
	data = @client.latest_topics()
	print_topics(data)
end

trap "SIGINT" do
	puts "\nBye Bye"
	exit
end

articles = Articles.new("articles")

loop {
	puts "Welcome to Pupper - Official 0x00sec Download Tool"
	puts "Name courtesy of oaktree"
	puts "Software concieved by pry0cc\n"

	choose do |menu|
		menu.prompt = "Pick an option, any option..."

		menu.choice(:Search) {
			system("clear")
			say("Alright Mr Searchy Pants...")
			search()
			say("Press enter to return to the main menu")
			gets.chomp
			system("clear")
		}
		menu.choice(:Topic) {
			system("clear")
			say("Please gimme a Topic ID then...")
			print ">> "
			id = gets.chomp
			save(id)
			say("Press enter to return to the main menu")
			gets.chomp
			system("clear")
		}
		menu.choice(:Latest) {
			system("clear")
			say("Outputting Latest Topics")
			latest()
			print "Topic ID >> "
			id = gets.chomp
			save(id)
			say("Press enter to return to the main menu")
			gets.chomp
			system("clear")
		}
	end
}
