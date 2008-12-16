require 'redcloth'

puts $*.join("\n").split("\n").each{|x| RedCloth.new(x).to_html }