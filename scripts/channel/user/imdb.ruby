require 'open-uri'
require 'mysql'

mysql = Mysql.init()
mysql.connect('cerberus','db','db')
mysql.select_db('viper7')

filename = ""
title = ""
plot = ""
imdburl = ""
tagline = ""
releasedate = ""
rating = 0
text = open("http://www.google.com.au/search?btnI=1&q=" + $*.join("+") + "+site%3Aimdb.com").read

text.scan(/<div id="tn15title">(.*?)<h5>Awards:<\/h5>/m) {|x|
	x[0].scan(/<h1>(.*?) <span>/) { |line|
		title = line.to_s.chomp
	}
	x[0].scan(/<h5>Plot:<\/h5>(.*?)<\/div>/m) { |block|
		block[0].scan(/<a class="tn15more inline" href="(.*?)" onClick="\(new Image\(\)\)/) { |line|
			imdburl = 'http://www.imdb.com' + line.to_s.chomp.gsub(/plotsummary/,'')
		}
		plot = block[0].gsub(/<\/?[^>]*>/, "").chomp
	}
	x[0].scan(/<h5>Tagline:<\/h5>(.*?)(?: <a class="tn15more inline"|<\/div>)/m) { |block|
		tagline = block[0].chomp.gsub(/\n/,'')
	}
	x[0].scan(/<h5>Release Date:<\/h5> (.*?)(?: <a class="tn15more inline"|<\/div>)/m) { |block|
		releasedate = block[0].chomp.gsub(/\n/,'')
	}
	x[0].scan(/<div class="usr rating">.*?<div class="meta">.*?<b>(.*?)<\/b>/m) { |line|
		rating = line[0].chop.to_f
	}
	x[0].scan(/<h5>Plot:<\/h5>(.*?)<\/div>/m) { |block|
		plot = block[0].to_s.chomp
	}
}

puts "Title: #{title} Tagline: #{tagline} Release Date: #{releasedate} Rating: #{rating} Imdburl: #{imdburl}"

# mysql.query('SELECT Filename, Ticket, Quality FROM flvTickets ORDER BY ID DESC LIMIT 1').each do |row|
