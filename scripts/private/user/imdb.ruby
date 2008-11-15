require 'open-uri'
require 'cgi'
require 'uri'
require 'mysql'
require 'time'
require 'timeout'

mysql = Mysql.init()
mysql.connect('cerberus','db','db')
mysql.select_db('viper7')

parent = Dir.new('/opt/filestore/Movies')
parent.rewind
parent.each{|filename|
	next if filename == '.' or filename == '..' or filename == 'Thumbs.db' or filename == 'movieslist.txt' or filename == 'movieslist' or File.directory? parent.path + '/' + filename

	movie=filename.gsub(/\.[^\.]*$/,'')
	filename = mysql.escape_string(filename).gsub(/\&/,'\\\&').gsub(/ /,'\ ')

	qry = mysql.query("SELECT ID FROM imdbfiles WHERE filename='#{filename}'")
	next if qry.num_rows > 0
	
	
	part = 0
	movie =~ / - ([\d]) of [\d]/
	part = $1.to_i if $1
	movie=movie.gsub(/ - [\d] of [\d]/,'')
	title=movie.gsub(/\'/,'\\\'').gsub(/\&/,'\&')

	path = parent.path + '/' + filename.gsub(/\(/,'\(').gsub(/\)/,'\)')

	duration = `avidentify #{path} 2>/dev/null| grep Duration | cut -f 4 -d ' ' | cut -f 1 -d ,`.chop
	duration = 0 if duration == 'N/A' or duration == ''
	
	duration =~ /([\d]{2}):([\d]{2}):([\d]{2}).([\d])/
	duration = 0
	if $1 and $2 and $3 and $4
		duration = ($1.to_i * 3600) + ($2.to_i * 60) + $3.to_i + ($4.to_f / 10)
	end
	
	imdbid = 0
	qry = mysql.query("SELECT ID FROM imdb WHERE Name='#{title}'")
	imdbid = qry.fetch_row[0] if qry.num_rows > 0 
	if imdbid == 0
		mysql.query("INSERT INTO imdb SET Name='#{title}'")
		imdbid = mysql.insert_id
	end
	
	dbpart = 0
	qry = mysql.query("SELECT MAX(part) FROM imdbfiles WHERE imdbid='#{imdbid}' GROUP BY part")
	dbpart = qry.fetch_row[0] if qry.num_rows > 0
	
	if part > 0
		puts "Adding ID\##{imdbid}: #{movie} - Part #{part} - #{duration} secs"
		mysql.query("DELETE FROM imdbfiles WHERE imdbid='#{imdbid}' AND part=0") if dbpart == 0
	else
		puts "Adding ID\##{imdbid}: #{movie} - #{duration} secs"
		mysql.query("DELETE FROM imdbfiles WHERE imdbid='#{imdbid}'")
	end
	mysql.query("INSERT INTO imdbfiles SET imdbid='#{imdbid}', Filename='#{filename}', Duration=#{duration}, Part=#{part}")
}

qry = mysql.query("SELECT Name FROM imdb where imdburl=''")
qry.each{|movie|
	movie = movie[0]
	tags = Array.new
	boxlink = ""
	title = ""
	plot = ""
	imdburl = ""
	tagline = ""
	releasedate = ""
	rating = 0
	text = ""

	dbtitle = movie.gsub(/\'/,'\\\'').gsub(/\&/,'\\\&')	
	
	puts "Processing video #{movie}"
	3.times do
		begin
			timeout(10) {
				text = open("http://www.google.com.au/search?btnI=1&q=" + URI.escape(movie).gsub(/ /,'+').gsub(/&/,'%26') + "+site%3Aimdb.com").read
			}
		rescue Exception => ex
		end
		break if text.length > 0
	end
	
	text.scan(/<div id="tn15lhs">(.*?)<\/div>/m) {|x|
		x[0].scan(/src="(.*)"/) {|line|
			boxlink = mysql.escape_string(line.to_s.chomp)
		}
	}
	text.scan(/<div id="tn15title">(.*?)(?:<h5>Awards:<\/h5>|<h5>User Comments:<\/h5>)/m) {|x|
		x[0].scan(/<h1>(.*?) <span>/) { |line|
			title = mysql.escape_string(line.to_s.chomp)
		}
		x[0].scan(/<h5>Plot:<\/h5>(.*?)<\/div>/m) { |block|
			block[0].scan(/<a class="tn15more inline" href="(.*?)\/plotsummary" onClick="\(new Image\(\)\)/) { |line|
				imdburl = mysql.escape_string('http://www.imdb.com' + line.to_s.chomp)
			}
			plot = mysql.escape_string(block[0].gsub(/<\/?[^>]*>/, "").chomp)
		}
		x[0].scan(/<h5>Plot Keywords:<\/h5>(.*?)<\/div>/m) { |block|
			block[0].scan(/<[^>]*?>(.*?)<\/a>/) {|line|
				tag = mysql.escape_string(line[0].chomp)
				tags.push tag if tag != 'more'
			}
		}
		x[0].scan(/<h5>Genre:<\/h5>(.*?)<\/div>/m) { |block|
			block[0].scan(/<[^>]*?>(.*?)<\/a>/) {|line|
				tag = mysql.escape_string(line[0].chomp)
				tags.push tag if tag != 'more'
			}
			if imdburl.length == 0
				block[0].scan(/<a class="tn15more inline" href="(.*?)\/keywords" onClick="\(new Image\(\)\)/) { |line|
					imdburl = mysql.escape_string('http://www.imdb.com' + line.to_s.chomp)
				}
			end
		}
		if imdburl.length == 0
			x[0].scan(/"http:\/\/pro.imdb.com\/rg\/maindetails-title\/tconst-pro-header-link(.*?)">More at IMDb Pro/) { |line|
				imdburl = mysql.escape_string('http://www.imdb.com' + line.to_s.chomp)
			}
		end

		x[0].scan(/<h5>Tagline:<\/h5>(.*?)(?: <a class="tn15more inline"|<\/div>)/m) { |block|
			tagline = mysql.escape_string(block[0].chomp.gsub(/\n/,''))
		}
		x[0].scan(/<h5>Release Date:<\/h5> (.*?)(?: <a class="tn15more inline"|<\/div>)/m) { |block|
			begin
				releasedate = Time.parse(block[0].chomp.gsub(/\n/,'').gsub(/\([^\)]*\)/,'')).to_i
			rescue Exception => ex
				releasedate = Time.parse('1 Jan ' + block[0].chomp.gsub(/\n/,'').gsub(/\([^\)]*\)/,'')).to_i if releasedate == 0
			end
		}
		x[0].scan(/<div class="usr rating">.*?<div class="meta">.*?<b>(.*?)<\/b>/m) { |line|
			rating = line[0].chop.to_f
		}
		x[0].scan(/<h5>Plot:<\/h5>(.*?)<\/div>/m) { |block|
			plot = mysql.escape_string(block[0].to_s.chomp)
		}
	}

	movieid = 0
	qry = mysql.query("SELECT ID FROM imdb WHERE Name='#{dbtitle}'")
	if qry.num_rows > 0
		movieid = qry.fetch_row[0]
		if imdburl.length > 0
			duration = mysql.query("SELECT SUM(duration) from imdbfiles WHERE imdbid=#{movieid} GROUP BY imdbid").fetch_row[0]
			mysql.query("UPDATE imdb SET title='#{title}', plot='#{plot}', duration='#{duration}', tagline='#{tagline}', boxurl='#{boxlink}', releasedate='#{releasedate}', rating='#{rating}', imdburl='#{imdburl}' WHERE ID=#{movieid}")
			mysql.query("DELETE FROM imdbtags WHERE imdbid=#{movieid}")
			tags.each {|x|
				x=CGI.unescapeHTML(x.gsub(/&#160;/,'-'))
				mysql.query("INSERT INTO imdbtags SET imdbid=#{movieid}, tag='#{x}'")
			}
		else
			puts "No IMDB Record!"
			mysql.query("DELETE FROM imdbfiles WHERE imdbid=#{movieid}")
			mysql.query("DELETE FROM imdb WHERE ID=#{movieid}")
			mysql.query("DELETE FROM imdbtags WHERE imdbid=#{movieid}")
		end
	else
		puts "Database Error!!"
	end
}

