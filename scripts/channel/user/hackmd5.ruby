require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'net/http'
require 'uri'

output = ''
md5 = $*.first
begin
	doc = Nokogiri::XML(open("http://md5.rednoize.com/?q=#{$*.first}&xml").read)
	output = doc.xpath('//md5/ResultString').text
rescue
end

if output == ''
	puts 'no rednoize'
	begin
		open("http://wordd.org/#{md5}").read.scan(/<h1>(.*?)<\/h1>/) {|x|
			output = x
			break
		}
	rescue
	end
end


if output == ''
	puts 'no wordd'
	begin
		Net::HTTP.post_form(URI.parse('http://gdataonline.com/seekhash.php'),{'hash' => md5, 'code' => '2ea1bc916f1eb31ae417929aff4bf3af'}) {|x|
			output = x
			break
		}
	rescue 
	end
end


if output == ''
	puts 'no gdataonline'
	begin
		open("http://www.google.com.au/search?btnI=1&q=#{$*.first}+site%3Asecure.sensepost.com",{'Referer'=>'http://www.google.com.au/ig'}).read
	rescue RuntimeError => ex
		ex.to_s =~ /-> (.*)$/
		open($1).read.scan(/(\w*)\s*==>\s*#{md5}/) {|x|
			output = x
			break
		}
	end
end

puts output