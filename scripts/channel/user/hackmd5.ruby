require 'open-uri'

text = ''
text2 = ''
begin
	text = open("http://wordd.org/" + $*.first).read
rescue
	begin
		text2 = open("http://www.google.com.au/search?btnI=1&q=#{$*.first}+site%3Asecure.sensepost.com",{'Referer'=>'http://www.google.com.au/ig'}).read
	rescue RuntimeError => ex
		ex.to_s =~ /-> (.*)$/
		text2 = open($1).read
		
		text2.scan(/(\w*)\s*==>\s*#{$*.first}/) {|x|
			text2 = x
			break
		}
	end
end

if text == '' and text2 == ''
	puts 'Decryption failed :('
	exit
end

text.scan(/<h1>(.*?)<\/h1>/) {|x|
	puts x
	break
} if text != ''

puts text2 if text2 != ''

#text2.scan(/br>([^<]*)</) {|x|
#	x =~ /(\w*)\s*==>/
#	puts $1 if $1 != nil
#	break
#} if text2 != ''
