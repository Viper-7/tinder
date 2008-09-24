require 'open-uri'
require 'mysql'

mysql = Mysql.init()
mysql.connect('kodiak','db','db')
mysql.select_db('viper7')
mysql.query("TRUNCATE TABLE drunkjokes")

file = open('http://www.viper-7.com/drunk.txt').readlines
file.each {|x|
	mysql.query('INSERT INTO drunkjokes SET Line="' + x + '";')
}
