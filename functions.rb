require_relative 'printers.rb'
require_relative 'generate.rb'
require 'highline/import'

module Pupper
	## This function will take the ID of a post, use the API to retrieve it, and then save the article using generate
	def self.save(id, articles, client)
		# Declare all variables + access data required for html generation
		data = self.topic(client, id)
		username = data["post_stream"]["posts"][0]["username"]
		cooked = data["post_stream"]["posts"][0]["cooked"]
		title = data["title"]
		filename = data["slug"] + ".html"
		if ! articles.return().include?(filename)
		# Does all the heavy lifting
			articles.add(filename)
			Pupper.generate(title, cooked, filename)
		else
			puts "Already downloaded!"
		end
	end

	## This function uses the API to retrieve and output the articles infomation
	def self.topic(client, id = 0)

		puts "You have to actually supply an ID..." if id == 0

		begin
			post_data_raw = client.topic(id)
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

	def self.search(client)
		print "What would you like to search for kind sir?\n>> "
		query = gets.chomp
		if query != ""
			begin
				data = client.search(query)
			rescue
				puts "Something went wrong."
			else
				Pupper.print_posts(data["posts"], client)
			end
		end
	end

	def self.user_topics(client)
		print "Who's articles would you like to search for sir?\n>> "
		query = gets.chomp
		if query != ""
			begin
				data = client.topics_by(query)
			rescue
				puts "Something went wrong."
			else
				Pupper.print_user_topics(data, client)
			end
		end
	end

	def self.snapshot(client, articles)
		data = client.latest_topics()
		for topic in data
			self.save(topic["id"], articles, client)
		end
	end

	def self.latest(client)
		data = client.latest_topics()
		Pupper.print_topics(data, client)
	end


	def self.downloads(articles)
		for article in articles.return()
			puts articles.return().index(article).to_s + ". " + article
		end
	end

	def self.prompt(articles, client)
		print "ID >> "
		id = gets.chomp
		if id != ""
			self.save(id, articles, client)
			say("Press enter to return to the main menu")
			gets.chomp
		end
	end

end
