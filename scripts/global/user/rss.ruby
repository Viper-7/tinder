require 'open-uri'; require 'rss/1.0'; require 'rss/2.0'; require 'haml'

rss = RSS::Parser.parse(open('http://www.overclockers.com.au/files/ocau_news.rss').read)
rss.items.each{|item|
	out = ".item\n"
	out += "  %a{ :href => '#{item.link}' }"
	out += "    #{item.title}"
	out += "  #{item.description}"
	out += "  #{item.date}"
	Haml::Engine.new(out).render
}