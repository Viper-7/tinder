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
		url = URI.parse('http://gdataonline.com/seekhash.php')
		req = Net::HTTP.new(url.host, url.port).start {|http|
			response = http.post('/seekhash.php',"hash=#{md5}",{'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.8) Gecko/20050511 Firefox/1.0.4', 'Referer' => 'http://gdataonline.com/seekhash.php'})
			puts 'made request'
			p response
			response.read_body.scan(/<td width="35%"><b>([^\?<]*)<\/b><\/td>/) {|x|
				output = x
				break
			}
		}
	rescue Exception => ex
		puts ex
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