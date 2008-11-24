require 'drb'
require 'net/http'
require 'socket'
require 'timeout'
require 'find'
require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'mysql'
require 'uri'
require 'cgi'
require 'date'
require 'rubygems'
require 'open4'
require 'nokogiri'

STDOUT.sync = true
tinderChannels = Array.new

DRb.start_service

module Net
  class HTTP
    def HTTP.get_with_headers(uri, headers=nil)
      uri = URI.parse(uri) if uri.respond_to? :to_str
      start(uri.host, uri.port) do |http|
        return http.get(uri.path, headers)
      end
    end
  end
end

class TinderChannel
    include DRbUndumped

    attr_accessor :channel, :tinderBot, :nick, :graceful, :uptime, :adminHosts
    attr_accessor :dirWatchers, :rssWatchers, :dumpnicks, :mysql, :ping

    def initialize(channel)
	@dirWatchers = Array.new
	@rssWatchers = Array.new
	@adminHosts = Array.new
        @channel = channel
        @graceful = false
    	@dumpnicks = Array.new
    	@uptime = 0

	@mysql = Mysql.init()
	@mysql.connect('cerberus','db','db')
	@mysql.select_db('viper7')
    end

    def setTinderBot(tinderBot)
        @tinderBot = tinderBot
    	@tinderBot.addChannel(self)
    end

    def popen4(command, mode="t")
	begin
		return status = Open4.popen4(command) do |pid,stdin,stdout,stderr|
			yield stdout, stderr, stdin, pid
			stdout.read unless stdout.eof?
			stderr.read unless stderr.eof?
		end
	rescue Errno::ENOENT => e
		# On windows executing a non existent command does not raise an error
		# (as in unix) so on unix we return nil instead of a status object and
		# on windows we try to determine if we couldn't start the command and
		# return nil instead of the Process::Status object.
		return nil
	end
    end

    def checkPing
	if @ping
	else
		@tinderBot.status 'Ping Timeout - Restarting Server'
		@tinderBot.halt
	end
    end

    def clearPing
    	@ping = false
    end

    def ping
	@ping = true
    end

    def poll
    	@uptime += 1
    	@uptime = 5 if @uptime > 964
    	begin
		@dirWatchers.each{|x| x.poll} if @uptime % 20 == 0
		@rssWatchers.each{|x| x.poll} if @uptime % 960 == 0
		@tinderBot.clearPing if @ping and (@uptime + 230) % 240 == 0
		checkPing if (@uptime + 1) % 240 == 0
	rescue Exception => ex
		@tinderBot.status ex
	end
    end

    def memUsage
	response = %x[ps -eo 'cputime,%cpu,%mem,vsz,sz,command']
	output = ""
	response.each_line {|x|
		z = ""
		x = x.gsub(/  /,' ')
		x = x.split(/ /)
		x.each {|y|
			z += ' . ' + y.rjust(4, '0')
		}

		z = z.gsub(/\.\.\./, ' . ')
		z =~ /(.+?)tinder(.+)/
		if $1 != nil
			output = "#{$1}tinder#{$2}"
		end
	}
	output = "Client Fail" if output == ""

	return output[3..-1]
    end

    def shutDown()
	if @graceful == true
	else
		exit
	end
    end

    def sendChannel(msg)
	lines=0
	msg.each_line{|line| lines += 1; @tinderBot.status "Channel>: \##{@channel} <#{@nick}> #{line}"}
    	@tinderBot.sendChannel msg, @channel
    end

    def sendPrivate(msg, nick)
	lines=0
	msg.each_line{|line| lines += 1; @tinderBot.status "Private>: <#{@nick}> -> <#{nick}> #{line}"}
    	@tinderBot.sendPrivate msg, nick
    end

    def sendPrivateAction(msg, nick)
	lines=0
	msg.each_line{|line| lines += 1; @tinderBot.status "Action >: <#{@nick}> -> <#{nick}> #{line}"}
    	@tinderBot.sendCTCP "ACTION #{msg}", nick
    end

    def sendChannelAction(msg)
	lines=0
	msg.each_line{|line| lines += 1; @tinderBot.status "Action >: \##{@channel} <#{@nick}> #{line}"}
    	@tinderBot.sendCTCP "ACTION #{msg}", "\##{@channel}"
    end

    def sendCTCP(msg, nick)
	lines=0
	msg.each_line{|line| lines += 1; @tinderBot.status "CTCP   >: <#{@nick}> -> <#{nick}> #{line}"}
    	@tinderBot.sendCTCP msg, nick
    end

    def connected
    	@nick = @tinderBot.nick
    end

    def serverText(msg)
    end

    def help(commandtypes)
    	lines = ""
    	commandtypes.each{|z|
    		response = z.capitalize + ' Commands: '
    		folders = ["/opt/tinderBot/scripts/#{z}/builtin","/opt/tinderBot/scripts/#{z}/user"]
	    	for folder in folders
	    		Find.find(folder) do |path|
	    			if FileTest.directory?(path)
					next
	    			else
					next if !path.include? '.'
					next if path.include? '.svn'
	    				begin
		    				path =~ /^.+\/(.+?)\.(.+)/
		    				ext = $2
		    				filename = $1
		    				response += '@' + filename + ' '
	    				rescue
	    				end
	    			end
	    		end
	    	end

		if z == "global"
		    	response += '@php @ruby @tcl '
		end

	    	if z == "channel"
		    	dirNames = Array.new
		    	@dirWatchers.each do |x|
		    		dirNames.push x.name if !dirNames.include? x.name
		    	end
			dirNames.each{|x| response += '@' + x.downcase + ' '}

		    	rssTypes = Array.new
		    	@rssWatchers.each do |x|
		    		rssTypes.push x.type if !rssTypes.include? x.type
		    	end
			rssTypes.each{|x| response += '@' + x.downcase + ' '}
			response += '@quote @addquote '
		end

	    	lines += response + "\n"
	}
	lines += 'Type a command to see its usage'
	return lines
    end

    def customCommands
	return 'dump'
    end

    def runCommand(command, args, nick, host, commandtypes)
    	response = ""
    	hit = false
    	commandtypes.each{|z|
    		folders = ["/opt/tinderBot/scripts/#{z}/builtin","/opt/tinderBot/scripts/#{z}/user"]
	    	for folder in folders
	    		Find.find(folder) do |path|
	    			if FileTest.directory?(path)
					next
	    			else
					next if !path.include? '.'
					next if path.include? '.svn'
	    				path =~ /^(.+)\.(.+)/
	    				ext = $2
	    				filename = $1

	    				if command.chomp == File.basename(filename.downcase)
	    					hit = true

	    					args = args.gsub(/\|/, ':')
	    					args = args.gsub(/\//, '\/')
	    					args = args.gsub(/\!/, '\!')
	    					args = args.gsub(/\?/, '\?')
	    					args = args.gsub(/\[/, '\[')
	    					args = args.gsub(/\]/, '\]')
	    					args = args.gsub(/\(/, '\(')
	    					args = args.gsub(/\)/, '\)')
	    					args = args.gsub(/\"/, '\"')
	    					args = args.gsub(/\'/, "\\\'")
	    					args = args.gsub(/wget/, 'wgot')
	    					lang = ext

	    					ENV['IIBOT_DIR'] = filename.match(/^(.+)\/.+?\/.+?\/.+?$/)[1] # iiBot script compatibilty
	    					ENV['IIBOT_TEMP_DIR'] = ENV['IIBOT_DIR'] + '/tmp'
	    					ENV['IIBOT_SCRIPT_DIR'] = ENV['IIBOT_DIR'] + '/scripts'

						if command.chomp == "bf"
							args =~ /^(.+?) (.+)$/
							if !($2.nil? rescue true)
								args = $1 + '" "' + $2
							end
							args = '"' + args + '"'
						end
	    					if args.length > 0
						    	args = args.gsub(/\|/,':')
	    						cmdline = "#{lang} #{filename}.#{ext} #{args}" + ' 2>&1'
	    					else
	    						cmdline = "#{lang} #{filename}.#{ext}" + ' 2>&1'
	    					end

	    					@tinderBot.status "Exec    : '" + cmdline + "'" if @tinderBot
						
						popen4(cmdline) {|stdout, stderr, stdin, pipe|
							begin
								timeout(45) do
									response = stdout.readlines.join("").to_s
									response = stderr.readlines.join("").to_s if response == ""
								end
							rescue Exception => ex
								Process.kill 'KILL', pipe
								response = "Command timed out - " + ex.to_s
							ensure
								response = "No Output." if response == ""
							end
						}
	    				end
	    			end
	    		end
	    	end
	}
	case command.chomp
		when /^php$/
			if args == ""
				response = 'Usage: @php <code to run>' + "\n"
				response += 'Eg: @php echo "hi";'
			else
				args = args.gsub(/rm/, 'rn') # Disable a few nasty low level php commands
				args = args.gsub(/eval/, 'evel')
				args = args.gsub(/exec/, 'exac')
				args = args.gsub(/fork/, 'fark')
				args = args.gsub(/mail/, 'm@il')
				args = args.gsub(/\[\\n\]/, "\n")
				args = "<?php\n" + args + "\n?>"

				File.open('/tmp/tinderScript', 'w') {|f| f.write(args) }

				popen4('php /tmp/tinderScript') {|stdout, stderr, stdin, pipe|
					begin
						timeout(5) do
							response = stdout.readlines.join("\n").to_s
							response = stderr.readlines.join("\n").to_s if response == ""
						end
					rescue Exception => ex
						Process.kill 'KILL', pipe
						response = "Command timed out - " + ex.to_s
					ensure
						response = "No Output." if response == ""
					end
				}
			end
		when /^ruby$/
			if args == ""
				response = 'Usage: @ruby <code to run>' + "\n"
				response += 'Eg: @ruby puts "hi"'
			else
				args = args.gsub(/rm/, 'rn')
				args = args.gsub(/exec/, 'exac')
				args = args.gsub(/fork/, 'fark')
				args = args.gsub(/mail/, 'm@il')
				args = args.gsub(/\[\\n\]/, "\n")

				File.open('/tmp/tinderScript', 'w') {|f| f.write(args) }

				popen4('ruby /tmp/tinderScript') {|stdout, stderr, stdin, pipe|
					begin
						timeout(5) do
							response = stdout.readlines.join("").to_s
							response = stderr.readlines.join("").to_s if response == ""
						end
					rescue Exception => ex
						Process.kill 'KILL', pipe
						response = "Command timed out - " + ex.to_s
					ensure
						response = "No Output." if response == ""
					end
				}
			end
		when /^tcl$/
			if args == ""
				response = 'Usage: @tcl <code to run>' + "\n"
				response += 'Eg: @tcl puts hi'
			else
				args = args.gsub(/rm/, 'rn')
				args = args.gsub(/exec/, 'exac')
				args = args.gsub(/fork/, 'fark')
				args = args.gsub(/mail/, 'm@il')
				args = args.gsub(/\[\\n\]/, "\n")

				File.open('/tmp/tinderScript', 'w') {|f| f.write(args) }

				popen4('tclsh /tmp/tinderScript') {|stdout, stderr, stdin, pipe|
					begin
						timeout(5) do
							response = stdout.readlines.join("\n").to_s
							response = stderr.readlines.join("\n").to_s if response == ""
						end
					rescue Exception => ex
						Process.kill 'KILL', pipe
						response = "Command timed out - " + ex.to_s
					ensure
						response = "No Output." if response == ""
					end
				}
			end
		when /^mem$/
			usage = memUsage
			response = response + usage
		when /^help$/
			response = help(commandtypes)
		when /^#{customCommands}/
			hit = true
		when /^dump/
			hit = true
		when /^stopdump$/
			hit = true
	end

	response = "Command not found" if response == "" and hit == false

	aOut = Array.new
	hit = false

	begin
		@dirWatchers.each do |x|
			if /^#{command.chomp}$/i.match(x.name)
				if args.match(/^random$/i)
					resp = x.random
					if resp.length > 1
						aOut.push resp
						hit = true
					end
				elsif args.length > 1 and !args.match(/^latest$/)
					resp = x.search args
					if resp.length > 1
						aOut.push resp
						hit = true
					end
				else
					resp = x.latest
					if resp.length > 1
						aOut.push resp
						hit = true
					end
				end
			end
		end
		if hit == true
			if args.length == 0 or args.match(/^latest$/)
				begin
					aOut.sort_by{|x| x =~ /.+?\|(.+)/; $1}
					aOut.first =~ /(.+?)\|.+/
					response = $1
				rescue
					response = aOut.first
				end
			else
				response = aOut.sort_by{rand}.first.to_s
			end
		end
	rescue Exception => ex
		response = ex.to_s
	end
	resp = ""
	count = 0
	rsshit = false
	begin
		@rssWatchers.each do |x|
			if x.type.match(/^#{command.chomp}$/i)
				rsshit = true
				case args
					when /^latest$/i
						resp2 = x.latest
						resp = resp2 if resp2 != ""
					when /(listallow|list)/
						resp = x.listallow
					when /listignore/
						resp = x.listignore
					when /^(.+?) is (?:shit|bad|poo|terrible|crap|gay|ass|fail|no good|stupid|retarded)/i
						args = $1.gsub(/ /,'.')
						result = @mysql.query("SELECT COUNT(*) FROM #{x.type}allow WHERE Line LIKE \"#{args}\"")
						z = result.fetch_row[0]
						if z != "0" or args[-1,1] == '!'
							@mysql.query("DELETE FROM #{x.type}allow WHERE Line LIKE \"#{args}\"")
							resp = "Stopped Allowing #{args}"
						end
						if z == "0" or args[-1,1] == '!'
							result = @mysql.query("SELECT COUNT(*) FROM #{x.type}ignore WHERE Line LIKE \"#{args}\"")
							if result.fetch_row[0] == "0" or args[-1,1] == '!'
								@mysql.query("INSERT INTO #{x.type}ignore SET Line=\"#{args}\"")
								resp = "Started Ignoring #{args}"
							else
								resp = "Already Ignoring #{args}"
							end
						end
						@tinderBot.status "Status  : Refreshed #{x.refresh} #{x.type} rules" if @tinderBot
						break
					when /^(.+?) is (?:good|fine|ok|sick|cool|mad|orsm|grouse|grouce|awesome|great|mine)$/i
						args = $1.gsub(/ /,'.')
						result = @mysql.query("SELECT COUNT(*) FROM #{x.type}ignore WHERE Line LIKE \"#{args}\"")
						z = result.fetch_row[0]
						if z != "0" or args[-1,1] == '!'
							@mysql.query("DELETE FROM #{x.type}ignore WHERE Line LIKE \"#{args}\"")
							resp = "Stopped Ignoring #{args}"
						end
						if z == "0" or args[-1,1] == '!'
							result = @mysql.query("SELECT COUNT(*) FROM #{x.type}allow WHERE Line LIKE \"#{args}\"")
							if result.fetch_row[0] == "0" or args[-1,1] == '!'
								@mysql.query("INSERT INTO #{x.type}allow SET Line=\"#{args}\"")
								resp = "Started Allowing #{args}"
							else
								resp = "Already Allowing #{args}"
							end
						end
						@tinderBot.status "Status  : Refreshed #{x.refresh} #{x.type} rules" if @tinderBot
						break
					when /help/
						resp = x.help
					when /^$/
						resp = "count"
						count += x.count
					else
						resp2 = x.search args
						resp = resp2 if resp != ''
						break if resp.match(/http/i)
				end
			end
		end
		resp = "#{args} was not found in recent #{command.chomp}'s, the PreDB, or the EZTV Calendar" if resp == "" and rsshit
	rescue Exception => ex
		resp = ex.to_s
	end
	resp = "#{count.to_s} #{command.chomp}'s indexed - '@#{command.chomp} help' for help" if resp == "count"
	response = resp if resp != ""
	@tinderBot.status "Output  : " + response if @tinderBot
	return response
    end

    def channelEvent(channel, host, nick, event, msg)
    	case event
    		when /^MODE/
		    	@tinderBot.status "#{event.capitalize.ljust(7)}<: \##{channel} #{msg} #{nick}"
    			if nick == @nick # if i'm affected
	    			case msg
	    				when /\-\w{0,5}o/ # On De-Op
	    				when /\+\w{0,5}o/ # On Op
	    				when /\-\w{0,5}v/ # On De-Voice
	    				when /\+\w{0,5}v/ # On Voice
	    			end
	    		end
	    	when /^KICK/
		    	@tinderBot.status "#{event.capitalize.ljust(7)}<: \##{channel} #{nick} #{msg}"
	    		if nick == @nick # if it was me that got kicked
		    		@tinderBot.rejoinChannel channel.to_s
		    		sendChannel 'Screw you!'
		    	end

		    	@tinderBot.status "#{event.capitalize.ljust(7)}<: \##{channel} <#{nick}> #{msg}"
    	end
    end

    def statusMsg(msg)
	puts msg
	@dumpnicks.each{|x|
		@tinderBot.sendPrivate msg, x.to_s
	} if @dumpnicks.length > 0
    end

    def channelText(nick, host, msg)
    	@tinderBot.status "Channel<: \##{@channel} <#{nick}> #{msg}"
    	case msg
    		when /^(hi|hey|sup|yo) #{@nick}/i
			sendChannel $1 + " " + nick + "! :D"
		when /^@rehash/i
			sendChannel "Reloaded by request from " + nick
			@tinderBot.status "Status  : Reloaded by request from " + host
			@tinderBot.channels.first.graceful = true
			@tinderBot.shutDown
			@tinderBot = nil
		when /^@dump \#(.+?)$/
			@tinderBot.adddumpchan @channel, $1
			@tinderBot.channelText "#{$1}", "#{host}", "#{@nick}", "Started capturing with filter /.+/"
		when /^@dump \#(.+?) (.+)$/
			@tinderBot.adddumpchan @channel, $1, /#{$2}/i
			@tinderBot.channelText "#{$1}", "#{host}", "#{@nick}", "Started capturing with filter /#{$2}/i"
		when /^@stopdump$/
			@tinderBot.stopdump
		when /^@(.+?) (.+)$/
			response = runCommand($1, $2, nick, host, ["global", "channel"])
			sendChannel response
		when /^@(.+)$/
			response = runCommand($1, "", nick, host, ["global", "channel"])
			sendChannel response
    	end
    end

    def privateText(nick, host, msg)
    	@tinderBot.status "Private<: <#{nick}> -> <#{@nick}> #{msg}"
    	hostmask = nick + '!' + host

	if @adminHosts.include? hostmask
    		case msg
    			when /^RELOAD$/
    				sendPrivate "Roger that, " + nick, nick
				@tinderBot.status "Status  : Reloaded by request from " + host
				@graceful = true
				@tinderBot.rehash
				@tinderBot = nil
				DRb.stop_service
				break
			when /^REHASH$/
    				sendPrivate "Roger that " + nick, nick
				@tinderBot.status "Status  : Killed server by request from " + host
				@graceful = true
				@tinderBot.close
				@tinderBot = nil
				DRb.stop_service
				break
			when /^@dump$/
				@dumpnicks.push nick if !@dumpnicks.include? nick
				@tinderBot.status "Now dumping to #{nick}!#{host}"
			when /^@stopdump$/
				@dumpnicks.delete nick
				@tinderBot.status "Stopped dumping to #{nick}!#{host}"
			when /^SAY \##{@channel} (.+)$/i
				sendChannel $1
				break

		end
	end

	case msg
		when /^(hi|hey|sup|yo) #{@nick}$/i
			sendPrivate $1.capitalize + " " + nick + "!", nick
		when /^\x01(.+)\x01$/
			sendCTCP $1, nick
		when /^@(.+?) (.+)$/
			response = runCommand($1, $2, nick, host, ["global", "private"])
			sendPrivate response, nick
		when /^@(.+)$/
			response = runCommand($1, "", nick, host, ["global", "private"])
			sendPrivate response, nick
	end
    end
end

def addServer(server,port,nick)
	begin
		tinderServer1 = DRbObject.new(nil, 'druby://'+ ARGV[0] +':7777')
	rescue
		puts "Failed to connect to Tinder server"
		exit 0
	end

	tinderServer1.connectServer(server, port, nick)
	tinderBot1 = tinderServer1.addBot
	return tinderServer1, tinderBot1
end

def addChannels(channels,type)
	tinderChannels = Array.new

	channels.each {|x|
		tinderChannels.push Module.const_get(type).new(x.to_s)
	}
	return tinderChannels
end

def addChannel(channel,type)
	return Module.const_get(type).new(channel.to_s)
end

def connect(tinderServer, tinderBot, tinderChannels)
	trap("INT") {
		tinderChannels.first.graceful = false
		tinderBot.close
		tinderBot = nil
	}

	while tinderBot
		break if tinderBot.open != true
		tinderChannels.each {|x|
			x.poll
		}
		sleep 1
	end
	sleep 2
	exit 1 if tinderChannels.first.graceful == true
	exit 0
end

def addAdminHost(channels, host)
	channels.each {|x| x.adminHosts.push host if host.match /.+\!.+@.+?\..+/ }
end

def addDirWatcher(channels, path, name, url = "", channel = "", recursive = false)
	y = nil
	count = 0

	if channel == ""
		channels.each {|x|
			count = addDirectoryWatcher(path, name, url, x)
		}
		y = channels.first
	else
		channels.each {|x| y = x if x.channel.to_s == channel.to_s}
		if recursive
			count = addRecursiveDirectoryWatcher(path, name, url, y)
		else
			count = addDirectoryWatcher(path, name, url, y)
		end
	end

	y.tinderBot.status "Status  : Indexed #{count} files in #{name.downcase}\\#{File.basename(path).downcase}" if y.tinderBot
end

def addRecursiveDirectoryWatcher(path, name, url, channel)
	myDir = Dir.new(path)
	myDir.rewind
	count = 0
	count += addDirectoryWatcher(path, name, url, channel)
	myDir.each {|x|
		dirName = "#{path}/#{x.to_s}"
		childURL = "#{url}#{x.to_s}/"
		next if File.file? dirName
		next if /^[\.].*$/.match(x.to_s)
		count += addRecursiveDirectoryWatcher(dirName, name, childURL, channel)
	}
	return count
end

def addDirectoryWatcher(path, name, url, channel)
	dirWatcher = TinderDir.new(path, name, url, channel) if channel != nil

	dirWatcher.watcher.on_add = Proc.new{ |the_file, stats_hash|
		if channel.uptime > 5
			y = the_file.path.to_s.split(/\//).last.gsub(/ /,'%20')
			channel.sendChannel url + "#{y} Added to #{name}!"
		end
	}

	dirWatcher.watcher.on_modify = Proc.new{ |the_file, stats_hash|
	}

	dirWatcher.watcher.on_remove = Proc.new{ |stats_hash|
	}

	count = dirWatcher.poll()
	channel.dirWatchers.push dirWatcher
	return count
end

def addRSSWatcher(tinderChannels, url, type = "link", channel = "", announce = false)
	y = nil
	count = 0
	if channel.length > 1
		tinderChannels.each {|x| y = x if x.channel.to_s == channel.to_s}
		url.each{|x|
			newWatcher = TinderRSS.new(x, y, type, announce)
			y.rssWatchers.push newWatcher
			count += newWatcher.count
		}
	else
		tinderChannels.each {|y|
			url.each{|x|
				newWatcher = TinderRSS.new(x, y, type, announce)
				y.rssWatchers.push newWatcher
				count += newWatcher.count
			}
		}
	end

	y.tinderBot.status "Status  : Indexed #{count} #{type}'s" if y.tinderBot
end

class TinderDir
	attr_accessor :watcher, :path, :name, :channel, :url
	def initialize(path, name, url, channel)
		@path = path
		@name = name
		@channel = channel
		@url = url
		@watcher = DirectoryWatcher.new( path, 15 )
	end

	def search(args)
		response = ""
		@watcher.known_files.each {|x|
			args = args.gsub(/ /,'.+')
			y = File.basename(x)
			if y.match /#{args}/
				response = @url + y
				break
			end
		}
		return response
	end

	def poll
		begin
			return @watcher.scan_now
		rescue Exception => ex
			puts 'DirScan : ' + ex
		end
	end

	def latest
		latestFile = @watcher.known_files.sort_by{|x| @watcher.known_file_stats[x][:date]}.last
		response = ""
		response = @url + File.basename(latestFile) + '|' + @watcher.known_file_stats[latestFile][:date].to_s if latestFile != nil
		return response
	end

	def random
		return @url + File.basename(@watcher.known_files.sort_by{rand}.first)
	end
end

class TinderRSS
	attr_accessor :buffer, :channel, :url, :uptime, :announce, :type, :allow, :ignore, :count

	def initialize(url, channel, type = 'link', announce = false)
		@channel = channel
		@url = url
		@announce = announce
		@type = type
		@buffer = Array.new
		@allow = Array.new
		@ignore = Array.new
		@count = 0

		begin
			timeout(20) do
				content = open(@url).read
				rss = RSS::Parser.parse(content, false)

				rss.items.each{|x|
					filesize = ""
					category = ""
					begin
						category = x.category.to_s.gsub(/<\/?[^>]*>/, "").gsub(/&gt;/,'>').gsub(/&lt;/,'<')
						x.description =~ /size:<\/b> (.+?)<br>/i
						filesize = '[' + $1 + ']'
					rescue
						# no rescue for you
					end
					@buffer.push("#{category}: #{x.title} - #{x.link} #{filesize}")
				}

				result = @channel.mysql.query("SELECT Line FROM #{@type}allow")
				result.each_hash {|x| @allow.push x["Line"] }

				result = @channel.mysql.query("SELECT Line FROM #{@type}ignore")
				result.each_hash {|x| @ignore.push x["Line"] }
			end
		rescue Exception => ex
			puts 'RSS     : ' + ex
		end
	end

	def help
		resp = '@' + @type + ' latest - Lists the latest ' + @type + "\n"
		resp += '@' + @type + ' list - Lists the currently allowed ' + @type + "'s\n"
		resp += '@' + @type + ' listignore - Lists the currently ignored ' + @type + "'s\n"
		resp += '@' + @type + ' <search> - Searches the cache for an ' + @type + '.'
		if @type == 'nzb' or @type == 'torrent'
			resp += " Add 720 to your search to see 720p releases\n"
		else
			resp += "\n"
		end
		resp += 'Adding "is good" or "is bad" to the end of a search will announce or ignore new ' + @type + "'s with that name as they are released" + "\n"
		return resp
	end

	def cacheNZB(outLink)
		output = ""
		begin
			timeout(15) do
				@count += 1
				nzb = open(outLink, {'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3', 'Cookie' => 'userZone=-660; uid=104223; pass=ed1303786609789d6cdd24430248d19e; phpbb2mysql_data=a%3A2%3A%7Bs%3A11%3A%22autologinid%22%3Bs%3A32%3A%22b8aa492b883332fd7984001340267ffc%22%3Bs%3A6%3A%22userid%22%3Bs%3A5%3A%2276579%22%3B%7D; phpbb2mysql_sid=1b152ae6c5bf4f3f67a805c7e1a48597;'}).read
	                        outLink =~ /^.*\/(.*?)\.nzbdlnzb$/
	                        filename = @count.to_s
	                        filename = $1 if $1 != nil
				open('/var/www/nzb/' + filename + '.nzb', "w").write(nzb)
				output = 'http://www.viper-7.com/nzb/' + filename + '.nzb'
			end
		rescue Exception => ex
			puts "#{ex} - #{ex.backtrace}"
		end
		output = outLink if output == ""
		return output
	end

	def checkPre(rls)
		output = ""


		begin
			timeout(15) do
				open("http://scnsrc.net/pre/bots.php?user=betauser38&pass=ye9893V&results=5&search=" + rls.split('.+').first).read.scan(/([^^]*)\^(.*?)\^TV\^\^/){|rlstime,name|
					if rls.match(/720[pP]?$/)
						if !rlstime.include? 'd' and name.match(/#{rls}/i)
							output = "#{name} was released #{rlstime.chomp} ago, But there's no #{@type.capitalize} yet :("
							break
						end
					else
						if !rlstime.include? 'd' and name.match(/#{rls}/i)
							next if name.match(/720[pP]?/)
							output = "#{name} was released #{rlstime.chomp} ago, But there's no #{@type.capitalize} yet :("
							break
						end
					end
				}
			end
		rescue
		end
		return output.split("\n").join("")
	end

	def checkScreening(rls)
		output = ""
		name = ""
		text = ""
		begin
			timeout(20) do
				text = open("http://eztv.it/index.php?main=calendar").read
			end
		rescue Exception => ex
			puts "#{ex} - #{ex.backtrace}"
		end
		text.scan(/<td class='forum_thread_header' valign='top' width='90%'>\n        (.*?)?\n    </m) {|block|
			block[0] =~ /^(.*?)</
			day = $1
			block[0].scan(/<font size='1'>(.*?)<\/font>/) {|line|
				if line[0].match(/#{rls}/i)
					output = (Date.parse(day.chomp)+1).strftime('%A')
					name = line[0]
					break 2
				end
			}
		}
		if output != ""
			puts ".#{output}." + Date.today.strftime('%A') + "."
			if output.match(Date.today.strftime('%A'))
				output = "#{name} is due today, but hasn't been pre'd yet"
			else
				if output.match((Date.today+1).strftime('%A'))
					output = "Chill out! #{name} isn't due until tomorrow!"
				else
					output = "Settle down! #{name} isn't due until #{output}!"
				end
			end
		end
		return output
	end
	
	def tinyURL(url)
		resp = ""
		begin
			doc = Nokogiri::XML(open("http://urlborg.com/api/56698-8d89/url/create/" + CGI.escape(url.chomp)).read)
			resp = doc.xpath('//response/s_url').text
		rescue Exception => ex
			puts "#{ex} - #{ex.backtrace}"
		end
		return resp
	end

	def poll
		begin
			timeout(20) do
				content = open(@url,{'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.8) Gecko/20050511 Firefox/1.0.4', 'Referer' => 'http://www.nzbsrus.com'}).read
				rss = RSS::Parser.parse(content, false)

				rss.items.each{|x|
					filesize = ""
					category = ""
					begin
						category = x.category.to_s.gsub(/<\/?[^>]*>/, "").gsub(/&gt;/,'>').gsub(/&lt;/,'<')
						x.description =~ /size:<\/b> (.+?)<br>/i
						filesize = '[' + $1 + ']'
					rescue
						# no rescue for you
					end

					if !@buffer.include?("#{category}: #{x.title} - #{x.link} #{filesize}")
						@buffer.push("#{category}: #{x.title} - #{x.link} #{filesize}")
						if @announce
							hit = false

							@allow.each do |y|
								if /#{y}/i.match(x.title)
									hit = true
									@ignore.each {|z| hit = false if /#{z}/i.match(x.title)}
								end
							end

							if hit 
								if @type == 'nzb'
									@channel.sendChannel "New #{category}: #{x.title} - #{cacheNZB(x.link)} #{filesize}"
								else
									@channel.sendChannel "New #{category}: #{x.title} - #{tinyURL(x.link)}"
								end
							else
								puts 'Ignored : ' + "New #{category}: #{x.title} #{filesize}"
							end
						end
					end
				}
			end
		rescue Exception => ex
			puts 'RSS     : ' + ex
		end
	end

	def count
		return @buffer.length
	end

	def refresh
		@allow.clear
		@ignore.clear
		count = 0
		result = @channel.mysql.query("SELECT Line FROM #{@type}allow")
		result.each_hash {|x| @allow.push x["Line"]; count += 1 }

		result = @channel.mysql.query("SELECT Line FROM #{@type}ignore")
		result.each_hash {|x| @ignore.push x["Line"]; count += 1 }

		return count.to_s
	end

	def listallow
		response = ""
		count = 0
		@allow.each {|x|
			count += 1
			x=x.gsub(/\./,' ')
			response += "\"#{x}\" "
			response += "\n" if count % 5 == 0
		}
		response = "No #{@type}'s in the Allow list, '@#{@type} help' for help adding one" if response == ""
		return response
	end

	def listignore
		response = ""
		count = 0
		@ignore.each {|x|
			count += 1
			x=x.gsub(/\./,' ')
			response += "\"#{x}\" "
			response += "\n" if count % 5 == 0
		}
		return response
		response = "No #{@type}'s in the Ignore list, '@#{@type} help' for help adding one" if response == ""
	end

	def search(args)
	    	output = ""
		@buffer.each{|x|
			if args.match(/720[pP]?/)
			    	args = args.gsub(/ /,'.+')
				if x.match(/.+?: .*?#{args}.*?/i)
					if @type == 'nzb'
						x =~ /^(.+?): (.+) - (.+?) (.*?)$/
						output = "#{$1}: #{$2} - #{cacheNZB($3)} #{$4}"
						puts output
						break
					else
						x =~ /^(.+?): (.+) - (.+?)\s?$/
						output = "#{$1}: #{$2} - #{tinyURL($3)}"
						puts output
						break
					end
				end
			else
			    	args = args.gsub(/ /,'.+')
				if x.match(/.+?: .*?#{args} -/i)
					next if x.match(/.+?: .*720[pP]?.*? -/)
					next if x.match(/.+?: .*1080[pP]?.*? -/)
					if @type == 'nzb'
						x =~ /^(.+?): (.+) - (.+?) (.+?)$/
						output = "#{$1}: #{$2} - #{cacheNZB($3)} #{$4}"
						puts output
						break
					else
						x =~ /^(.+?): (.+) - (.+?)\s?$/
						output = "#{$1}: #{$2} - #{tinyURL($3)}"
						puts output
						break
					end
				end
			end
		}
		if output == ""
			output = checkPre(args)
			output = checkScreening(args) if output == ""
		end
		
		return output
	end

	def latest
		output = ""
		if @type == 'nzb'
			@buffer.last =~ /^(.+?): (.+) - (.+?) (.+?)$/
			output = "#{$1}: #{$2} - #{cacheNZB($3)} #{$4}" if $3 != nil
		else
			@buffer.last =~ /^(.+?): (.+) - (.+?)\s?$/
			output = "#{$1}: #{$2} - #{tinyURL($3)}" if $3 != nil
		end
		return output
	end
end

class DirectoryWatcher
   # How long (in seconds) to wait between checks of the directory for changes.
   attr_accessor :autoscan_delay

   # The Dir instance or path to the directory to watch.
   attr_accessor :directory
   def directory=( dir ) #:nodoc:
      @directory = dir.is_a?(Dir) ? dir : Dir.new( dir )
   end

   # Proc to call when files are added to the watched directory.
   attr_accessor :on_add

   # Proc to call when files are modified in the watched directory
   # (see +onmodify_checks+).
   attr_accessor :on_modify

   # Proc to call when files are removed from the watched directory.
   attr_accessor :on_remove

   # Array of symbols which specify which attribute(s) to check for changes.
   # Valid symbols are <tt>:date</tt> and <tt>:size</tt>.
   # Defaults to <tt>:date</tt> only.
   attr_accessor :onmodify_checks

   # If more than one symbol is specified for +onmodify_checks+, should
   # +on_modify+ be called only when *all* specified values change
   # (value of +true+), or when any *one* value changes (value of +false+)?
   # Defaults to +false+.
   attr_accessor :onmodify_requiresall

   # Should files which exist in the directory fire the +on_add+ callback
   # the first time the directory is scanned? Defaults to +true+.
   attr_accessor :onadd_for_existing

   # Regular expression to match against file names. If +nil+, all files
   # will be included, otherwise only those whose name match the regexp
   # will be passed to the +on_add+/+on_modify+/+on_remove+ callbacks.
   # Defaults to <tt>/^[^.].*$/</tt> (files which do not begin with a period).
   attr_accessor :name_regexp
   attr_accessor :known_files
   attr_accessor :known_file_stats

   # Creates a new directory watcher.
   #
   # _dir_::    The path (relative to the current working directory) of the
   #            directory to watch, or a Dir instance.
   # _delay_::  The +autoscan_delay+ value to use; defaults to 10 seconds.
   def initialize( dir, delay = 10 )
      self.directory = dir
      @autoscan_delay = delay
      @known_file_stats = {}
      @known_files = Array.new
      @onmodify_checks = [ :date ]
      @onmodify_requiresall = false
      @onadd_for_existing = true
      @scanned_once = false
      @name_regexp = /^[^.].*[^db]$/
   end

   # Scans the directory for additions/modifications/removals,
   # calling the +on_add+/+on_modify+/+on_remove+ callbacks as
   # appropriate.
   def scan_now
      # Setup the checks
      # ToDo: CRC
      checks = {
      	 :name => {
            :use=>false,
            :proc=>Proc.new{ |the_file,stats| the_file.path }
         },
         :date => {
            :use=>false,
            :proc=>Proc.new{ |the_file,stats| stats.mtime }
         },
         :size => {
            :use=>true,
            :proc=>Proc.new{ |the_file,stats| stats.size }
         },
      }
      checks.each_pair{ |check_name,check|
         check[:use] = (@onmodify_checks == check_name) || ( @onmodify_checks.respond_to?( :include? ) && @onmodify_checks.include?( check_name ) )
      }

      #Check for add/modify
      @directory.rewind
      count = 0
      @directory.each{ |fname|
         file_path = "#{@directory.path}/#{fname}"
         next if (@name_regexp.respond_to?( :match ) && !@name_regexp.match( fname )) || !File.file?( file_path )
         the_file = File.new( file_path )
         file_stats = File.stat( file_path )

         saved_stats = @known_file_stats[file_path]
         new_stats = {}
         checks.each_pair{ |check_name,check|
            new_stats[check_name] = check[:proc].call( the_file, file_stats )
         }

	 @known_files.push file_path if !@known_files.include? file_path

         if saved_stats
            if @on_modify.respond_to?( :call )
               sufficiently_modified = @onmodify_requiresall
               saved_stats = @known_file_stats[file_path]
               checks.each_pair{ |check_name,check|
                  stat_changed = check[:use] && ( saved_stats[check_name] != new_stats[check_name] )
                  if @onmodify_requiresall
                     sufficiently_modified &&= stat_changed
                  else
                     sufficiently_modified ||= stat_changed
                  end
                  saved_stats[check_name] = new_stats[check_name]
               }
               @on_modify.call( the_file, saved_stats ) if sufficiently_modified
            end
         elsif @on_add.respond_to?( :call ) && (@scanned_once || @onadd_for_existing)
            @known_file_stats[file_path] = new_stats
            @on_add.call( the_file, new_stats )
            count += 1
         end
         the_file.close
      }

      # Check for removed files
      if @on_remove.respond_to?( :call )
         @known_file_stats.each_pair{ |path,stats|
            next if File.file?( path )
            stats[:path] = path
            @on_remove.call( stats )
            @known_file_stats.delete(path)
         }
      end

      @scanned_once = true
      return count
   end
end
