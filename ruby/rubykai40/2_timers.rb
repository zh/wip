#!/usr/bin/env ruby

require "rubygems"
require "eventmachine"

EM.run do
  EM.add_periodic_timer(1) do
    puts "tick..."
  end
  EM.add_timer(5) do
    puts "BOOOOOOM !!!"
    EM.stop
  end
end
