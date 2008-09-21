require 'open-uri'

data = open("http://www.youtube.com/results?search_query=" + $*.join("+"))
puts DATA
data.each_line { |line| 
	line.scan(/<li class=g>(.*?)<\/div><\/div><br/) { |a|
		a[0].scan(/<h3 class=r>(.*?)<cite>/) { |b|
			b=b.to_s
			b =~ /class=l>(.*?)<\/a><\/h3>/
			name = $1
			b =~ /<div class="s">(.*?)<br>/
			desc = $1
			b =~ /<a href="(.*?)" class=l>/
			link = $1
			
			name = name.to_s.gsub(/<\/?[^>]*>/, "")
			name = name.to_s.gsub(/&[^;]*;/, "")
			desc = desc.to_s.gsub(/<\/?[^>]*>/, "")
			desc = desc.to_s.gsub(/&[^;]*;/, "")
			desc = desc.to_s.gsub(/\([^\)]*\)/, "")
			desc = desc.to_s.gsub(/[.]*/, "")

			puts "" + name + " - " + desc
			puts link
		}
	}
}
