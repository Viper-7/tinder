require 'open-uri'
require 'mysql'

mysql = Mysql.init()
mysql.connect('kodiak','db','db')
mysql.select_db('viper7')

count=0

while count < 58
	count += 1
	puts count
	file = open('http://www.weed-forums.com/showthread.php?t=155&page=count').readlines.join
	file.scan(/(?:.+?<div id="post_message_".+">([^<].+?).+?)*/) {|x| p x}
end
#	results = mysql.query("
