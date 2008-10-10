def getRDocMethod(classname,methodname)
	require 'open-uri'
	classes = Array.new

	url = open("http://www.viper-7.com/rdoc/fr_class_index.html").read.scan(/<a href="(.+?)">#{classname}<\/a>/)
	url.each {|x| classes.push x.join }
	data = open("http://www.ruby-doc.org/core/#{url}").read
	data.scan(/<td><strong>Parent:<\/strong><\/td>(.+?)<\/td>/im) {|parents|
		parents.join.scan(/<a href="(.+?)">/im) {|parent|
			classes.push classes.first.match(/(.+)\/.+?/)[0].chop + parent.join
		}
	}
	classes.each {|classurl|
		data = open("http://www.viper-7.com/rdoc/#{classurl}").read if classurl != classes.first
		data.scan(/<a name="(.+?)">.+?<span class="method-name">(.+?)<\/span>.+?<div class="m-description">(.+?)(?:<h3>|<\/div>)/im) { |anchor,mnames,mdesc|
			mnames.scan(/(.+?)<br[ \/]*>/im) {|mname|
				if mname.join.match(/\.#{methodname}/im)
					mname = mname.join.gsub(/\n/,'')
					anchor = anchor.gsub(/\n/,'')
					puts "http://www.viper-7.com/rdoc/#{url}\##{anchor} - #{mname}"
					mdesc = mdesc.gsub(/<br[ \/]*>/, "").chomp
					mdesc = mdesc.gsub(/<\/?[^>]*>/, "")
					mdesc = mdesc.gsub(/&[^;]*;/, "")
					count = 0
					mdesc.each_line {|line| 
						exit if count > 6
						count += 1
						line = line.chomp
						puts line if line.gsub(/ /,'').length > 1
					}
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