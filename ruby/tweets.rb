require 'rubygems'
require 'sinatra'
require 'em-http'
require 'json'


get '/tweets' do
  content_type 'text/html', :charset => 'utf-8'
  TWEETS.map {|tweet| "<p><b>#{tweet['user']['screen_name']}</b>: #{tweet['text']}</p>" }.join
end

class RingBuffer < Array
  def initialize(size)
    @max = size
    super(0)
  end

  def push(object)
    shift if size == @max
    super
  end
end

TWEETS = RingBuffer.new(10)
KEYWORD = ARGV[0] ? ARGV[0] : 'iphone'
STREAMING_URL = "http://stream.twitter.com/1/statuses/filter.json?track=#{KEYWORD}"

def handle_tweet(tweet)
  puts "[D] #{tweet.inspect}"
  return unless tweet['text']
  TWEETS.push(tweet)
end

EM.schedule do
  http = EM::HttpRequest.new(STREAMING_URL).get :head => { 'Authorization' => [ 'user', 'secret' ] }
  buffer = ""
  http.stream do |chunk|
    buffer += chunk
    while line = buffer.slice!(/.+＼r?＼n/)
      handle_tweet JSON.parse(line)
    end
  end
end
