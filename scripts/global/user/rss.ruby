require 'rubygems'; require 'open-uri'; require 'rss'; require 'haml'

class RSS::Parser
	def render
		self.items.each{|item|
			sout = ".item
  %a{ :href => '#{item.link}'}
    #{item.title}
  #{item.description}
  #{item.date}"
			puts Haml::Engine.new(sout).render
		}
	end	
end

puts RSS::Parser.parse(open('http://www.overclockers.com.au/files/ocau_news.rss').read).render
}