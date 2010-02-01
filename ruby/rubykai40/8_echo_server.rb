#!/usr/bin/env ruby

require "rubygems"
require "eventmachine"

trap(:INT) { puts "bye!"; EM.stop }
trap(:TERM) { puts "bye!"; EM.stop }

class Echo < EM::Connection
  def receive_data(data)
    send_data(data)
  end
end

EM.epoll
EM.run do
  EM.start_server("0.0.0.0", 10000, Echo)
end
