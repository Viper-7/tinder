#!/usr/bin/ruby

puts $*.join(' ').downcase.unpack('C*').map{|x|
	x=x-1 if x > 96
	if x < 111
		x=x+12 if x > 96
	else
		x=x-12
	end
}.pack('C*')