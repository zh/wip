#!/usr/bin/env ruby

require "rubygems"
require "eventmachine"

trap(:INT) { puts "done."; EM.stop }

class Connector < EM::Connection
  def post_init
    puts "connecting..."
    send_data("GET / HTTP/1.1\r\nHost: mini10v\r\n\r\n")
  end

  def receive_data(data)
    puts "received: #{data.length} bytes"
  end
end

EM.epoll
EM.run do
  EM.connect ARGV.first, 80, Connector
end
