require 'open-uri'
require 'rubygems'
require 'nokogiri'

onlinearr=[]
offlinearr=[]

doc = Nokogiri::HTML(open('http://steamcommunity.com/id/' + $*.join('') + '/friends').read)
doc.css('div#memberList').scan(/<a href="(.*?)"><img src="(.*?)".+?<p><a class=".+?" href=".+?">(.+?)<\/a>.+?<span class="friendSmallText">(.+?)<\/span>/).each {|profile,img,name,status|
	puts name
}

