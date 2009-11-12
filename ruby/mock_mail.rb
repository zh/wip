#!/usr/bin/env ruby

require 'socket'

DEBUG = false

def data(sock)
	s = ""

	sock.print "354 End data with <CR><LF>.<CR><LF>\r\n"
	while(line = sock.gets)
		puts line if DEBUG
		break if line =~ /^\.\r?\n?$/
		s += line
	end
	s
end

def session(sock)
	sock.print "220 localhost SMTP mockmail\r\n"
	from = nil
	to = []
	body = nil
	while(line = sock.gets)
		line.chomp!
		puts line if DEBUG
		sock.print case line
			when /HELO/: "250 localhost\r\n"
			when /RSET/: "250 Ok\r\n"
			when /VRFY/:
				/VRFY [^\s]/ =~ line
				"252 #{$1}\r\n"
			when /MAIL FROM/:
				/MAIL FROM:\s*\<?([^\s<>]+)\>?/ =~ line
				from = $1
				puts from if DEBUG
				"250 Ok\r\n"
			when /RCPT TO/:
				/RCPT TO:\s*\<?([^\s\r\n\t\f<>]+)\>?/ =~ line
				to << $1
				puts to if DEBUG
				"250 Ok\r\n"
			when /DATA/:
				body = data(sock)
				"250 Ok\r\n"
			when /QUIT/:
				sock.print "221 Bye\r\n"
				break
			else "500 Err\r\n"
		end
	end
	puts "from: #{from}"
	puts "to: #{to.join '; '}"
	puts "---"
	puts body
	puts "==="
	open("mockmail.txt", "a") { |f|
		f.puts "from: #{from}"
		f.puts "to: #{to.join '; '}"
		f.puts "---"
		f.puts body
		f.puts "==="
	}
	sock.close
end

def main
	begin
		server = TCPServer.new('localhost',25)
		Thread.start {
			loop { sleep 1 }
		}
		loop do 
			Thread.start(server.accept) { |sock|
				begin
					session(sock)
				rescue Exception => e
					p e
				end
			}
		end
	rescue Interrupt => i
		puts "ending..."
	end
end

main
