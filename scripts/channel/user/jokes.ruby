mysql = Mysql.init()
mysql.connect('kodiak','db','db')
mysql.select_db('viper7')

result = mysql.query('SHOW TABLES')
while result.fetch_row {|row|
	count = mysql.query('SELECT COUNT(*) FROM ' + row).fetch_row
	puts row.capitalize + ' - ' + count + ' entries'
}
