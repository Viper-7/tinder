#!/usr/bin/ruby

class String
	def each
		self.split($/).each { |e| yield e }
	end
end

require 'rubygems'
require 'sinatra'
require 'cgi'
require 'tinderChannelBase.rb'

def get_html(params, tinderChannel)
	args = params["splat"].first.gsub('://','##%').gsub('\/','##@').split('/')
	cmd = args.shift
	cmd = 'help' if cmd == '' or cmd == nil
	case cmd
		when /get|rss/
			args = args.join('/')
		when /php/
			args = CGI.unescape(args.join(";\n"))
		when /ruby|tcl/
			args = CGI.unescape(args.join("\n"))
		else
			args = CGI.unescape(args.join(" "))
	end
	
	args.gsub!('##@',"/")
	args.gsub!('##@',"://")
	
	return tinderChannel.runCommand(cmd, args, 'www', 'host', ['channel','global','private'])
end


tinderChannel = TinderChannel.new('www')

get '/xml/*' do
	outStr = get_html(params, tinderChannel)
	outStr
end

get '/*' do
	outStr = get_html(params, tinderChannel)
	
	if outStr[0,7] == 'http://'
		outStr.gsub!(/<[^>]*>/,'')
		redirect outStr.chomp
	else
		outStr.gsub!(/(http:\/\/[\w\/\?&\.\=\_\#\@\!-]+)/i, '<a href="\1">\1</a>') if !outStr.match(/<[^>]*>/)
		if outStr.match(/<html/) 
			outStr
		else
			'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>' + "\n" + 
			'<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"><body>' + "\n" + outStr.gsub(/\n/im,"<BR\/>\n") + "\n</body></html>"
		end
	end
end
