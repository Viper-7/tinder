require 'redcloth'

$*.join("\n").split("\n").each{|x| puts RedCloth.new(x).to_html }