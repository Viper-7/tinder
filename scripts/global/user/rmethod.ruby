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