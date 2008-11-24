#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'open4'
require 'cgi'
require 'tinderChannelBase.rb'

debug = false
tinderChannel = TinderChannel.new('www')

def popen4(command, mode="t")
	begin
		return status = Open4.popen4(command) do |pid,stdin,stdout,stderr|
			yield stdout, stderr, stdin, pid
			stdout.read unless stdout.eof?
			stderr.read unless stderr.eof?
		end
	rescue Errno::ENOENT => e
		return nil
	end
end

get '/*' do
	out = ''
	args = params["splat"].first.split('/')
	cmd = args.shift
	cmd = 'help' if cmd == ''
	puts cmd
	args = ' ' + CGI.unescape(args.join("/"))

	out = tinderChannel.runCommand(cmd, args, 'www', 'host', ['channel','global','private']).split("\n").join("<BR/>\n")

	if out[0,7] == 'http://'
		redirect out
	else
		out = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>' + out
		out = '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">' + out + '</html>'
		out 
	end
end