#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'cgi'
require 'tinderChannelBase.rb'

tinderChannel = TinderChannel.new('www')

get '/*' do
	outStr = ''
	args = params["splat"].first.split('/')
	cmd = args.shift
	cmd = 'help' if cmd == '' or cmd == nil
	args = CGI.unescape(args.join(";")).gsub(/http:;/,'http://')

	outStr = tinderChannel.runCommand(cmd, args, 'www', 'host', ['channel','global','private'])
	
	if outStr[0,7] == 'http://'
		outStr.gsub!(/<[^>]*>/,'').chomp
		redirect outStr
	else
		outStr.gsub!(/(http:\/\/[\w\/\?&]+)/i, "<a href='\1'>\1<\/a>")
		'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>' + "\n" + 
		'<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"><body>' + "\n" + outStr + "\n</body></html>"
	end
end
