require 'rubygems'; require 'open-uri'; require 'rss'; require 'haml'

class RSS::Rss
	def render
		count = 0
		self.items.each{|item|
			sout = "
\#item#{count}
  .title= link
  .description= description
  .date= date"
			puts Haml::Engine.new(sout).render(item)
			count += 1
		}
	end	
end

RSS::Parser.parse(open('http://www.overclockers.com.au/files/ocau_news.rss').read).items.each{|item|
	puts item.class
#	item.render
}