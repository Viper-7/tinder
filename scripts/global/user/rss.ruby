require 'rubygems'; require 'open-uri'; require 'rss'; require 'haml'

class RSS::Rss
	def render
		count = 0
		self.items.each{|item|
			count += 1
			sout = "#item#{count}
  .title= #{item.link}}
  .description= #{item.description}
  .date= #{item.date}"
			puts Haml::Engine.new(sout).render
		}
	end	
end

puts RSS::Parser.parse(open('http://www.overclockers.com.au/files/ocau_news.rss').read).render
