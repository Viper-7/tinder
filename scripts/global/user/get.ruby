require 'open-uri'
require 'cgi'

url = $*.join('/')
puts open(url).read.gsub(/<[^>]*>/,'')
