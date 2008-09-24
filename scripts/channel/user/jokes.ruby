require 'mysql'

mysql = Mysql.init()
mysql.connect('kodiak','db','db')
mysql.select_db('viper7')

result = mysql.query('SHOW TABLES')
while row = result.fetch_row
	result = mysql.query('SELECT COUNT(*) FROM ' + row)
	count = result.fetch_row[0]
	puts row[0].capitalize + ' - ' + count + ' entries'
end
