#!/usr/bin/ruby

puts $*.join(' ').unpack('C*').map{|x| x=x+1}.pack('C*')