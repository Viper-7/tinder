require 'open-uri'
require 'cgi'
args = CGI.unescape($*.join(' ')).split(' ')

if args.join("") == ""
	puts "@youtube <search string>  : Searches YouTube and returns a random video"
	exit
end

if args.first.chomp == args.first.to_i.to_s.chomp
	count = 0
	limit = args.shift.to_i
	inStr = open("http://www.youtube.com/results?search_query=" + args.join("+")).readlines.join
	inStr.scan(/<div class="vldescbox".*?>(.*?)<div class="vlclearaltl">/im).sort_by{rand}.sort_by{rand}.each {|data|
		count += 1
		break if count > limit
		data.scan(/<div class="vlshortTitle">(.*?)<div class="vllongTitle">/im) { |b|
			b.to_s =~ /<a id=".+?"\s*href="(.+?)"\s*title="(.+?)">/i
			name, link = $2, $1
			
			puts "" + name + " - http://www.youtube.com" + link
		}
	}
else
	data = open("http://www.youtube.com/results?search_query=" + args.join("+")).readlines.join
	data = data.scan(/<div class="vldescbox".*?>(.*?)<div class="vlclearaltl">/im).sort_by{rand}.sort_by{rand}.first.join
	
	data.scan(/<div class="vlshortTitle">(.*?)<div class="vllongTitle">/im) { |b|
		b.to_s =~ /<a id=".+?"\s*href="(.+?)"\s*title="(.+?)">/i
		name, link = $2, $1
		
		puts "" + name + " - http://www.youtube.com" + link
	}
end

