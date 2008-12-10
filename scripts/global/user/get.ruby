require 'open-uri'
require 'cgi'

url = $*.join('/').tr(';','/').tr(' ','+')
puts url
puts open(url).read.gsub(/<[^>]*>/,'')
