grandtotal=open('/tmp/durationlist.txt','r').each_line.first.to_i
days = (grandtotal / 86400).to_i.to_s
grandtotal = grandtotal % 86400
hours = (grandtotal / 3600).to_i.to_s
grandtotal = grandtotal % 3600
minutes = (grandtotal / 3600).to_i.to_s
seconds = (((grandtotal % 60) * 10).to_i.to_f / 10).to_s
puts "#{days} Days, #{hours} Hours, #{minutes} Minutes, #{seconds} Seconds"
