#!/usr/bin/ruby
require 'cgi'

outarr = []

CGI.unescape($*.join(' ')).downcase.unpack('C*').each{|x|
	x = x + 1 if x > 96
	
	if x < 114 and x > 96 
		x = x + 12
	else
		if x > 113
			x = x - 12
		end
	end
	outarr.push x
}

puts outarr.pack('C*')