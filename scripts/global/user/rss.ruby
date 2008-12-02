require 'rubygems'; require 'open-uri'; require 'rss'; require 'haml'

rss = RSS::Parser.parse(open('http://www.overclockers.com.au/files/ocau_news.rss').read)
rss.items.each{|item|
sout << END
.item
  %a{ :href => '#{item.link}'}
    #{item.title}
  #{item.description}
  #{item.date}
END
puts Haml::Engine.new(sout).render
}