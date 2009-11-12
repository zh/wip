#!/usr/bin/env ruby

require 'digest/sha1'
require 'rubygems'
require 'json'
require 'httpclient'

begin
  require 'system_timer'
  MyTimer = SystemTimer
rescue
  require 'timeout'
  MyTimer = Timeout
end

unless ARGV[0]
  p "Usage: #{$0} MSG"
  exit 
end

USER = "__me__".freeze
KEY = "__some_secret__".freeze
URL = "http://im.kayac.com/api/post/#{USER}".freeze

sig = Digest::SHA1.hexdigest("#{ARGV[0]}#{KEY}")

MyTimer.timeout(5) do
  res = HTTPClient.post(URL, :message => ARGV[0], :sig => sig)
  p JSON.parse(res.content)
end 
