require 'rubygems'; require 'rss'; require 'haml'

class RSS::Rss::Channel::Item
	def render
		template = '
%p.item
  .title= title
  .link= link %br/'
		print Haml::Engine.new(template).render(self)
	end
end

rss = RSS::Parser.parse(open($*.join('+')).read)
count = 0
rss.items.each{|item|
	break if count > 3
	item.render
	count += 1
}
