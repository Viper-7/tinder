require 'mysql'

mysql = Mysql.init()
mysql.connect('cerberus','db','db')
mysql.select_db('viper7')

grandtotal=mysql.query("SELECT SUM(duration) FROM imdbfiles GROUP BY duration").fetch_row[0].to_i
days = (grandtotal / 86400).to_i.to_s
grandtotal = grandtotal % 86400
hours = (grandtotal / 3600).to_i.to_s
grandtotal = grandtotal % 3600
minutes = (grandtotal / 60).to_i.to_s
seconds = (grandtotal % 60).to_i.to_s
puts "#{days} Days, #{hours} Hours, #{minutes} Minutes, #{seconds} Seconds"
