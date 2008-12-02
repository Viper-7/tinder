require 'rubygems'; require 'open-uri'; require 'rss'; require 'haml'

class RSS::Rss::Channel::Item
	def render
		template = '
%p.item
  .title= title - link
  .description= description
  .date= date'
		print Haml::Engine.new(template).render(self)
	end	
end

rss = RSS::Parser.parse(open('http://www.overclockers.com.au/files/ocau_news.rss').read)
rss.items.each{|item|
	item.render
}
