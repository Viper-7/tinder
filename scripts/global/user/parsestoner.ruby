require 'open-uri'
require 'mysql'

mysql = Mysql.init()
mysql.connect('kodiak','db','db')
mysql.select_db('viper7')

count=0

while count < 58
	count += 1
	file = open('http://www.weed-forums.com/showthread.php?t=155&page=' + count.to_s).readlines.join
	file.scan(/(?:<div id="post_message_.+">\t*([^<].+)<\/div>)|(?:<div id="post_message_.+">.+?<\/table>\s*<\/div>(.+)<\/div>)/) {|x|
		puts x.to_s
		y = x.to_s.gsub(/<\/?[^>]*>/, "")
		y = y.gsub(/"/,'\"')
		mysql.query('INSERT INTO stonerjokes SET Line="' + y + '";')
	}
	sleep 0.3
end
