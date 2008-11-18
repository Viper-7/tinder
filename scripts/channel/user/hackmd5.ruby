require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'net/http'
require 'uri'


if output == ''
	begin
		open("http://wordd.org/#{md5}").read.scan(/<h1>(.*?)<\/h1>/) {|x|
			output = x
			break
		}
	rescue
	end
end



puts output