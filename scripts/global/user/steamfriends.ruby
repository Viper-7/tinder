require 'open-uri'
require 'rubygems'
require 'nokogiri'

onlinearr=[]
offlinearr=[]

doc = Nokogiri::HTML(open('http://steamcommunity.com/id/' + $*.join('') + '/friends').read)
p doc.css('div#memberList')

