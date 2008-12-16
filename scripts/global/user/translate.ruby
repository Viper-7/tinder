require 'open-uri'
require 'cgi'
require 'rubygems'
require 'json'

if $*.join('') == ''
	puts 'Usage: @translate (foreign text)<BR>'
	puts '	     @translate (from lang):(to lang) (text)<BR>'
	puts 'Eg:    @translate de:fr hallo mein neger'
	exit
end

lang = '|en'
args = $*.join(' ').split(' ')
t0 = args.shift
if t0.chomp.length == 5 and t0[2,1] == ':'
	lang = t0[0,2] + '|' + t0[3,2]
else
	if t0.chomp.length == 2 or (t0.chomp.length == 5 and t0[2,1] == '-')
		lang = '|' + t0
	else
		args.unshift(t0)
	end
end

inTxt = open('http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=' + CGI.escape(args.join(' ')) + '&langpair=' + CGI.escape(lang)).read
inObj = JSON.parse(inTxt)

if inObj['responseData'].nil?
	puts 'Failed to translate'
elsif !inObj['responseData']['translatedText'].ascii_only?
	puts 'Failed to translate'
else
	puts inObj['responseData']['translatedText']
end
