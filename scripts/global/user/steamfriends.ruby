require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'cgi'

onlinearr=[]
offlinearr=[]

doc = Nokogiri::HTML(open('http://steamcommunity.com/id/' + $*.join('') + '/friends').read)
doc.css('div#memberList').to_s.scan(/<a href="(.*?)"><img src="(.*?)".+?<p><a class=".+?" href=".+?">(.+?)<\/a>.+?<span class="friendSmallText">(.+?)<\/span>/im).each {|profile,img,name,status|
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

puts onlinearr.count.to_s + ' friends Online (not in a game): ' + onlinearr.map{|x| x[:name]}.join(", ") if onlinearr.length > 0
puts offlinearr.count.to_s + " friends Offline: " + offlinearr.map{|x| x[:name]}.join(", ")
