#!/usr/bin/ruby

require 'rubygems'
require 'builder'
require 'sinatra'
require 'cgi'
require 'json'
require 'tinderChannelBase.rb'

class String
	def each
		self.split($/).each { |e| yield e }
	end
end

def get_html(param, tinderChannel)
	args = param.gsub('://','##%').gsub('\/','##@').split('/')
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
	
	return tinderChannel.runCommand(cmd, args, 'www', 'host', ['channel','global','private','system','www'])
end


tinderChannel = TinderChannel.new('www')

get '/text/*' do
	get_html(params['splat'].first, tinderChannel).gsub('<BR[/]*>',"\n").gsub(/<[^>]*>/,'')
end

get '/soap' do
	outStr = get_html('help', tinderChannel)
	outputArr = {}
	
	outputArr['command'] = 'help'
	
	if outStr[0,7] == 'http://' and !outStr.match(/ /)
		outStr.gsub!(/<[^>]*>/,'')
		outputArr['body'] = outStr.chomp
		outputArr['url'] = outStr.chomp
	else
		outputArr['url'] = ''
		outputArr['body'] = outStr.gsub(/(http:\/\/[\w\/\?&\.\=\_\#\@\!-]+)/i, '<a href="\1">\1</a>').chomp if !outStr.match(/<[^>]*>/)
		$outStr = ''
		
		xml = ::Builder::XmlMarkup.new( :target => $outStr, :indent => 0 )
		
		xml.tinderResponseResponse('xmlns'=>'http://tinder.viper-7.com') do 
			xml.command( outputArr['command'], 'xsi:type'=>'xsd:string' )
			xml.url( outputArr['url'], 'xsi:type'=>'xsd:string' )
			xml.body( outputArr['body'], 'xsi:type'=>'xsd:string' )
		end

		 '<?xml version="1.0" encoding="US-ASCII"?>' + "\n" + 
		 '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' + "\n" + 
		 '<soap:Body>' + $outStr + '</soap:Body>' + "\n" + 
		 '</soap:Envelope>'
	end
end

get '/xml/*' do
	outStr = get_html(params['splat'].first, tinderChannel)
	outputArr = {}
	
	outputArr['command'] = params['splat'].first
	
	if outStr[0,7] == 'http://' and !outStr.match(/ /)
		outStr.gsub!(/<[^>]*>/,'')
		outputArr['body'] = outStr.chomp
		outputArr['url'] = outStr.chomp
	else
		outputArr['url'] = ''
		outputArr['body'] = outStr.gsub(/(http:\/\/[\w\/\?&\.\=\_\#\@\!-]+)/i, '<a href="\1">\1</a>').chomp if !outStr.match(/<[^>]*>/)
		$outStr = ''
		
		xml = ::Builder::XmlMarkup.new( :target => $outStr, :indent => 0 )
		
		xml.instruct! :xml, :version => "1.1", :encoding => "utf-8"
		
		xml.tinderResponse do 
			outputArr.each do | name, choice |
				xml.response( choice, 'type'=>name )
			end
		end

		$outStr
	end
end

get '/json/*' do
	outStr = get_html(params['splat'].first, tinderChannel)
	outputArr = {}
	
	outputArr['command'] = params['splat'].first
	
	if outStr[0,7] == 'http://' and !outStr.match(/ /)
		outStr.gsub!(/<[^>]*>/,'')
		outputArr['body'] = outStr.chomp
		outputArr['url'] = outStr.chomp
	else
		outputArr['url'] = ''
		outStr.gsub!(/(http:\/\/[\w\/\?&\.\=\_\#\@\!-]+)/i, '<a href="\1">\1</a>') if !outStr.match(/<[^>]*>/)
		outputArr['body'] = outStr.chomp
		outputArr.to_json
	end
end

get '/*' do
	outStr = get_html(params['splat'].first, tinderChannel)
	
	if outStr[0,7] == 'http://' and !outStr.match(/ /)
		outStr.gsub!(/<[^>]*>/,'')
		redirect outStr.chomp
	else
		outStr.gsub!(/(http:\/\/[\w\/\?&\.\=\_\#\@\!-]+)/i, '<a href="\1">\1</a>') if !outStr.match(/<[^>]*>/)
		if outStr.match(/<html/) 
			outStr
		else
			 '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>' + "\n" + 
			 '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">' + "\n<head><title>" + params['splat'].first + '</title></head>' + "\n" + 
			 '<body>' + "\n" + outStr.gsub(/\n/im,"<BR\/>\n") + "\n</body></html>"
		end
	end
end
