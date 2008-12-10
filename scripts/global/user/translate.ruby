require 'open-uri'
require 'cgi'

lang = '|en'
args = $*.join(' ').split(' ')
t0 = args.shift
case t0.chomp.length
	when 5
		lang = t0
	when 2
		lang = '|' + t0
	else
		args.unshift(t0)
end

inTxt = open('http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=' + args.join('+') + '&langpair=' + CGI.escape(lang)).read
result = inTxt.match(/"translatedText":"(.+?)","/)

if result.nil?
	puts 'Failed to translate'
else
	puts result[1]
end
