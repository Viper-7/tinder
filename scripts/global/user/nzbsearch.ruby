#!/usr/bin/ruby
require 'open-uri'

def cacheNZB(outLink)
	output = ""
	begin
		timeout(15) do
			@count += 1
			nzb = open(outLink, {'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3', 'Cookie' => 'userZone=-660; uid=104223; pass=ed1303786609789d6cdd24430248d19e; phpbb2mysql_data=a%3A2%3A%7Bs%3A11%3A%22autologinid%22%3Bs%3A32%3A%22b8aa492b883332fd7984001340267ffc%22%3Bs%3A6%3A%22userid%22%3Bs%3A5%3A%2276579%22%3B%7D; phpbb2mysql_sid=1b152ae6c5bf4f3f67a805c7e1a48597;'}).read
                        outLink =~ /^.*\/(.*?)\.nzbdlnzb$/
                        filename = @count.to_s
                        filename = CGI.unescape($1).gsub(/ /,'.') if $1 != nil
			open('/var/www/nzb/' + filename + '.nzb', "w").write(nzb)
			output = 'http://www.viper-7.com/nzb/' + filename + '.nzb'
		end
	rescue Exception => ex
		puts "#{ex} - #{ex.backtrace}"
	end
	output = outLink if output == ""
	return output
end

inStr = open('http://www.nzbsrus.com/nzbbrowse.php?searchwhere=title&search=' + $*.join('+').split(' ').join('+'), {'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3', 'Cookie' => 'userZone=-660; uid=104223; pass=ed1303786609789d6cdd24430248d19e; phpbb2mysql_data=a%3A2%3A%7Bs%3A11%3A%22autologinid%22%3Bs%3A32%3A%22b8aa492b883332fd7984001340267ffc%22%3Bs%3A6%3A%22userid%22%3Bs%3A5%3A%2276579%22%3B%7D; phpbb2mysql_sid=1b152ae6c5bf4f3f67a805c7e1a48597;'}).read
line = inStr.match(/<table class="nzbindex2" cellspacing="0" cellpadding="0">.+?<tr>(.+?)<\/tr>/im)[0]
link = line.match(/<a href="nzbdownload.php\/(.+?)">/im)[0]
title = line.match(/<font class="nzbtitle">(.+?)<\/font>/)[0].gsub(/(?:<[^>]*?>|&[^;]*?;|\n)/,'').chomp
puts title
puts link
