require 'open-uri'
require 'cgi'

puts open(CGI.escape($*.join('+'))).read
