#!/usr/bin/ruby
require 'cgi'

puts CGI.unescape($*.join(' ')).downcase.unpack('C*').map{|x|
	x = x + 1 if x > 96
	if x < 112 and x > 96 
		x = x + 12
	else
		if x > 111 then
			x = x - 12
		end
	end
}.pack('C*')