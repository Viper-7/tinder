#!/usr/bin/ruby
require 'cgi'

outarr = []

CGI.unescape($*.join(' ')).downcase.unpack('C*').each{|x|
	x = x - 1 if x > 96
	
	if x > 109
		x = x - 13
	else
		if x > 95
			x = x + 13
		else 
			if x > 60 and x < 80
				x = x - 20
			end
		end
	end
	outarr.push x
}

puts outarr.pack('C*')