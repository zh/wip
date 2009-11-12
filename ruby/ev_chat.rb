#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'

module Chat
 
  # Called after the connection with a client has been established
  def post_init      
    # Add ourselves to the list of clients
    (@@connections ||= []) << self  
    send_data "Please enter your name: "
  end 

  # Called on new incoming data from the client
  def receive_data data
    # The first message from the user is its name
    @name ||= data.strip
 
    @@connections.each do |client|
      # Send the message from the client to all other clients
      client.send_data "#{@name} says: #{data}"
    end
  end
end

# Start a server on localhost, using port 8081 and hosting our Chat application
EventMachine::run do
  EventMachine::start_server "0.0.0.0", 8081, Chat
end 
