#!/usr/bin/env ruby

require 'rubygems'
require 'rack'
require 'rack/request'
require 'rack/response'
require 'erb'
require 'xmpp4r'

#BOT = 'zhesto@notify.me/Web'.freeze
BOT = '__bot__@jabber.org/Web'.freeze
PASS = '__secret__'.freeze
TO = '__you__@gmail.com'.freeze

class ToXMPP

  include Jabber

  def call(env)
    req = Rack::Request.new(env)

    message = req.POST['message']
    
    if message 
      c = Client::new(JID::new(BOT))
      c.connect
      c.auth(PASS)
      c.send Message::new(TO, message.to_s).set_type(:normal).set_id('1').set_subject('message to juick')
      sleep(1)
      c.close
    end

    # Build the HTML template
    html_template = ERB.new <<-EOL
<html>
<head><title>Send XMPP message</title>
<style>
.ln 
{
 font-family: arial, helvetica, geneva, tahoma;
 font-size: 9px;
 color: white; 
 text-decoration: none; 
 background-color:green; 
 padding: 2px; 
 border: 1px solid black; 
 cursor: pointer; 
}
img { border:none; }
</style>
<script src="http://cdn.zhekov.net/js/CookieManager.js"></script>
<script src="http://cdn.zhekov.net/js/motranslatorUTF8.js"></script>
<noscript><h2>JavaScript required!</h2></noscript>
<meta http-equiv=Content-Type content="text/html; charset=utf-8" />
</head>
<body><%= message %>
<br/><br/>
<form action="" method="post">
<a href="#" id="langLink" title="Language" class="ln"></a>
<small>(PHO: phonetic, BDS, OFF: latin)</small>
<br/><br/>
<textarea  MOLANG="PHO" rows="3" cols="60" id="message" name="message"></textarea>
<br/><br/>
<input type="submit">
</form>
</body></html>
    EOL
    out = html_template.result binding
    Rack::Response.new.finish do |res|
      res.write out
    end  
  end
end

prot_app = Rack::Auth::Basic.new(ToXMPP.new) do |username, password|
  'stoyan' == username  && 'secret' == password
end
    
Rack::Handler::Mongrel.run Rack::ShowExceptions.new(prot_app), :Port => 9292
