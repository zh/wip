#!/usr/bin/env ruby
#
#   A simple ruby script to encrypt a file
#     can be edited to encrypt directories also
#
#    Written by:  Studlee2 at gmail dot com
#
#    Using the blowfish algorithm
#        several algorithms exist, just substitute for 'blowfish'
#
require 'crypt/blowfish'

begin
#take in the file name to encrypt as an argument
  filename = ARGV.shift
  puts filename
  c = "Encrypted_#{filename}"
#User specifies a key from 1-56 bytes (Don't forget this or your stuff is history)
  print 'Enter your encryption key (1-56 bytes): '
  kee = gets
#initialize the encryption method using the user input key
  blowfish = Crypt::Blowfish.new(kee)
  blowfish.encrypt_file(filename.to_str, c)
#encrypt the file
  puts 'Encryption SUCCESS!'
rescue
#if the script busts for any reason this will catch it
  puts "\n\n\nSorry the encryption was unsuccessful"
  puts "USAGE: ruby bf_encrypt.rb <plaintext file>\n\n\n"
  raise
end
