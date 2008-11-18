require 'open-uri'

text = ''
text2 = ''
begin
	text = open("http://wordd.org/" + $*.first).read
rescue
	text2 = open("http://www.google.com.au/search?btnI=1&q=#{$*.first}+site%3Asecure.sensepost.com").each_line{|x|
		x =~ /(\w*)\s*==>/
		if $1 != nil
			puts $1 
			break
		end
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
