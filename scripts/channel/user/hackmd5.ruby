require 'open-uri'

text = ''
text2 = ''
begin
	text = open("http://wordd.org/" + $*.first).read
rescue
	begin
		text2 = open("http://www.google.com.au/search?btnI=1&q=#{$*.first}+site%3Asecure.sensepost.com",{'Referer'=>'http://www.google.com.au/ig'}).read
	rescue RuntimeError => ex
		ex =~ /-> (.*)$/
		text2 = open($1.to_s).read
	end
	
	text2.scan(/(\w*)\s*==>/) {|x|
		puts x
		break
	}
end

if text == '' and text2 == ''
	puts 'Decryption failed :('
	exit
end

text.scan(/<h1>(.*?)<\/h1>/) {|x|
	puts x
	break
} if text != ''

#text2.scan(/br>([^<]*)</) {|x|
#	x =~ /(\w*)\s*==>/
#	puts $1 if $1 != nil
#	break
#} if text2 != ''
