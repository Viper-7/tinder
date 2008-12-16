require 'redcloth'

puts RedCloth.new($*.join(' ')).to_html