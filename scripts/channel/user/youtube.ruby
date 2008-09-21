require 'open-uri'

data = open("http://www.youtube.com/results?search_query=" + $*.join("+"))
data = data.readlines.join
data = data.scan(/<div class="vldescbox".*?>(.*?)<div class="vlclearaltl">/im).first
puts data

