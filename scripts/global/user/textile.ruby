require 'redcloth'

puts RedCloth.new($*.join("\n")).to_html