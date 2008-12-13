require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'net/http'
require 'uri'
require 'cgi'

output = ''
md5 = $*.first
if md5 == ''
	puts 'Usage: @md5 <string>   - Returns an MD5 hash for the supplied string<BR>'
	puts '       @md5 <md5 hash> - Attempts to decrypt the supplied MD5 hash using an array of methods'
	exit
end

begin
	res = open("http://md5.rednoize.com/?q=#{md5}&xml").read
	doc = Nokogiri::XML(res)
	output = doc.search('//md5:Result/ResultString',{'md5' => 'http://md5.rednoize.com'}).text
rescue Exception => ex
	puts ex
end

if output == ''
	begin
		url = URI.parse('http://gdataonline.com/seekhash.php')
		req = Net::HTTP.new(url.host, url.port).start {|http|
			response = http.post('/seekhash.php',"hash=#{md5}&code=2ea1bc916f1eb31ae417929aff4bf3af",{'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.8) Gecko/20050511 Firefox/1.0.4', 'Referer' => 'http://gdataonline.com/seekhash.php'})
			response.read_body.scan(/<td width="35%"><b>(.*?)<\/b><\/td>/i) {|x|
				output = x
				break
			}
		}
	rescue Exception => ex
		puts ex
	end
end

if output == ''
	begin
		open("http://wordd.org/#{md5}").read.scan(/<h1>(.*?)<\/h1>/) {|x|
			output = x
			break
		}
	rescue
	end
end

if output == ''
	begin
		p open("http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{CGI.escape($*.join)}+site%3Asecure.sensepost.com&num=1").read
		
		# open("http://www.google.com.au/search?btnI=1&q=#{$*.first}+site%3Asecure.sensepost.com",{'Referer'=>'http://www.google.com.au/ig'}).read
	rescue RuntimeError => ex
		ex.to_s =~ /-> (.*)$/
		open($1).read.scan(/(\w*)\s*==>\s*#{md5}/) {|x|
			output = x
			break
		}
	rescue Exception => ex
		puts ex
	end
end

output = 'Decryption Failed :(' if output == ''

puts output