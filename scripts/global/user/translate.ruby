require 'open-uri'

inTxt = open('https://www.google.com/uds/Gtranslate?callback=google.language.callbacks.id100&context=22&langpair=%7Ciw&format=text&key=notsupplied&v=1.0&q=' + $*.join('+')).read
result = inTxt.match(/"translatedText":"(.+?)","/)

if result.nil?
	puts 'Failed to translate'
else
	puts result[1]
end
