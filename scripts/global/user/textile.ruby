require 'redcloth'

$*.join("\n").split("\n").each{|x| puts RedCloth.new(x.chomp).to_html }