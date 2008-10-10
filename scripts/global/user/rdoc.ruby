def getRDocMethod(classname,methodname="")
	require 'open-uri'
	outarr = Array.new
	outstr = ''
	classes = Array.new
	hitcount = 1
	methodcount = 0
	hit = false
	
	open("http://www.viper-7.com/rdoc/fr_class_index.html").read.scan(/<a href="(.+?)">#{classname}<\/a>/i) {|x| classes.push x.join}
	
	data = open("http://www.viper-7.com/rdoc/#{classes.first}").read; hitcount += 1
	data.scan(/<td><strong>Parent:<\/strong><\/td>(.+?)<\/td>/im) {|parents|
		parents.join.scan(/<a href="(.+?)".*?>/im) {|parent|
			classes.push classes.first.match(/(.+)\/.+?/)[0].chop + parent.join
		}
	}
	
	data.scan(/<div id="includes-list">(.+?)<\/div>/im) {|includes|
		includes.join.scan(/<a href="(.+?)".*?>/im) {|minclude|
			classes.push classes.first.match(/(.+)\/.+?/)[0].chop + minclude.join
		}
	}

	data.scan(/<div id="class-list">(.+?)<\/div>/im) {|children|
		children.join.scan(/<a href="(.+?)".*?>/im) {|child|
			classes.push classes.first.match(/(.+)\/.+?/)[0].chop + child.join
		}
	}

	classes.each {|classurl|
		data = open("http://www.viper-7.com/rdoc/#{classurl}").read if classurl != classes.first
		hitcount += 1 if classurl != classes.first
		data.scan(/<a name="(.+?)">.+?<span class="method-name">(.+?)<\/span>.+?<div class="m-description">(.+?)(?:<h3>|<\/div>)/im) { |anchor,mnames,mdesc|
			if mnames.include?('<br')
				mnames.scan(/(.+?)<br/im) {|mname|
					methodcount += 1
					if mname.join.match(/#{methodname}/im)
						mname = mname.join.gsub(/\n/,'')
						anchor = anchor.gsub(/\n/,'')
						puts "http://www.viper-7.com/rdoc/#{classurl}\##{anchor} - #{mname}"
						mdesc = mdesc.gsub(/\n/,' ').gsub(/<br[ \/]*>/, "\n").gsub(/<p>/,' ').gsub(/<\/p>/, "\n").gsub(/<\/?[^>]*>/, "").gsub(/&[^;]*;/, "").chomp
						count = 0
						mdesc.each_line {|line| 
							exit if count > 4
							count += 1
							line = line.chomp
							puts line[0,399] if line.gsub(/ /,'').length > 1
						}
						exit
					end
					outstr += mname.join.gsub(/\n/,'') + ' ' if methodname == ""
					if outstr.length > 110; outarr.push outstr; outstr = ''; end
				}
			else
				methodcount += 1
				if mnames.match(/#{methodname}/im)
					mname = mnames.gsub(/\n/,'')
					anchor = anchor.gsub(/\n/,'')
					puts "http://www.viper-7.com/rdoc/#{classurl}\##{anchor} - #{mname}"
					mdesc = mdesc.gsub(/\n/,' ').gsub(/<br[ \/]*>/, "\n").gsub(/<p>/,' ').gsub(/<\/p>/, "\n").gsub(/<\/?[^>]*>/, "").gsub(/&[^;]*;/, "").chomp
					count = 0
					mdesc.each_line {|line| 
						exit if count > 4
						count += 1
						line = line.chomp
						puts line[0,399] if line.gsub(/ /,'').length > 1
					}
					exit
				end
				outstr += mnames.gsub(/\n/,'') + ' ' if methodname == ""
				if outstr.length > 110; outarr.push outstr; outstr = ''; end
			end
		}
	}
	if (outarr.first + outstr).length > 1
		outarr.push outstr
		outarr.each {|x|
			puts x.chomp
		}
	end
	puts "No matches from #{hitcount} pages with #{methodcount} methods"
end

if ARGV[0].match(/^(.+)\.(.+?)$/)
	getRDocMethod($1, $2)
else
	getRDocMethod(ARGV[0])
	x = ""
	out = eval("#{ARGV[0]}.methods")
	out = eval("#{ARGV[0].capitalize}.methods") if out.length == 0
	out.each{|y|
		if x.length < 110
			x += ', ' + y
		else
			puts x
			x=""
		end
	}
end