require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'cgi'

onlinearr=[]
offlinearr=[]

doc = Nokogiri::HTML(open('http://steamcommunity.com/id/' + $*.join('') + '/friends').read)
doc.css('div#memberList').to_s.scan(/<a href="(.*?)"><img src="(.*?)".+?<a class=".+?" href=".+?">(.+?)<\/a>.+?<span class="friendSmallText">(.+?)<\/span>/im).each {|profile,img,name,status|
	friend = {}
	friend[:name] = CGI.unescapeHTML(name)
	friend[:avatar] = img
	friend[:url] = profile
	friend[:status] = status
	
	if status == 'Online'
		onlinearr.push friend
	else
		offlinearr.push friend
	end
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
