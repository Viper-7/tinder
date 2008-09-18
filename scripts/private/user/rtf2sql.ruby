require 'net/http'
require 'uri'

url = URI.parse(ARGV[0])
req = Net::HTTP::Get.new(url.path)
res = Net::HTTP.start(url.host, url.port) {|http|
http.request(req)
}

begin
	File.open('/mnt/kodiakopt/viper-7.com/out.sql', 'w'){|f|
		res.body.each_line {|x| 
			x =~ /^\s(.+?)\s+(.+?)\\.+$/
			if $1 != nil
					outline = "IF NOT (SELECT COUNT(*) FROM NEG-HAS-AIDS WHERE guid=\"#{$1}\") THEN"
					outline += " INSERT INTO 'NEG-HAS-AIDS'"
					outline += " ('guid','alias') values "
					outline += "('" + $1 + "','" + $2 + "')\r\n"
					f.write(outline)
			end
		}
	}
rescue Exception => ex
	puts ex
end
puts 'wrote http://www.viper-7.com/out.sql'
