require 'open-uri'

begin
	open("http://wordd.org/" + $*.first).read.scan(/<h1>(.*?)<\/h1>/) {|x|
		puts x
		break
	}
rescue
	begin
		open("http://www.google.com.au/search?btnI=1&q=#{$*.first}+site%3Asecure.sensepost.com",{'Referer'=>'http://www.google.com.au/ig'}).read
	rescue RuntimeError => ex
		ex.to_s =~ /-> (.*)$/
		open($1).read.scan(/(\w*)\s*==>\s*#{$*.first}/) {|x|
			puts x
			break
		}
	end
end