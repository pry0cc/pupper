#!/usr/bin/env ruby

require 'erb'

# title = ""
# cooked = ""

def generate(title, cooked)
	@title = title
	@cooked = cooked
	template = File.open("post.html", "r").read()
	renderer = ERB.new(template)
	puts renderer.result()
end

generate("hello!", "cooked!")
