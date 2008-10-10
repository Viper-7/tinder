def getRDocMethod(classname,methodname)
	require 'open-uri'
	classes = Array.new

	url = open("http://www.ruby-doc.org/core/fr_class_index.html").read.scan(/<a href="(.+?)">#{classname}<\/a>/)
	url.each {|x| classes.push x.join }
	data = open("http://www.ruby-doc.org/core/#{url}").read
	data.scan(/<td><strong>Parent:<\/strong><\/td>(.+?)<\/td>/im) {|x|
		x.join.scan(/<a href="(.+?)">/im) {|y|
			classes.push classes.first.match(/(.+)\/.+?/)[0].chop + y.join
		}
	}
	classes.each {|classurl|
		puts "Scanning http://www.ruby-doc.org/core/#{classurl}"
		data = open("http://www.ruby-doc.org/core/#{classurl}").read if classurl != url
		data.scan(/<a name="(.+?)">.+?<span class="method-name">(.+?)<\/span>.+?<div class="m-description">(.+?)(?:<h3>|<\/div>)/im) { |anchor,mnames,mdesc|
			mnames.scan(/(.+?)<br[ \/]>/im) {|mname|
				if mname.match(/#{methodname}\(/i)
					puts "http://www.ruby-doc.org/core/#{url}\##{anchor} - #{mname}".chomp
					mdesc = mdesc.gsub(/<br[ \/]*>/, "").chomp
					mdesc = mdesc.gsub(/<\/?[^>]*>/, "")
					mdesc = mdesc.gsub(/&[^;]*;/, "")
					mdesc.each_line {|x| puts x if x.length > 2 }
					exit
				end
			}
		}
	}
end

if ARGV[0].match(/^(.+)\.(.+?)$/)
	getRDocMethod($1, $2)
else
	x = ""
	out = eval("#{ARGV[0]}.methods")
	out.each{|y|
		if x.length < 110
			x += ', ' + y
		else
			puts x
			x=""
		end
	}
end