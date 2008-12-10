require 'open-uri'
require 'cgi'
require 'rubygems'
require 'json'

lang = '|en'
args = $*.join(' ').split(' ')
t0 = args.shift
case t0.chomp.length
	when 5
		lang = t0.tr(/\:/,'|')
	when 2
		lang = '|' + t0
	else
		args.unshift(t0)
end

inTxt = open('http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=' + args.join('+') + '&langpair=' + CGI.escape(lang)).read
inObj = JSON.parse(inTxt)

if inObj['responseData'].nil?
	puts 'Failed to translate'
else
	puts inObj['responseData']['translatedText']
end
