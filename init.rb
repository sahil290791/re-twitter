APP_ROOT = File.dirname(__FILE__)
require 'sinatra'
require 'json'
require File.join(APP_ROOT,"lib","bot")

LIST = ["@androidcentral","#react","#es6","#xperia-xz","#rails5"]

get '/bot.json' do
	bot = Bot.new
	LIST = ["@androidcentral","#react","#es6","#xperia-xz","#rails5"]
	LIST.each {|term| bot.search(term,3) }
	{ :status=>"Tweets liked!!" }.to_json
end

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

end

get '/css/main.css' do
  redirect "/main.css"
end