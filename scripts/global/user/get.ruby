require 'open-uri'
require 'cgi'

url = $*.join('/').tr(';','/').tr(' ','+')
p open(url)
