require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'net/http'
require 'uri'

output = ''
md5 = $*.first
begin
	doc = Nokogiri::XML(open("http://md5.rednoize.com/?q=#{md5}&xml").read)
	output = doc.xpath('//md5/ResultString').text
rescue Exception => ex
	puts ex
end



puts output