#!/usr/bin/ruby

puts $*.join(' ').unpack('C*').map{|x| x=x-(x/11).to_i}.pack('C*')