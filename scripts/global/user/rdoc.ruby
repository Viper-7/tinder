
def getMethod(classname,methodname)
	require 'open-uri'

	data = open("http://www.ruby-doc.org/core/fr_class_index.html").readlines.join
	url = data.scan(/<a href="(.+?\/#{classname}.+?)">/)
	url = url.first
	data = open("http://www.ruby-doc.org/core/#{url}").readlines.join
	parents = Array.new
	data.scan(/<td><strong>Parent:<\/strong><\/td>(.+?)<\/td>/) {|x|
		p x
		x.scan(/<a href="(.+?)">/) {|y|
			parents.push url[0,url.length - url.reverse.index('/')] + '/' + y
		}
	}
	p parents
	data.scan(/<a name="(.+?)">.+?<span class="method-name">(.+?)<br[ \/]*>.+?<div class="m-description">(.+?)(?:<h3>|<\/div>)/im) { |anchor,mname,mdesc|
		if /#{methodname}\(/i.match(mname)
			puts "http://www.ruby-doc.org/core/#{url}\##{anchor} - #{mname}"
			mdesc = mdesc.gsub(/<br[ \/]*>/, "")
			mdesc = mdesc.gsub(/<\/?[^>]*>/, "")
			mdesc = mdesc.gsub(/&[^;]*;/, "")
		end
	}
end

if ARGV[0].match(/^(.+)\.(.+?)$/)
	puts getMethod($1, $2)
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