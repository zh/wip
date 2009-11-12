#!/usr/bin/env ruby
#
# Purpose: AMQP based chat
#

require 'rubygems'
gem 'amqp'
require 'mq'

unless ARGV.length == 2
  STDERR.puts "Usage: #{$0} <channel> <nick>"
  exit 1
end
$channel, $nick = ARGV

AMQP.start(:host => 'localhost') do
  $chat = MQ.topic('chat')

  # Print any messages on our channel.
  queue = MQ.queue($nick)
  queue.bind('chat', :key => $channel)
  queue.subscribe do |msg|
    if msg.index("#{$nick}:") != 0
      puts msg
    end
  end

  # Forward console input to our channel.
  module KeyboardInput
    include EM::Protocols::LineText2
    def receive_line data
      $chat.publish("#{$nick}: #{data}",
                    :routing_key => $channel)
    end
  end
  EM.open_keyboard(KeyboardInput)
end
