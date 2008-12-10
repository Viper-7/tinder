require 'open-uri'
require 'cgi'

url = $*.join('/').tr(';','/').tr(' ','+')

puts open(url).read
