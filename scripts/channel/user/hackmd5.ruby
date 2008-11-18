require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'net/http'
require 'uri'

output = ''
md5 = $*.first
begin
	res = open("http://md5.rednoize.com/?q=#{md5}&xml").read
	puts res
	doc = Nokogiri::XML(res)
	output = doc.xpath('//md5:Result/ResultString').text
rescue Exception => ex
	puts ex
end



puts output