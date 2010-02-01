#!/usr/bin/env ruby
#
# enable_proxy allows direct forwarding of incoming data to another descriptor

require "rubygems"
require "eventmachine"

trap(:INT) { puts "bye!"; EM.stop }
trap(:TERM) { puts "bye!"; EM.stop }

module ProxyConnection
  def initialize(client, request)
    @client, @request = client, request
  end

  def post_init
    EM::enable_proxy(self, @client)
  end

  def connection_completed
    send_data @request
  end

  def proxy_target_unbound
    close_connection
  end

  def unbind
    @client.close_connection(true)
  end
end

module ProxyServer
  def receive_data(data)
    (@buf ||= "") << data
    if @buf =~ /\r\n\r\n/  # all http headers received
      EM.connect("www.google.com", 80, ProxyConnection, self, data)
    end
  end
end

EM.run do
  EM.start_server("127.0.0.1", 8080, ProxyServer)
end
