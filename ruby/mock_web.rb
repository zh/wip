#!/usr/bin/env ruby

require 'rubygems'
require 'rack'
require 'thin'

# Mock server for testing bad or heavyweight server responses; runs on
# localhost:4000 by default
#
# Example of use
#
# In setup method:
#
# @mock_server = MockServer.new # creating a new instance spawns a
# thread running the TCP server
# @mock_server.register( { 'REQUEST_METHOD' => 'GET' }, 
# [ 200, { 'Content-Type' => 'text/plain', 'Content-Length' => '11' }, 
# [ 'Hello World' ]])
# @mock_server.register( { `REQUEST_METHOD' => `GET' }, [
#  200, { 'Content-Type' => 'text/plain', 'Content-Length' => '11' }, 
#  [ 'Hello Again' ]])
#
# After each test, to remove all expectations:
#
# @mock_server.clear
#
# In teardown method:
#
# @mock_server.stop

class MockServer

  def initialize(options={})
    host = options[:host] || '127.0.0.1'
    port = options[:port] || 4000
    @expectations = []
    @server = Thin::Server.new(host, port, self)
    @thread = Thread.new { @server.start }
  end

  def stop
    @server.stop!
    Thread.kill(@thread)
  end

# env should be a hash mapping elements of a Rack env to expected values 
# (see examples above); note that an expected value can be a Proc which 
# will be passed the value from the request
# and executed - if the Proc returns true on execution, the expectation is met
#
# For example, to check that the querystring contains the value `1234', env could be:
#
# { `QUERY_STRING' => lambda { |qs| !((qs =~ /1234/).nil?) } }
#
# response should be a Rack-formatted response; i.e. [response_code,
# {'header' => 'value', ...}, response_body]
#
# options:
# :transient => false to prevent a response being removed after it has 
# been served (default is true)
  def register(env, response, options={})
    transient = options[:transient]
    transient = true if transient.nil?
    
    @expectations = []
  
    @expectations.each_with_index do |expectation, index|
      expectation_env, matched_response, transient = expectation
      matched = false
  
      expectation_env.each do |env_key, value|
        puts "Trying to match #{env_key} => #{value} to request"
        matched = true
  
        req_value = env[env_key]
  
        if value.is_a? Proc
          req_element_matches = value.call(req_value)
        else
          req_element_matches = (value == req_value)
        end
  
        unless req_element_matches
          puts " Value NOT matched: request value was #{env[env_key]} (needed #{value} to match)"
          matched = false
          break
        end
      end
  
      if matched
        if transient
          @expectations.delete_at(index)
        end
        response = matched_response
        break
      end
    end
    response
  end
  
end
