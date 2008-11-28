#!/usr/bin/ruby
require 'cgi'

outarr = []

CGI.unescape($*.join(' ')).downcase.unpack('C*').each{|x|
	x = x + 1 if x > 97
	if x < 112 and x > 96 
		x = x - 12
	else
		if x > 111 then
			x = x + 12
		end
	end
	outarr.push x
}

puts outarr.pack('C*')
