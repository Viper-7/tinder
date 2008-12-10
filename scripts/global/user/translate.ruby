require 'open-uri'

lang = 'en'
t0 = $*.shift
if t0.length == 2
	lang = t0
else
	$*.unshift(t0)
end

inTxt = open('https://www.google.com/uds/Gtranslate?callback=google.language.callbacks.id100&context=22&langpair=%7C' + lang + '&format=text&key=notsupplied&v=1.0&q=' + $*.join('+').gsub(/ /,'+')).read
result = inTxt.match(/"translatedText":"(.+?)","/)

if result.nil?
	puts 'Failed to translate'
else
	puts result[1]
end
