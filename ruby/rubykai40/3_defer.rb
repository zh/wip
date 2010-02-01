#!/usr/bin/env ruby

require "rubygems"
require "eventmachine"
require "thread"

EM.epoll
EM.run do
  EM.add_periodic_timer(1) do
    puts "- tick: #{Thread.current}"
  end
  EM.add_timer(5) do
    puts "main: #{Thread.current}"
    EM.stop
  end
  
  5.times do
    EM.defer(lambda { puts "defer: #{Thread.current}" })
  end
end
