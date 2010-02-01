#!/usr/bin/env ruby

require "rubygems"
require "eventmachine"
require "thread"

class Worker
  include EM::Deferrable

  def good(msg)
    puts "worker #{Thread.current}: #{msg}"
    set_deferred_status(:succeeded, "done.")
  end 

  def bad(msg) 
    puts "worker  #{Thread.current}: #{msg}"
    set_deferred_status(:failed, "ERROR")
  end 
end

EM.run do
  EM.add_timer(10) do
    EM.stop
  end

  EM.add_periodic_timer(1) do
    puts "tick..."
  end  
  
  EM.add_timer(3) do
    task = Worker.new
    task.callback { |msg| puts "cb1 #{Thread.current}: #{msg}" }
    task.errback  { |msg| puts "eb #{Thread.current}:    #{msg}" }
    task.callback { |msg| puts "cb2 #{Thread.current}: #{msg}" }
    task.good("good action")
  end

  EM.add_timer(5) do
    task = Worker.new
    task.callback { |msg| puts "cb1 #{Thread.current}: #{msg}" }
    task.errback  { |msg| puts "eb #{Thread.current}:    #{msg}" }
    task.callback { |msg| puts "cb2 #{Thread.current}: #{msg}" }
    task.bad("bad action")
  end
end
