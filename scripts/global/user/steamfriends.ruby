require 'open-uri'
require 'rubygems'
require 'json'

onlinearr=[]
offlinearr=[]
out = open('http://www.k1der.net/country/steamCommunity/steamQuery.php?limit=100&user=' + $*.join('')).read
JSON.parse(out).each {|friend|
	friend['last'] =~ /(\d*):(\d*):(\d*)/
	friend['lastDay'] = ''; friend['lastHour'] = ''; friend['lastMin'] = ''
	if $3 then
		friend['lastDay'] = $1
		friend['lastHour'] = $2
		friend['lastMin'] = $3
		friend['lastTime'] = (($1.to_i * 24) + $2.to_i) * 60 + $3.to_i
	end

	if friend['status'] == 'online' then
		if friend['game'].length > 1
			puts friend['name'] + ' - Online - Playing ' + friend['game']
		else
			onlinearr.push friend['name']
		end
	else
		if friend['lastTime'] > 0 then
			offlinearr.push friend['name']
#			if friend['lastDay'].to_i > 0 then
#				offlinearr.push  friend['name'] + ' for ' + friend['lastDay'] + ' Days'
#			else
#				offlinearr.push  friend['name'] + ' for ' + friend['lastHour'] + ' Hrs, ' + friend['lastMin'] + ' Mins'
#			end
		else
#			puts friend['name'] + ' - Never seen online'
		end
	end
}

puts onlinearr.count.to_s + ' friends Online (not in a game): ' + onlinearr.join(", ") if onlinearr.length > 0
#puts 'Offline: ' + offlinearr.join(" ") if offlinearr.length > 0
puts offlinearr.count.to_s + " friends Offline: " + offlinearr.join(", ")