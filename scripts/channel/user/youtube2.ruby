require 'open-uri'

data = open("http://www.youtube.com/results?search_query=" + $*.join("+")).readlines.join
data.scan (/<div class="vlshortTitle">.*<a href="(.+?)"  title="(.+?)">.*<div class="vllongTitle">/im){ |link,title|
	puts title + " - " + link
}