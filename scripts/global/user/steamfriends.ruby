require 'open-uri'
require 'rubygems'
require 'nokogiri'

onlinearr=[]
offlinearr=[]

doc = Nokogiri::HTML(open('http://steamcommunity.com/id/' + $*.join('') + '/friends').read)
p doc.xpath('//html/body/center///div/div')

