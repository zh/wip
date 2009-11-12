require 'openssl'
require 'digest/sha2'
c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
c.encrypt
# your pass is what is used to encrypt/decrypt
c.key = key = Digest::SHA256.hexdigest("yourpass")
c.iv = iv = c.random_iv
e = c.update("crypt this")
e << c.final
puts "encrypted: #{e}\n"
c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
c.decrypt
c.key = key
c.iv = iv
d = c.update(e)
d << c.final
puts "decrypted: #{d}\n"
