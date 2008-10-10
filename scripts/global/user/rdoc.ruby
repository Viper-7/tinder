require 'open-uri'

if ARGV[0].match(/^(.+)\.(.+?)$/)
	methodname = $2
	data = open("http://www.ruby-doc.org/core/fr_class_index.html").readlines.join
	url = data.scan(/<a href="(.+?\/#{$1}.+?)">/)
	url = url.first if url.length > 1
	data = open("http://www.ruby-doc.org/core/#{url}").readlines.join
	data = data.scan(/<a name="(.+?)"><\/a>.+?<span class="method-name">(.+?#{methodname}.+?)<br \/>.+?<div class="m-description">(.+?)<h3>/im)
	data.first { |anchor,mname,mdesc|
		puts "http://www.ruby-doc.org/core/#{url}\##{anchor} - #{mname}"
		mdesc = mdesc.gsub(/<br[ \/]*>/, "")
		mdesc = mdesc.gsub(/<\/?[^>]*>/, "")
		mdesc = mdesc.gsub(/&[^;]*;/, "")
		puts mdesc
	}
else
	x = ""
	out = eval("#{ARGV[0]}.methods")
	out.each{|y|
		if x.length < 100
			x += ' ' + y
		else
			puts x
			x=""
		end
	}
end