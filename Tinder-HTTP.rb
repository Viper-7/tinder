#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'cgi'
require 'tinderChannelBase.rb'

tinderChannel = TinderChannel.new('www')

get '/*' do
	out = ''
	args = params["splat"].first.split('/')
	cmd = args.shift
	cmd = 'help' if cmd == '' or cmd == nil
	args = CGI.unescape(args.join("/"))

	out = tinderChannel.runCommand(cmd, args, 'www', 'host', ['channel','global','private']).split("\n").join("<BR/>\n")
	
	while out.match(/\002/)
		out.scan(/^([^\002]*)\002([^\002]*)(?:\002|$)([^\002]*)$/) {|x,y,z|
			z = '' if z == nil
			out = x + '<B>' + y + '</B>' + z
		}
	end
	
	if out[0,7] == 'http://'
		redirect out
	else
		'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>' + "\n" + 
		'<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"><body>' + "\n" + out + "\n</body></html>"
	end
end