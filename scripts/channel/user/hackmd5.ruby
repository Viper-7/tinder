require 'open-uri'

text = open("http://wordd.org/" + $*.first).read
text.scan(/<h1>(.*?)<\/h1>/) {|x|
	puts x
	break
}