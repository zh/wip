#!/usr/bin/env ruby

require "rubygems"
require "eventmachine"

EM.epoll

puts "start"
EM.run do
  puts "init"
  EM.add_timer(1) do
    puts "quit..."
    EM.stop
  end
end
puts "done."
