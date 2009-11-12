#!/usr/bin/env ruby

require 'rubygems'
require 'rack'
require 'rack/request'
require 'rack/response'
require 'erb'

class ContactForm

  def call(env)
    req = Rack::Request.new(env) 

    return_addr = req.GET['email']
    message     = req.GET['message']
    
    if return_addr && message
      email_template = ERB.new <<-EOL
        From: <%= return_addr %>
        To: support@yourcompany.com
        Subject: Support Request
        Date: <%= Time.now.strftime('%m-%d-%Y') %>
    
        <%= message %>
      EOL
      require 'net/smtp'
      Net::SMTP.start('smtp.example.com', 25) do |smtp|
        smtp.send_message( email_template.result,
    		       return_addr, '__me__@example.com' )
      end
    
    end
    
    # Build the HTML template
    html_template = ERB.new <<-EOL
      <html>
      <head><title>Contact Us</title></head>
      <body><%= message %>
        <form action="">
          <h1>Contact Us</h1>
          
          <p>E-mail<br/>
          <input name="email" type="text"></p>
          
          <p>Message Body<br/>
          <input name="message" type="textarea"></p>
    
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
    
contact_form = ContactForm.new

#Rack::Handler::CGI.run contact_form
#Rack::Handler::WEBrick.run contact_form, :Port => 3000
Rack::Handler::Mongrel.run contact_form, :Port => 3000
