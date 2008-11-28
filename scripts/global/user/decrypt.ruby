#!/usr/bin/ruby
require 'cgi'

outarr = []

CGI.unescape($*.join(' ')).downcase.unpack('C*').each{|x|
	x = x - 1 if x > 97
	
	if x > 109
		x = x - 13
	else
		if x >= 96
			x = x + 13
		end
	end
	outarr.push x
}

puts outarr.pack('C*')