require 'erb'
require 'launchy'
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'base64'

module Pupper
	## Function to take the data from the article, and render it in a html file
	def self.generate(title, cooked, output)
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

		# Save it to a new file in templates
		File.open("articles/" + output, "w") { |file| file.write(localfied) }
		puts "[+] File saved to articles/" + output

	end
end
