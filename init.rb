APP_ROOT = File.dirname(__FILE__)
require 'sinatra'
require 'json'
require File.join(APP_ROOT,"lib","bot")

LIST = ["@androidcentral","#react","#es6","#xperia-xz","#rails5"]

get '/' do
	erb :index
end

get '/fav_tweets' do
	bot = Bot.new
	tweets = []
	LIST.each {|term| tweets << bot.get_tweets(term,2)}
	tweets.each {|tw| bot.fav_tweets(tw)}
	{:status=>"Done Tweeting"}.to_json
end

get '/rt_tweets' do
	# create a bot object
	bot = Bot.new
	tweets = []
	# store the tweets in an array
	LIST.each {|term| tweets << bot.get_tweets(term,2)}
	# call the retweet method on all the tweets inside tweets array
	tweets.each {|tw| bot.retweet(tw)}
	{:status=>"Done ReTweeting"}.to_json
end

get '/css/main.css' do
  redirect "/main.css"
end
