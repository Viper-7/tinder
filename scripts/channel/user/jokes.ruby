require 'mysql'

mysql = Mysql.init()
mysql.connect('kodiak','db','db')
mysql.select_db('viper7')

result = mysql.query('SHOW TABLES')
result.each do |row|
        result = mysql.query('SELECT COUNT(*) FROM ' + row[0])
        count = result.fetch_row[0]
        name = row[0]
        puts name.capitalize + ' - ' + count + ' entries'
end
