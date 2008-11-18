require 'open-uri'

text = ''
text2 = ''
begin
	text = open("http://wordd.org/" + $*.first).read

	text.scan(/<h1>(.*?)<\/h1>/) {|x|
		puts x
		break
	}
rescue
	begin
		text2 = open("http://www.google.com.au/search?btnI=1&q=#{$*.first}+site%3Asecure.sensepost.com",{'Referer'=>'http://www.google.com.au/ig'}).read
	rescue RuntimeError => ex
		ex.to_s =~ /-> (.*)$/
		text2 = open($1).read
		
		text2.scan(/(\w*)\s*==>\s*#{$*.first}/) {|x|
			puts x
			break
		}
	end
end