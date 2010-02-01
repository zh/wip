#!/usr/bin/env ruby

require "rubygems"
require "eventmachine"

EM.run do
  client = EM::Protocols::HttpClient.request(
    :host => ARGV.first, :request => "/")

  client.callback do |response|
    puts "success: #{response[:status]}, #{response[:content].length} bytes"
    EM.stop
  end

  client.errback do |response|
    puts "ERROR: #{response[:status]}"
    EM.stop
  end
end
