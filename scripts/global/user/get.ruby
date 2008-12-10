require 'open-uri'
require 'cgi'

url = $*.join(' ')
url = url.match(/^(.*)\/(.*?)$/)
puts open(url[1] + '/' + CGI.escape(url[2])).read
