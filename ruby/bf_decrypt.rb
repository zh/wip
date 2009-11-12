#!/usr/bin/env ruby
#
#   A simple ruby script to decrypt a file
#     can be edited to decrypt directories also
#
#    Written by:  Studlee2 at gmail dot com
#
#    Using the blowfish algorithm
#         several algorithms exist, just substitute for 'blowfish'
#         make sure it matches the encryption algorithm
require 'crypt/blowfish'

begin
#take in the file name to decrypt as an argument
  filename = ARGV.shift
  puts "Decrypting #{filename}"
  p = "Decrypted_#{filename}"
#User specifies the original key from 1-56 bytes (or guesses)
  print 'Enter your encryption key: '
  kee = gets
#initialize the decryption method using the user input key  
  blowfish = Crypt::Blowfish.new(kee)
  blowfish.decrypt_file(filename.to_str, p)
#decrypt the file  
  puts 'Decryption SUCCESS!'
rescue
#if the script busts for any reason this will catch it
  puts "\n\n\nSorry the decryption was unsuccessful"
  puts "USAGE: ruby bf_decrypt.rb <plaintext file>\n\n\n"
  raise
end
