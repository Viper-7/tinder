require 'open-uri'

lang = 'en'
args = $*.join(' ').split(' ')
t0 = args.shift
if t0.chomp.length == 2
	lang = t0
else
	args.unshift(t0)
end

inTxt = open('http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=' + args.join('+') + '&langpair=%7C' + lang).read
result = inTxt.match(/"translatedText":"(.+?)","/)

if result.nil?
	puts 'Failed to translate'
else
	puts result[1]
end
