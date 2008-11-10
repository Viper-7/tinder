grandtotal=0
open('/tmp/durationlist.txt','r').each_line{ |line|
	line =~ /Duration: (\d{0,2}):(\d{0,2}):(\d{0,2}).(\d?), start/
	hours = $1
	minutes = $2
	seconds = $3
	micro = $4
	totalseconds = (hours.to_i * 60 * 60) + (minutes.to_i * 60) + seconds.to_i + (micro.to_i * 0.1)
	grandtotal += totalseconds
}
days = (grandtotal / 86400).to_i.to_s
grandtotal = grandtotal % 86400
hours = (grandtotal / 3600).to_i.to_s
grandtotal = grandtotal % 3600
minutes = (grandtotal / 3600).to_i.to_s
seconds = (((grandtotal % 60) * 10).to_i.to_f / 10).to_s
puts "#{days} Days, #{hours} Hours, #{minutes} Minutes, #{seconds} Seconds"
