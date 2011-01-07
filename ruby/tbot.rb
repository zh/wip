require 'rubygems'
require 'xmpp4r-simple'
require 'eventmachine'
require 'httpclient'
require 'json'
require 'twitter/json_stream'

#Jabber::debug = true

class Jabber::Simple
  def subscribed_to?(x); true; end
  def ask_for_auth(x); contacts(x).ask_for_authorization!; end
end

module LiveCoding
  class Task
    include EM::Deferrable
  
    def do_subscribe(keyword, streams, url = nil)
      begin
        raise "need hook keyword" unless keyword
        stream = Twitter::JSONStream.connect(
          :path    => '/1/statuses/filter.json',
          :auth    => 'user:secret',
          :method  => 'POST',
          :content => "track=#{keyword}"
          #:content => 'follow=86723107'
        )
        streams[keyword] = [stream, url]

        stream.each_item do |item|
          parsed = JSON.parse(item)
          next unless parsed
          msg = "(#{keyword}) [#{parsed['user']['screen_name']}]: #{parsed['text']}"
          $stdout.print "#{msg}\n"
          $stdout.flush
          HTTPClient.post(url, {:payload => { :message => msg }.to_json }) if url
        end  
        set_deferred_status(:succeeded)
      rescue Exception => e
        puts "subscribe: #{e.to_s}"
        set_deferred_status(:failed)
      end
    end
  
    def do_unsubscribe(keyword, streams)
      begin
        raise "need keyword" unless keyword
        streams[keyword][0].stop
        set_deferred_status(:succeeded)
      rescue Exception => e
        puts "unsubscribe: #{e.to_s}"
        set_deferred_status(:failed)
      end
    end
  end # class  

  class Bot

    def self.run
      at_exit do
        @@socket.disconnect
        @@streams.each do |k,v|
          v[0].stop
        end  
      end

      EM.epoll
      EM.run do

        settings = YAML.load(File.read("livecoding.yml"))
        @@socket = Jabber::Simple.new(settings["bot.jid"], settings["bot.pass"])
        @@socket.accept_subscriptions = true

        # all subscriptions
        @@streams = {}

        EM::PeriodicTimer.new(0.05) do
         
          @@socket.received_messages do |msg|
            
            from = msg.from.strip.to_s
            next unless (msg.type == :chat and not msg.body.empty?)
            cmdline = msg.body.split

            case cmdline[0]
            when "HELP", "H", "help", "?":
              # TODO better help
              help = "HELP, PING, S, U, L"
              @@socket.deliver(from, help)
            when "PING", "ping", "Ping":
              @@socket.ask_for_auth(msg.from)
              @@socket.deliver(from, "PONG ;)")
            when "L", "l":
              msg = ""
              if @@streams.length > 0
                msg += "\nSubsciptions:\n"
                @@streams.each do |k,v|
                  msg += v[1] ? "#{k} -> #{v[1]}\n" : "#{k}\n"
                end  
              else
                msg = "No subscriptions"
              end
              @@socket.deliver(from, msg)
            when "S", "s":
              # ToDo: check for valid URL
              if cmdline.length < 2
                @@socket.deliver(from, "[E] Usage: S {keyword} [url]")
                next
              end  
              keyword = cmdline[1]
              url = cmdline.length > 2 ? cmdline[2] : nil
              EM.spawn do
                task = Task.new
                task.callback { @@socket.deliver(from, "Subscribed to #{keyword}") }
                task.errback  { @@socket.deliver(from, "Subscription failed") }
                task.do_subscribe(keyword, @@streams, url)
              end.notify
            when "U", "u":
              if cmdline.length < 2
                @@socket.deliver(from, "[E] Usage: U {keyword}")
                next
              end  
              keyword = cmdline[1]
              EM.spawn do
                task = Task.new
                task.callback { @@socket.deliver(from, "UnSubscribed from #{keyword}") }
                task.errback  { @@socket.deliver(from, "UnSubscription failed") }
                task.do_unsubscribe(keyword, @@streams)
              end.notify
            end  # case
          end
        end  # EM::Timer  
      end    # EM.run  
    end      # Bot::run 
  
  end  # Bot
end    # module


if __FILE__ == $0
  # register a handler for SIGINTs
  trap(:INT) do
    EM.stop
    exit
  end
  LiveCoding::Bot.run
end  
