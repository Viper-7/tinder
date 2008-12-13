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
require 'builder'

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

get '/soap/*' do
	outStr = get_html(params, tinderChannel)
	output = []
	
	output['command'] = params['splat'].first
	
	if outStr[0,7] == 'http://' and !outStr.match(/ /)
		outStr.gsub!(/<[^>]*>/,'')
		output['body'] = outStr.chomp
		output['url'] = outStr.chomp
	else
		output['body'] = outStr.gsub(/(http:\/\/[\w\/\?&\.\=\_\#\@\!-]+)/i, '<a href="\1">\1</a>').chomp if !outStr.match(/<[^>]*>/)
		outStr = ''
		
		xml = Builder::XmlMarkup.new( :target => outStr )
		
		xml.instruct! :xml, :version => "1.1", :encoding => "US-ASCII"
		
		xml.tinderResponse do 
			output.each do | name, choice |
				element = xml.tinderResponse( name ) 
				eval("element.#{choice}")
			end
		end

		 '<?xml version="1.0" encoding="utf-8"?>' + "\n" + 
		 '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' + "\n" + 
		 '<soap:Body>' + outStr + '</soap:Body>' + "\n" + 
		 '</soap:Envelope>'
	end
end

get '/*' do
	outStr = get_html(params, tinderChannel)
	
	if outStr[0,7] == 'http://' and !outStr.match(/ /)
		outStr.gsub!(/<[^>]*>/,'')
		redirect outStr.chomp
	else
		outStr.gsub!(/(http:\/\/[\w\/\?&\.\=\_\#\@\!-]+)/i, '<a href="\1">\1</a>') if !outStr.match(/<[^>]*>/)
		if outStr.match(/<html/) 
			outStr
		else
	output['body'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>' + "\n" + 
			 '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">' + "\n<head><title>" + output['command'] + '</title></head>' + "\n" + 
			 '<body>' + "\n" + outStr.gsub(/\n/im,"<BR\/>\n") + "\n</body></html>"
		end
	end
end
