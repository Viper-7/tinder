#!/usr/bin/ruby

puts $*.join(' ').unpack('C*').map{|x| x=x-(x/21).to_i}.pack('C*')