require 'rubygems'; require 'open-uri'; require 'rss'; require 'haml'

class RSS::Rss
	def render
		count = 0
		self.items.each{|item|
			sout = "\#item#{count}\n"
			sout += "  .title #{item.link}\n"
			sout += "  .description #{item.description}\n"
			sout += "  .date #{item.date}\n"
			puts Haml::Engine.new(sout).render
			count += 1
		}
	end	
end

RSS::Parser.parse(open('http://www.overclockers.com.au/files/ocau_news.rss').read).render
