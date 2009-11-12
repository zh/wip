require 'rubygems'
require 'twitter/json_stream'
require 'json'

EventMachine::run {
  stream = Twitter::JSONStream.connect(
    :path    => '/1/statuses/filter.json',
    :auth    => '__me__:__secret__',
    :method  => 'POST',
    :content => 'track=iphone'
    #:content => 'follow=86723107'
  )
    
  stream.each_item do |item|
    parsed = JSON.parse(item)
    $stdout.print "#{parsed['user']['screen_name']}: #{parsed['text']}\n"
    #$stdout.print "item: #{item}\n"
    $stdout.flush
  end
  
  stream.on_error do |message|
    $stdout.print "error: #{message}\n"
    $stdout.flush
  end
  
  stream.on_reconnect do |timeout, retries|
    $stdout.print "reconnecting in: #{timeout} seconds\n"
    $stdout.flush
  end
  
  stream.on_max_reconnects do |timeout, retries|
    $stdout.print "Failed after #{retries} failed reconnects\n"
    $stdout.flush
  end
  
  trap(:INT) {  
    stream.stop
    EventMachine.stop if EventMachine.reactor_running? 
  }
}
at_exit { puts "The event loop has ended" }
