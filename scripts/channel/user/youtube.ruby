require 'open-uri'

if $*.join("") == ""
	puts "@youtube <search string>  -::- Searches YouTube and returns a random video"
	exit
end

data = open("http://www.youtube.com/results?search_query=" + $*.join("+")).readlines.join
data = data.scan(/<div class="vldescbox".*?>(.*?)<div class="vlclearaltl">/im).sort_by{rand}.sort_by{rand}.first.join

data.scan(/<div class="vlshortTitle">(.*?)<div class="vllongTitle">/im) { |b|
	b.to_s =~ /<a href="(.+?)"  title="(.+?)">/im
	name, link = $2, $1
	
	puts "" + name + " - http://www.youtube.com" + link
}
