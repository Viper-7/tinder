require 'open-uri'
require 'cgi'

url = $*.join('/').tr(';','/')
puts open(url).read.gsub(/<[^>]*>/,'')
