#!/usr/bin/env ruby

require "rubygems"
require "eventmachine"
require "em-http"

EM.run {
  http = EM::HttpRequest.new('http://www.google.com/').get(:query => {'keyname' => 'value'}, 
                                                           :timeout => 10)
  http.callback {
    p http.response_header.status
    p http.response_header
    p http.response

    EM.stop
  }
}
