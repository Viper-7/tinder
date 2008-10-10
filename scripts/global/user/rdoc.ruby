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
		data.scan(/<a name="(.+?)">.+?<span class="method-name">(.+?)<\/span>.+?<div class="m-description">(.+?)(?:<h3>|<\/div>|<pre>)/im) { |anchor,mnames,mdesc|
			if mnames.include?('<br')
				mnames.scan(/(.+?)<br[ \/]*>/im) {|mname|
					methodcount += 1
					if methodname == ""
						outs = mname.join.gsub(/\n/,'').gsub(/\(.+\)/,'').gsub(/\[.+\]/,'').gsub(/.+\./,'').gsub(/[\!\?]/,'').gsub(/.+\#/,'').split(' ').first.to_s
						outstr += outs + ' ' if outs.length > 1 and !outstr.include?(outs) and !outarr.join.include?(outs)
						if outstr.length > 115; outarr.push outstr; outstr = ''; end
					else
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
					end
				}
			else
				methodcount += 1
				if methodname == ""
					outs = mnames.gsub(/\n/,'').gsub(/\(.+\)/,'').gsub(/\[.+\]/,'').gsub(/.+\./,'').gsub(/[\!\?]/,'').gsub(/.+\#/,'').split(' ').first.to_s
					outstr += outs + ' ' if outs.length > 1 and !outstr.include?(outs) and !outarr.join.include?(outs)
					if outstr.length > 115; outarr.push outstr; outstr = ''; end
				else
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
				end
			end
		}
	}
	if methodname == ""
		outarr.push outstr
		outarr.each {|x|
			puts x.chomp
		}
	else
		puts "No matches from #{hitcount} pages with #{methodcount} methods"
	end
end

if ARGV[0].match(/^(.+)\.(.+?)$/)
	getRDocMethod($1, $2)
else
	getRDocMethod(ARGV[0])
end