require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'net/http'
require 'uri'

output = ''
md5 = $*.first

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

puts output