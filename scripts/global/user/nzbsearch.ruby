#!/usr/bin/ruby
require 'open-uri'
require 'cgi'

def cacheNZB(outLink)
	output = ""
	begin
		timeout(15) do
			nzb = open(outLink, {'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3', 'Cookie' => 'userZone=-660; uid=104223; pass=ed1303786609789d6cdd24430248d19e; phpbb2mysql_data=a%3A2%3A%7Bs%3A11%3A%22autologinid%22%3Bs%3A32%3A%22b8aa492b883332fd7984001340267ffc%22%3Bs%3A6%3A%22userid%22%3Bs%3A5%3A%2276579%22%3B%7D; phpbb2mysql_sid=1b152ae6c5bf4f3f67a805c7e1a48597;'}).read
                        filename = CGI.unescape(outLink.match(/^.*\/(.*?)\.nzbdlnzb$/)[1]).gsub(/ /,'.')
			open('/var/www/nzb/' + filename + '.nzb', "w").write(nzb)
			output = 'http://www.viper-7.com/nzb/' + filename + '.nzb'
		end
	rescue Exception => ex
		puts "#{ex} - #{ex.backtrace}"
	end
	output = outLink if output == ""
	return output
end

if $*.join('') == ''
	puts 'Usage: @nzbsearch <search string>'
	puts "Mirrors the top 3 nzb's matching <search string>"
	exit
end

inStr = open('http://www.nzbsrus.com/nzbbrowse.php?searchwhere=title&search=' + $*.join('+').split(' ').join('+'), {'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3', 'Cookie' => 'userZone=-660; uid=104223; pass=ed1303786609789d6cdd24430248d19e; phpbb2mysql_data=a%3A2%3A%7Bs%3A11%3A%22autologinid%22%3Bs%3A32%3A%22b8aa492b883332fd7984001340267ffc%22%3Bs%3A6%3A%22userid%22%3Bs%3A5%3A%2276579%22%3B%7D; phpbb2mysql_sid=1b152ae6c5bf4f3f67a805c7e1a48597;'}).read
outStr = ''
begin
	inStr = inStr.match(/<table class="nzbindex2" cellspacing="0" cellpadding="0">(.+)<p align="center">/im)[1]
	count = 0
	inStr.scan(/<tr>(.+?)<\/tr>/im) {|line|
		next if !line[0].match(/nzbdownload.php/im)
		count += 1
		break if count > 3 or line == nil
		link = 'http://www.nzbsrus.com/nzbdownload.php/' + line[0].match(/<a href="nzbdownload.php\/(.+?)">/im)[1]
		title = line[0].match(/<font class="nzbtitle">(.+?)<\/font>/)[0].gsub(/(?:<[^>]*?>|&[^;]*?;|\n)/,'').chomp
		outStr += "#{title} - #{cacheNZB(link)}\n"
	}
rescue
	outStr = "No Results\n" if outStr == ''
ensure
	puts outStr
end
