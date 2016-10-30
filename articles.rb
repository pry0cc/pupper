require 'json'
module Pupper
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
end
