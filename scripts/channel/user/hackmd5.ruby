require 'open-uri'

text = ''
begin
	text = open("http://wordd.org/" + $*.first).read
rescue
end
text.scan(/<h1>(.*?)<\/h1>/) {|x|
	puts x
	break
}