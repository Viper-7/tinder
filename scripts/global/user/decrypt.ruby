#!/usr/bin/ruby

puts $*.join(' ').unpack('C*').map{|x| x=x-1; if x > 109 then { x=x-12 } else { x=x+12 }}.pack('C*')