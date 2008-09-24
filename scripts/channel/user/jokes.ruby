require 'mysql'

mysql = Mysql.init()
mysql.connect('kodiak','db','db')
mysql.select_db('viper7')

result = mysql.query('SHOW TABLES')
while row = result.fetch_row
	result = mysql.query('SELECT COUNT(*) FROM ' + row).fetch_row
	count = result[0]
	name = row[0]
	puts name.capitalize + ' - ' + count + ' entries'
end
