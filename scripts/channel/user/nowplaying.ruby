require 'mysql'

mysql = Mysql.init()
mysql.connect('cerberus','db','db')
mysql.select_db('viper7')

mysql.query('SELECT Filename, Ticket, Quality FROM flvTickets ORDER BY ID DESC LIMIT 1').each do |row|
	row[0] ~ /.*\/(.*?)\..*?/
        puts $1.gsub(/./,' ') + ' - ' + row[2].capitalize + ' Quality FLV - http://viper-7.com/flv?ticket=' + row[1]
end
