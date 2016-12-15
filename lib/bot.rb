#!/usr/bin/env ruby

class Bot

	def initialize
		@client = $client
	end

	def tweet_count
		puts @client.tweet_count
	end

	def search(text,count=1)
		tweets = @client.search("#{text}", lang: "en").first(count)
		tweets.each {|tw|  puts "#{tw.full_text}\n\n"}
		fav_tweets(tweets)
	end

	def user_timeline(user)
		tweets = @client.user_timeline(user).first(4)
		tweets.each {|tw|  puts "#{tw.full_text}\n\n"}
		fav_tweets(tweets)
		retweet(tweets)
	end

	def get_tweets(term,count=1)
		tweets = @client.search("#{text}", lang: "en").first(count) || ""
	end

	def fav_tweets(tweets)
		tweets.each do |tw|
			if !tw.favorited?
				puts "favorited!!"
				@client.favorite(tw.id)
			else
				puts "it has already been favorited"	
			end
		end
	end

	def retweet(tweets)
		tweets.each do |tw|
			if !tw.possibly_sensitive? and !tw.retweeted?
				@client.retweet(tw.id)
			else
				puts "it has been retweeted: #{tw.retweeted?}"	
			end
		end
	end

	private
	# def authorize!
	# 	@client = Twitter::REST::Client.new do |config|
	# 	  config.consumer_key        = ENV["CONSUMER_KEY"] 
	# 	  config.consumer_secret     = ENV["CONSUMER_SECRET"] 
	# 	  config.access_token        = ENV["ACCESS_TOKEN"] 
	# 	  config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
	# 	end
	# end
end	
