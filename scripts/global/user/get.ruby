require 'open-uri'
require 'cgi'

url = $*.join('/').gsub(/\s/,'+')
puts open(url).read.gsub(/<[^>]*>/,'')
