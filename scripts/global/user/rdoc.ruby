if ARGV[0].match(/.+\..+/)
	puts 'woo'
else
	x = ""
	out = eval("#{ARGV[0]}.methods")
	out.each{|y|
		if x.length < 120
			x += ' ' + y
		else
			puts x
			x=""
		end
	}
end