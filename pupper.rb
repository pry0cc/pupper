#!/usr/bin/env ruby
require 'discourse_api'
require 'highline/import'
require 'json'
require 'erb'

@client = DiscourseApi::Client.new("https://0x00sec.org/")

def generate(title, cooked, output)
		@title = title
		@cooked = cooked
		cooked = "hello!"
		template = File.open("template/post.html", "r").read()
		result = ERB.new(template).result()
		File.open("template/" + output, "w") { |file| file.write(result) }
end

def save(id)
	data = topic(id)
	username = data["post_stream"]["posts"][0]["username"]
	cooked = data["post_stream"]["posts"][0]["cooked"]
	title = data["title"]
	filename = data["slug"] + ".html"
	generate(title, cooked, filename)

end

def topic(id = 0)
	if id == 0
		puts "Hello there! Whats the ID you were looking for?"
		print ">> "
		id = gets.chomp
		begin
			post_data_raw = @client.topic(id)
		rescue
			puts "Hmm. Doesn\'t seem to exist"
		else
			post_data = post_data_raw["post_stream"]["posts"][0]
			if post_data_raw.length > 0
				puts "Found something!"
				printf "%-5s %-15s %-20s\n", id.to_s, post_data["username"], post_data_raw["title"]
			else
				puts "Hm. Nothing..."
			end
		end
	else
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

puts "Welcome to Pupper - Official 0x00sec Download Tool"
puts "Name courtesy of oaktree"
puts "Software concieved by pry0cc"
puts ""
loop {
	choose do |menu|
		menu.prompt = "Pick an option, any option..."

		menu.choice(:Search) {
			say("Alright Mr Searchy Pants...")
			search()
		}
		menu.choice(:Topic) {
			say("Woah, you really know what you want")
			topic()
		}

		menu.choice(:Save) {
			say("Hell0!")
			save(991)
		}
	end
}
