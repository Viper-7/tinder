require 'open-uri'

data = open("http://www.youtube.com/results?search_query=" + $*.join("+"))
data = data.readlines.join
data = data.scan(/<div class="vldescbox".*?>(.*?)<div class="vlclearaltl">/im).sort_by{rand}.first.join

puts data
data.scan(/<div class="vlshortTitle">(.*?)<div class="vllongTitle">/) { |b|
	puts b
	b=b.to_s
	b =~ /<a href="(.+?)"  title="(.+?)">/
	name, link = $1, $2
	
	puts "" + name + " - http://www.youtube.com" + link
}
