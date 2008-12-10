require 'open-uri'
require 'cgi'

url = $*.join('/').gsub(/ /,'+')
puts open(url).read.gsub(/<[^>]*>/,'')
