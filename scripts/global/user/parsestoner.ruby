require 'open-uri'
require 'mysql'

mysql = Mysql.init()
mysql.connect('kodiak','db','db')
mysql.select_db('viper7')

count=0

while count < 58
	count += 1
	File = open('http://www.weed-forums.com/showthread.php?t=155&page=' + count.to_s).readlines.join
	File.scan(/(?:<div id="post_message_.+">\t*([^<].+)<\/div>)|(?:<div id="post_message_.+">.+?<\/table>\s*<\/div>(.+)<\/div>)/) {|x|
		puts x
		mysql.query('INSERT INTO "stonerjokes" ("Line") VALUES ("' + x + '");')
	}
end
