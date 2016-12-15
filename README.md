# Re-Twitter
Let us see how to make a twitter bot using Ruby alone. I am sure you would have come across the term `twitter-bots`, it's used by almost everyone to automate tasks like, liking a tweet if your follower tweets by mentioning you in the tweet.

It's another important use case is fetching tweets from twitter to do sentiment analysis or understand the current trend.

The prerequisites for this project is Ruby and a little bit knowledge of HTML, CSS.

I could have used Ruby on Rails(RoR) for making a twitter bot, but it would not be a wise decision to use it for such a small projects. So I decided to use Sinatra, a small ruby based micro-web framework, it just has 1000 lines of code in it compared to RoR which has around 100000 lines of code.
**It's fast. It's simple. It's efficient.**

Features can be easily added by adding gems similar to how you add in Java or any NodeJS app.

So before we start making our app we need to install Ruby.
The best way to install Ruby and RubyGems is with Ruby Version Manager, or RVM.

Follow the steps mentioned below to do so:
```shell
\curl -L https://get.rvm.io | bash -s stable --ruby=2.3.1
```
*You can put any version number for the Ruby version.*

To install systemwide, prepend sudo before bash:
```shell
\curl -L https://get.rvm.io | sudo bash -s stable --ruby=2.3.1
```

Now check the `ruby` version by entering `ruby -v`, if it is not the same which you installed then do `rvm use 2.3.1`.

### Install Sinatra
``` ruby
gem install sinatra
```

Now create a folder named as **twitter_bot**.
```shell
mkdir twitter_bot
cd twitter_bot
```
Open this folder in your favorite text editor, I prefer using [Sublime](https://www.sublimetext.com/) because of its simplicity.

Now we are going to put the app structure and basic setup in place. Run the following commands:
```shell
mkdir -p config/initializers lib views public/css

touch config/initializers/secrets.rb config/initializers/twitter.rb public/css/main.css Gemfile Rakefile config.ru init.rb views/index.erb lib/bot.rb
```

Now you should have the app structure like this:
```
twitter_bot/
        ----config/
            ----initializers/
                ----secrets.rb
                ----twitter.rb
        ----lib/
            ----bot.rb
        ----public/
            ----css/
                ----main.css
        ----views/
            ----index.erb
        ----Gemfile
        ----Rakefile
        ----config.ru
        ----init.rb

```

Add the following gems in the **Gemfile** which will allow us to add features to our app.
#### rack:
Rack provides a minimal, modular, and adaptable interface for developing web applications in Ruby. By wrapping HTTP requests and responses in the simplest way possible, it unifies and distills the API for web servers, web frameworks, and software in between (the so-called middleware) into a single method call.
#### twitter
A ruby interface for the Twitter API.
#### sinatra
#### sinatra-contrib
Auto restarting the app after every change.
#### thin
A small and fast Ruby web server.
#### json
This is a implementation of the JSON specification according to RFC 7159. It allows us to deal with JSON.

Gemfile should look like this:
```
# specifying the ruby version
ruby '2.3.1'
source 'https://rubygems.org'
gem 'rack'
gem 'twitter'
gem 'sinatra'

# auto restarting the app after every change
gem "sinatra-contrib"
gem 'thin'
gem 'json'
```
Now run bundle install to install all the gems specified in the Gemfile,
`bundle install`

Now we will add the modules that should be loaded when the app starts in `config.ru`.
```
require './config/initializers/secrets'
require './config/initializers/twitter'
require './init'
run Sinatra::Application
```
Now we need to have a developer account in twitter to be able to fetch tweets from Twitter. So let's create it now.
1. Go to https://dev.twitter.com/apps/new and log in, if necessary.
2. Supply the necessary required fields, accept the TOS, and solve the CAPTCHA.
3. Submit the form
4. Copy the consumer key (API key) and consumer secret from the screen into your application
5. If you also need the access token representing your own account's relationship with the application:
6. Ensure that your application is configured correctly with the permission level you need (read-only, read-write, read-write-with-direct messages).
7. On the application's detail page, invoke the "Your access token" feature to automatically negotiate the access token at the permission level you need.
8. Copy the indicated access token and access token secret from the screen into your application

We need these four keys in order to communicate with Twitter API:
- CONSUMER_KEY
- CONSUMER_SECRET
- ACCESS_TOKEN
- ACCESS_TOKEN_SECRET

In the **config/initializers/secrets.rb** file add the following keys:
```ruby
ENV["CONSUMER_KEY"] = "xxxkJhDxxxxxxxxxxxxxxxzxx0"
ENV["CONSUMER_SECRET"] = "0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxXV"
ENV["ACCESS_TOKEN"] = "xxxxxxxxxxxxxxxxxxxxxx"
ENV["ACCESS_TOKEN_SECRET"] = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

Now add the following code to authenticate and get access to fetch tweets from Twitter in **config/initializers/twitter.rb**.

```ruby
require 'twitter'

$client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["CONSUMER_KEY"]
  config.consumer_secret     = ENV["CONSUMER_SECRET"]
  config.access_token        = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
end
```

Now we will create a Bot class where we would be able to define certain methods that the bot should do.

Now lets define what our app is going to do.
- Favorite tweets which w want to by providing certain terms if it has not been favorited by our bots.
- Retweet tweets if it has not been retweeted by bots.

Our bot should be able to fetch the tweets based on the search terms provided by us.
#### search:`client.search(search_string, lang: "en")`
#### favorite:`client.favorite(<tweet_id>)`
#### retweet:`client.retweet(<tweet_id>)`

You definitely do not want to get in trouble by your bot liking a sensitive tweet. So twitter provides a method to check that too.
#### possibly_sensitive?
Call this method on the tweet, `tweet.possibly_sensitive?`. This
returns `true` or `false`.

Similarly the twitter API also provides methods like retweeted?, favorited?. These methods can be directly called on the tweets.

```ruby
# lib/bot.rb
class Bot

	def initialize
    # gets the $client global variable initialized during starting our application
		@client = $client
	end

	def get_tweets(term,limit=1)
    # getting the tweets by using limit
		tweets = @client.search("#{text}", lang: "en").first(limit) || ""
	end

	def fav_tweets(tweets)
		tweets.each do |tw|
      # like a tweet if it has not been liked by our bot
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
      # retweet a tweet if it has not been retweeted before by our bot
			if !tw.possibly_sensitive? and !tw.retweeted?
				@client.retweet(tw.id)
			else
				puts "it has been retweeted: #{tw.retweeted?}"
			end
		end
	end

end
```

Now we need to create actions which can be called from the view to perform a certain action.

Open `init.rb` file,
```
# storing the root location in a constant.
APP_ROOT = File.dirname(__FILE__)
require 'sinatra'
require 'json'
# loading the bot class
require File.join(APP_ROOT,"lib","bot")
```
So we have done the basic setup, let us create an index page.

Open `views/index.erb`, and add the following HTML code, you have your own layout.
```html
<!DOCTYPE html>
<html lang="en">
<head>
	<title>Twitter Bot</title>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width,initial-scale=1">
	<link rel="stylesheet" type="text/css" href="/css/main.css">
</head>
<body>
	<div class="col-12">
		<div class="col-12 navbar txt--center">
			<h3>ReTwitter Bot</h3>
		</div>
		<div class="col-12 container txt--center margin-top-md">
			<h4>
				This a twitter bot which likes to do what I like.
			</h4>
			<div class="col-12 txt--center">
				<a class="fnt--white btn--red" href="/fav_tweets">Favourite!</a>
				<a class="fnt--white btn--blue" href="/rt_tweets">ReTweet</a>
			</div>
		</div>

	</div>
</body>
</html>
```
Above we have added two buttons to retweet and favorite tweets which we like.

Let us define the actions which will help us in rendering the pages and performing certain actions.
```ruby
# add any serach term or twitter handle which you want to like or retweet
LIST = ["@androidcentral","#react","#es6","#xperia-xz","#rails5"]

# This renders the html page when we hit the root url
get '/' do
  #  specifying which page to render
	erb :index
end

get '/fav_tweets' do
	bot = Bot.new
	tweets = []
	LIST.each {|term| tweets << bot.get_tweets(term,2)}
	tweets.each {|tw| bot.fav_tweets(tw)}
	{:status=>"Done Favoriting"}.to_json
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

# serves main.css
get '/css/main.css' do
  redirect "/main.css"
end
```

You can read about more methods provided by the `twitter` gem [here](http://www.rubydoc.info/gems/twitter).

### Test your app locally,
```
 bundle exec rackup -p 9292 config.ru &
 ```

 ### Deploying App to Heroku:
 ```
 git init
 git add .
 git commit -m 'pure rack app'
 heroku create
 git push heroku master
```

The app is now deployed to Heroku. Test by executing heroku open or by visiting your app’s URL in your browser. You should see the twitter app.

