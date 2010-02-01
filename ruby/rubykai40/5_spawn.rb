#!/usr/bin/env ruby

require "rubygems"
require "eventmachine"
require "thread"

EM.run do
  EM.add_periodic_timer(1) do
    puts "#{Thread.current} tick..."
  end

  EM.add_timer(6) do
    EM.stop
  end

  s = EM.spawn do |val| 
    puts "#{Thread.current} received #{val}"
  end

  EM.add_timer(3) do
    s.notify "hello"
  end
end
