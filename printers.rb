module Pupper
	def self.print_posts(posts, client)
		$post_buffer = []
		printf "%-5s %-15s %-20s\n", "ID", "Username", "Title"
		printf "-" * 65 + "\n"
		for post in posts
			$post_buffer.push(post["topic_id"])
			post_data_raw = client.topic(post["topic_id"])
			post_data = post_data_raw["post_stream"]["posts"][0]
			# puts JSON.generate(post_data)
			printf "%-5s %-15s %-20s\n", post["topic_id"].to_s, post_data["username"], post_data_raw["title"]
		end
	end

	def self.print_categories(categories)
		printf "%-40s %-30s\n", "Category", "Slug"
		printf "-" * 65 + "\n"
		for category in categories
			printf "%-40s %-30s\n", category["name"], category["slug"]
		end
	end

	def self.print_topics(topics, client)
		$post_buffer = []
		printf "%-5s %-15s %-20s\n", "ID", "Username", "Title"
		printf "-" * 65 + "\n"
		for topic in topics
			topic_data_raw = client.topic(topic["id"])
			$post_buffer.push(topic["id"])
			topic_data = topic_data_raw["post_stream"]["posts"][0]
			printf "%-5s %-15s %-20s\n", topic["id"].to_s, topic_data["username"], topic_data_raw["title"]
		end
	end

	def self.print_user_topics(topics, client)
		$post_buffer = []
		printf "%-5s %-15s %-20s\n", "ID", "Username", "Title"
		printf "-" * 65 + "\n"
		for topic in topics
			$post_buffer.push(topic["id"])
			topic_data_raw = client.topic(topic["id"])
			topic_data = topic_data_raw["post_stream"]["posts"][0]
			printf "%-5s %-15s %-20s\n", topic["id"].to_s, topic_data["username"], topic_data_raw["title"]
		end
	end
end
