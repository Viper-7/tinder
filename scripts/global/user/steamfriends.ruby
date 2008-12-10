require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'cgi'

gamesarr={}
onlinearr=[]
offlinearr=[]

doc = Nokogiri::HTML(open('http://steamcommunity.com/id/' + $*.join('') + '/friends',{'Cookie'=>'timezoneOffset=39600,0; steamLogin=76561197969367824%7C%7C51EE8217AA3DFAF8563CF84C41865F8993CF603D'}).read)
doc.css('div#memberList').to_s.scan(/<a href="(.*?)"><img src="(.*?)".+?<a class="linkFriend.+?" href=".+?">(.+?)<\/a>.+?<span class="friendSmallText">(.+?)<\/span>/im).each {|profile,img,name,status|
	friend = {}
	friend[:name] = CGI.unescapeHTML(name)
	friend[:avatar] = img
	friend[:url] = profile
	friend[:status] = status
	friend[:game] = ''
	
	ingame = status.match(/^<span class="linkFriend_in-game">In-Game<br\/>(.+)$/i)
	if ingame
		friend[:status] = 'In-Game'
		friend[:game] = ingame[1]
		gamesarr[ingame[1]] = [] if gamesarr[ingame[1]].nil?
		gamesarr[ingame[1]].push friend
	else
		if status == 'Online'
			onlinearr.push friend
		else
			offlinearr.push friend
		end
	end
}

y=''
gamesarr.each{|z|
	gamesarr[z[0]].each{|x|
		y = y + x[:name] + ", "
	}
	print y[0,y.length - 2]
	if gamesarr[z[0]].count < 3
		print ' is'
	else
		print ' are'
	end
	puts ' playing ' + z[0]
}
y=''
print onlinearr.count.to_s + ' friends Online (not in a game): '
onlinearr.each{|x|
	y = y + x[:name] + ", "
	if y.length > 350
		puts y[0,y.length - 2]
		y = ''
	end
}
puts y[0,y.length - 2]
y=''
print offlinearr.count.to_s + " friends Offline: "
offlinearr.each{|x| 
	y = y + x[:name] + ", "
	if y.length > 350
		puts y[0,y.length - 2]
		y = ''
	end
}
puts y[0,y.length - 2]
