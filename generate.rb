require 'erb'
require 'launchy'
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'base64'

module Pupper
	## Function to take the data from the article, and render it in a html file
	def self.generate(title, cooked, output, category)
		# Create 'scope' accessible variables (needed for ERB)
		$title = title
		$cooked = cooked.gsub('img src="//','img src="https://')

		# Import the post.html template file (its an ERB really)
		template = File.open("post.erb", "r").read()

		# Render the post.html ERB
		result = ERB.new(template).result()
		html = Nokogiri::HTML(result)
		images = html.css("img")

		for image in images
			base64 = Base64.encode64(open(image["src"]).read())
			image["src"] = "data:image/jpg;base64," + base64
		end

		localfied = html.to_html
		Dir.mkdir("articles/" + category) unless File.exists?("articles/" + category)
		# Save it to a new file in templates
		File.open("articles/" + category + "/" + output, "w") { |file| file.write(localfied) }
		puts "[+] File saved to articles/" + category + "/" + output

	end

	def self.generate_menu(articles)
		articles_hash = {}
		for article in articles.return()
			parts = article.split("/")
			category = parts[0]
			filename = parts[1]
			
			if ! articles_hash.has_key? category
				articles_hash[category] = []
			end

			articles_hash[category].push(filename)
		end
		$title = "0x00sec Offline"
		$body = ""
		articles_hash.each do |key, array|
			$body += "<h2>" + key + "</h2>\n"
			for article in array
				$body += "<a href='" + key + "/" + article +"'>" + article + "</a><br>\n"
			end
		end
		
		template = File.open("menu.erb", "r").read()
		result = ERB.new(template).result()
		File.open("articles/index.html", "w") { |file| file.write(result) }
		puts "[+] Saved Menu"
	end
end
