require 'mysql'

mysql = Mysql.init()
mysql.connect('kodiak','db','db')
mysql.select_db('viper7')

result = mysql.query('SHOW TABLES')
count = 0
resp = ""
result.each do |row|
        count += 1
        result = mysql.query('SELECT COUNT(*) FROM ' + row[0])
        count2 = result.fetch_row[0]
        name = row[0]
        resp += '| ' + name.capitalize + ' - ' + count2 + ' entries '
        resp += "|\n" if count % 5 == 0
end
resp += "|\n" if count % 5 != 0
puts resp
