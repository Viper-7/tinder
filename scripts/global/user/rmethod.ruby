x = ""
out = eval("#{ARGV[0]}.methods"
out.each{|y|
	if x.length < 250
		x += ' ' + y
	else
		puts x
		x=""
	end
}