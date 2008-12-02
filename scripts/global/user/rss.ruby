require 'rubygems'; require 'open-uri'; require 'rss'; require 'haml'

rss = RSS::Parser.parse(open('http://www.overclockers.com.au/files/ocau_news.rss').read)
rss.items.each{|item|
	out = ".item\n"
	out += "  %a{ :href => '#{item.link}' }"
	out += "    #{item.title}"
	out += "  #{item.description}"
	out += "  #{item.date}"
	puts Haml::Engine.new(out).render
}