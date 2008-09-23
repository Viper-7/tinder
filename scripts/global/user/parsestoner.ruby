require 'open-uri'
require 'mysql'

mysql = Mysql.init()
mysql.connect('kodiak','db','db')
mysql.select_db('viper7')
mysql.query("TRUNCATE TABLE stonerjokes")

count=0

while count < 58
	count += 1
	file = open('http://www.weed-forums.com/showthread.php?t=155&page=' + count.to_s).readlines.join
	file.scan(/(?:<div id="post_message_.+">\t*([^<].+)<\/div>)|(?:<div id="post_message_.+">.+?<\/table>\s*<\/div>(.+)<\/div>)/) {|x|
		y = x.to_s.gsub(/<\/?[^>]*>/, "")
		y = y.gsub(/&\/?[^;]{2,6};/,"")
		y = y.gsub(/\"/,'\"')
		y = y.gsub(/^(?:you|u ){0,1}(?:know.{0,7}stoned ){0,1}/i, "")
		y = y.gsub(/^[\.]*(?:when ){0,1}/i, "")
		puts y
		mysql.query('INSERT INTO stonerjokes SET Line="' + y + '";')
	}
	sleep 0.3
end
