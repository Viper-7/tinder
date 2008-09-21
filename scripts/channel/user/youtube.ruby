require 'open-uri'

data = open("http://www.youtube.com/results?search_query=" + $*.join("+"))
data = data.readlines.join
data = data.scan(/<div class="vldescbox".*?>(.*?)<div class="vlclearaltl">/im).sort_by{rand}.sort_by{rand}.first.join

data.scan(/<div class="vlshortTitle">(.*?)<div class="vllongTitle">/im) { |b|
	b=b.to_s
	b =~ /<a href="(.+?)"  title="(.+?)">/im
	name, link = $2, $1
	
	puts "" + name + " - http://www.youtube.com" + link
}
