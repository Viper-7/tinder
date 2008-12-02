require 'rubygems'; require 'open-uri'; require 'rss'; require 'haml'

class RSS::Rss::Channel::Item
	def render
		sout = "
\#item
  .title= link
  .description= description
  .date= date"
		puts Haml::Engine.new(sout).render(self)
	end	
end

RSS::Parser.parse(open('http://www.overclockers.com.au/files/ocau_news.rss').read).items.each{|item|
	item.render
}