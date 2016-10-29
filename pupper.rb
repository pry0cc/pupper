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
		File.open("articles/" + output, "w") { |file| file.write(result) }
		puts "[+] File saved to articles/" + output
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

def search()
	puts "What would you like to search for kind sir?"
	print ">> "
	query = gets.chomp
	begin
		data = @client.search(query)
	rescue
		puts "Something went wrong."
	else
		posts = data["posts"]
		printf "%-5s %-15s %-20s\n", "ID", "Username", "Title"
		for post in posts
			post_data_raw = @client.topic(post["topic_id"])
			post_data = post_data_raw["post_stream"]["posts"][0]
			# puts JSON.generate(post_data)
			printf "%-5s %-15s %-20s\n", post["topic_id"].to_s, post_data["username"], post_data_raw["title"]
		end
		puts "Which would you like to save? (id)"
		print ">> "
		topic_id_to_save = gets.chomp
		save(topic_id_to_save)
	end
end

trap "SIGINT" do
	puts ""
  puts "Bye Bye"
  exit
end

loop {
	puts "Welcome to Pupper - Official 0x00sec Download Tool"
	puts "Name courtesy of oaktree"
	puts "Software concieved by pry0cc"
	puts ""

	choose do |menu|
		menu.prompt = "Pick an option, any option..."

		menu.choice(:Search) {
			say("Alright Mr Searchy Pants...")
			search()
			say("Press enter to return to the main menu")
			gets.chomp
			system("clear")
		}
		menu.choice(:Topic) {
			say("Please gimme a Topic ID then...")
			print ">> "
			id = gets.chomp
			puts id
			save(id)
		}
	end
}
