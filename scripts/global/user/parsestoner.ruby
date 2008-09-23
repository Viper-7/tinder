require 'open-uri'
require 'mysql'

mysql = Mysql.init()
mysql.connect('kodiak','db','db')
mysql.select_db('viper7')
mysql.query("TRUNCATE TABLE stonerjokes")

count=0

while count < 58
	count += 1
	hits1 = 0
	hits2 = 0
	file = open('http://www.weed-forums.com/showthread.php?t=155&page=' + count.to_s).readlines.join
	file.scan(/<div id="post_message_.+">\t*([^<].+)<\/div>/) {|x|
		y = x.to_s.gsub(/<\/?[^>]*>/, "")
		y = y.gsub(/&\/?[^;]{2,6};/,"")
		y = y.gsub(/\"/,'\"')
		y = y.gsub(/^(?:(?:you|u)[^\w]{0,2}){0,1}(?:(?:know|kno|now) you.{0,4}(?:stoned|high)[^\w]{0,2}){0,1}(?:[\.]*(?:when ){0,1}){0,1}/i, "")
		puts y
		hits1 += 1
		mysql.query('INSERT INTO stonerjokes SET Line="' + y + '";')
	}
	file.scan(/<div id="post_message_.{1,6}?"><.+?<\/table>[^\w]*?<\/div>(.+?)<\/div>/im) {|x|
		y = x.to_s.gsub(/<\/?[^>]*>/, "")
		y = y.gsub(/&\/?[^;]{2,6};/,"")
		y = y.gsub(/\"/,'\"')
		y = y.gsub(/^(?:(?:you|u)[^\w]{0,2}){0,1}(?:(?:know|kno|now) you.{0,4}(?:stoned|high)[^\w]{0,2}){0,1}(?:[\.]*(?:when ){0,1}){0,1}/i, "")
		puts y
		hits2 += 1
		mysql.query('INSERT INTO stonerjokes SET Line="' + y + '";')
	}
	puts "#{hits1},#{hits2} hits this poll \##{count}"
	sleep 0.3
end
