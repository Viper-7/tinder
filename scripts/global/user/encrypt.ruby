#!/usr/bin/ruby
require 'cgi'

puts CGI.unescape($*.join(' ')).downcase.unpack('C*').map{|x|
	x = x
	x = x + 1 if x > 96
	if x > 111
		x = x - 12
	else
	 	x = x + 12 if x > 96
	end
}.pack('C*')