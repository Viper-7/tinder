require 'drb'
require 'socket'
require 'timeout'
require 'find'
require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'mysql'

require 'rubygems'
require 'open4'

STDOUT.sync = true
tinderChannels = Array.new

DRb.start_service

class TinderChannelBase
    include DRbUndumped

    attr_accessor :channel, :tinderBot, :nick, :graceful, :uptime, :dumpnicks, :dirWatchers, :rssWatchers, :adminHosts, :mysql

    def initialize(channel, tinderBot)
	@dirWatchers = Array.new
	@rssWatchers = Array.new
	@adminHosts = Array.new
        @channel = channel
        @graceful = false
        @tinderBot = tinderBot
    	@tinderBot.addChannel(self)
    	@dumpnicks = Array.new
    	@uptime = 0

	@mysql = Mysql.init()
	@mysql.connect('kodiak','db','db')
	@mysql.select_db('viper7')
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

    def poll
    	@uptime += 1
    	@uptime = 5 if @uptime > 604
    	begin
		@dirWatchers.each{|x| x.poll} if @uptime % 20 == 0
		@rssWatchers.each{|x| x.poll} if @uptime % 120 == 0
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
	if output == ""
		output = "Fail"
	end
	return output[3..-1]
    end

    def shutDown()
	if tinderChannel1.graceful == true
	else
	end
    end

    def sendChannel(msg)
	lines=0
	msg.each_line{|line| lines += 1; @tinderBot.status "Output  : \##{@channel} - #{line}"}
    	@tinderBot.sendChannel msg, @channel
    end

    def sendPrivate(msg, nick)
	lines=0
	msg.each_line{|line| lines += 1; @tinderBot.status "Private\>: #{nick} - #{line}"}
    	@tinderBot.sendPrivate msg, nick
    end

    def sendAction(msg)
	lines=0
	msg.each_line{|line| lines += 1; @tinderBot.status "Action \>: \##{@channel} - #{line}"}
    	@tinderBot.sendCTCP "ACTION #{msg}", "\##{@channel}"
    end

    def sendCTCP(msg, nick)
	lines=0
	msg.each_line{|line| lines += 1; @tinderBot.status "CTCP   \>: #{nick} - #{line}"}
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
	return ''
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

	    					args.gsub(/rm/, 'rn')
	    					args.gsub(/wget/, 'wgot')
	    					args.gsub(/mail/, 'm@il')
	    					lang = ext

	    					ENV['IIBOT_DIR'] = filename.split('/')[0..2].join('/')
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

	    					@tinderBot.status "Exec    : '" + cmdline + "'"

						popen4(cmdline) {|stdout, stderr, stdin, pipe|
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
				args.gsub(/rm/, 'rn')
				args.gsub(/exec/, 'pcntl_exec')
				args.gsub(/fork/, 'fark')
				args.gsub(/mail/, 'm@il')

				args = "<?php\n" + args + "\n?>"

				File.open('/tmp/tinderScript', 'w') {|f| f.write(args) }

				popen4('sudo -u nobody php /tmp/tinderScript') {|stdout, stderr, stdin, pipe|
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
				args.gsub(/rm/, 'rn')
				args.gsub(/exec/, 'exac')
				args.gsub(/fork/, 'fark')
				args.gsub(/mail/, 'm@il')

				File.open('/tmp/tinderScript', 'w') {|f| f.write(args) }

				popen4('sudo -u nobody ruby /tmp/tinderScript') {|stdout, stderr, stdin, pipe|
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
		when /^tcl$/
			if args == ""
				response = 'Usage: @tcl <code to run>' + "\n"
				response += 'Eg: @tcl puts hi'
			else
				args.gsub(/rm/, 'rn')
				args.gsub(/exec/, 'exac')
				args.gsub(/fork/, 'fark')
				args.gsub(/mail/, 'm@il')

				File.open('/tmp/tinderScript', 'w') {|f| f.write(args) }

				popen4('sudo -u nobody tclsh /tmp/tinderScript') {|stdout, stderr, stdin, pipe|
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
		when /^#{customCommands}$/
			hit = true
	end

	response = "Command not found" if response == "" and hit == false

	aOut = Array.new
	hit = false

	@dirWatchers.each do |x|
		if x.name.match(/^#{command.chomp}$/i)
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
			aOut.sort_by{|x| x =~ /.+?\|(.+)/; $1}
			aOut.first =~ /(.+?)\|.+/
			response = $1
		else
			response = aOut.sort_by{rand}.first.to_s
		end
	end
	resp = ""
	@rssWatchers.each do |x|
		if x.type.match(/^#{command.chomp}$/i)
			case args
				when /^latest$/i
					resp2 = x.latest
					resp = resp2 if resp2 != ""
				when /(.+?) is (?:shit|bad|poo|terrible|crap|gay)/i
					x.ignore $1
					args = $1.gsub(/ /,'.+')
					result = @mysql.query("SELECT COUNT(*) FROM nzballow WHERE Line LIKE \"#{args}\"")
					@mysql.query("DELETE FROM nzballow WHERE Line LIKE \"#{args}\"") if result.fetch_row[0] != "0"
					resp = "Ignoring #{args}"
				when /listallow/
					resp = x.listallow
				when /(.+?) is (?:good|fine|ok|sick|cool|mad|grouse)/i
					x.allow $1
					args = $1.gsub(/ /,'.+')
					result = @mysql.query("SELECT COUNT(*) FROM nzballow WHERE Line LIKE \"#{args}\"")
					@mysql.query("INSERT INTO nzballow SET Line=\"#{args}\"") if result.fetch_row[0] == "0"
					resp = "Allowing #{args}"
				when /help/
					resp = '@' + command.chomp + ' latest - Lists the latest ' + command.chomp + "\n"
					resp += '@' + command.chomp + ' <search> - Searches the cache for an ' + command.chomp + "\n"
					resp += 'Adding "is bad" or "is good" to the end of a search will ignore or announce new ' + command.chomp + "'s with that name on release" + "\n"
					resp += '@' + command.chomp + ' listallow - lists the currently ignored ' + command.chomp + "'s"
				else
					resp2 = x.search args
					resp = resp2 if resp2.length > 1
					resp = 'No Hits :(' if resp == ""
			end
		end
	end
	response = resp if resp != ""
	puts "Output  : " + response
	return response
    end

    def channelEvent(channel, host, nick, event, msg)
    	@tinderBot.status "Event   : " + event + ": " + nick + " #" + channel + " - '" + msg + "'"
    	case event
    		when /^MODE/
    			if nick == @nick
	    			case msg
	    				when /\-o/ # On De-Op
	    				when /\+o/ # On Op
	    				when /\-v/ # On De-Voice
	    				when /\+v/ # On Voice
	    			end
	    		end
	    	when /^KICK/
	    		puts nick + ":" + event + ":" + msg
	    		if nick == @nick
		    		@tinderBot.rejoinChannel channel.to_s
		    		sendChannel 'Screw you!'
		    	end
    	end
    end

    def statusMsg(msg)
	puts msg
	@dumpnicks.each{|x|
		@tinderBot.sendPrivate msg, x.to_s
	} if @dumpnicks.length > 0
    end

    def channelText(nick, host, msg)
    	@tinderBot.status "Text    : #" + @channel + " <" + nick + "> - '" + msg + "'"
    	case msg
    		when /^(hi|hey|sup|yo) #{@nick}/i
			sendChannel $1 + " " + nick + "!"
		when /^@rehash/i
			sendChannel "Reloaded by request from " + nick
			puts "Status  : Reloaded by request from " + host
			@tinderBot.channels.first.graceful = true
			@tinderBot.shutDown
			@tinderBot = nil
		when /^@(.+?) (.+)$/
			response = runCommand($1, $2, nick, host, ["global", "channel"])
			sendChannel response
		when /^@(.+)$/
			response = runCommand($1, "", nick, host, ["global", "channel"])
			sendChannel response
    	end
    end

    def privateText(nick, host, msg)
    	@tinderBot.status "Private\<: " + nick + " - '" + msg + "'"
    	hostmask = nick + '!' + host

	if @adminHosts.include? hostmask
    		case msg
    			when /^RELOAD$/
    				sendPrivate "Roger that, " + nick, nick
				puts "Status  : Reloaded by request from " + host
				@graceful = true
				@tinderBot.rehash
				@tinderBot = nil
				DRb.stop_service
				break
			when /^REHASH$/
    				sendPrivate "Roger that, " + nick, nick
				puts "Status  : Killed server by request from " + host
				@graceful = true
				@tinderBot.close
				@tinderBot = nil
				DRb.stop_service
				break
			when /^startdump$/
				@dumpnicks.push nick
				@tinderBot.status "Now dumping to #{nick}@#{host}"
			when /^stopdump$/
				@dumpnicks.delete nick
				@tinderBot.status "Stopped dumping to #{nick}@#{host}"
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
	puts "Status  : Connecting..."
	begin
		tinderClient1 = DRbObject.new(nil, 'druby://'+ ARGV[0] +':7777')
	rescue
		puts "Status  : Failed to connect to Tinder server"
		exit 0
	end

	tinderClient1.connectServer(server, port, nick)
	tinderBot1 = tinderClient1.addBot
	return tinderClient1, tinderBot1
end

def addChannels(channels,tinderBot1,type)
	tinderChannels = Array.new

	channels.each {|x|
		tinderChannels.push Module.const_get(type).new(x.to_s, tinderBot1)
	}
	return tinderChannels
end


def connect(tinderClient, tinderBot, tinderChannels)
	trap("INT") {
		tinderChannels.first.graceful = false
		tinderBot.close
		tinderBot = nil
	}

	puts "Status  : Running..."
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

def addAdminHost(host, channels)
	channels.each {|x| x.adminHosts.push host if host.match /.+\!.+@.+?\..+/ }
end

def addDirectoryWatcher(path, name, channel, url, channels)
	y = nil
	channels.each {|x| y = x if x.channel.to_s == channel.to_s}

	dirWatcher = TinderDir.new(path, name, channel, url, channels) if y != nil

	dirWatcher.watcher.on_add = Proc.new{ |the_file, stats_hash|
		channels.each{|x|
			if x.channel.to_s == channel and x.uptime > 5
				y = the_file.path.to_s.split(/\//).last.gsub(/ /,'%20')
				x.sendChannel url + "#{y} Added to #{name}!"
			end
		}
	}

	dirWatcher.watcher.on_modify = Proc.new{ |the_file, stats_hash|
	}

	dirWatcher.watcher.on_remove = Proc.new{ |stats_hash|
	}
	dirWatcher.poll
	y.dirWatchers.push dirWatcher
end

def addRSSWatcher(url, channel, tinderChannels, type = 'link', announce = false)
	y = nil
	tinderChannels.each {|x| y = x if x.channel.to_s == channel.to_s}
	y.rssWatchers.push TinderRSS.new(url, y, type, announce)
end

class TinderDir
	attr_accessor :watcher, :path, :name, :channel, :url, :channels
	def initialize(path, name, channel, url, channels)
		@path = path
		@name = name
		@channel = channel
		@channels = channels
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
		@watcher.scan_now
	end

	def latest
		latestFile = @watcher.known_files.sort_by{|x| @watcher.known_file_stats[x][:date]}.last
		return @url + File.basename(latestFile) + '|' + @watcher.known_file_stats[latestFile][:date].to_s
	end

	def random
		return @url + File.basename(@watcher.known_files.sort_by{rand}.first)
	end
end

class TinderRSS
	attr_accessor :buffer, :channel, :url, :uptime, :announce, :type, :allow

	def initialize(url, channel, type = 'link', announce = false)
		@channel = channel
		@url = url
		@announce = announce
		@type = type
		@buffer = Array.new
		@allow = Array.new

		content = open(@url).read
		rss = RSS::Parser.parse(content, false)
		count = 0
		rss.items.each{|x|
			@buffer.push(x.title + ' - ' + x.link)
			count += 1
		}
		puts "Status  : Added #{count} entries to RSS Watcher - #{@url}"

		result = @channel.mysql.query("SELECT Line FROM nzballow")
		result.each_hash {|x| @allow.push x["Line"] }
	end

	def tinyURL(url)
		return open('http://tinyurl.viper-7.com/?url=' + url).read
	end

	def poll
		content = open(@url).read
		rss = RSS::Parser.parse(content, false)

		rss.items.each{|x|
			if !@buffer.include?(x.title + ' - ' + x.link)
				@buffer.push(x.title + ' - ' + x.link)
				if @announce
					hit = false

					@allow.each{|y|
						hit = true if /#{y}/i.match(x.title)
					}

					if hit
						@channel.sendChannel "New #{x.category}: #{x.title} - #{tinyURL(x.link)} - #{x.size}"
					else
						puts 'Ignored : ' + "New #{x.category}: #{x.title} - #{tinyURL(x.link)} - #{x.size}"
					end
				end
			end
		}
	end

	def allow(args)
		args = args.gsub(/ /,'.+')
		@allow.push args
	end

	def listallow
		response = ""
		@allow.clear
		count = 0
		result = @channel.mysql.query("SELECT Line FROM nzballow")
		result.each_hash {|x|
			@allow.push x["Line"]
			count += 1
		}
		count = 0
		@allow.each {|x|
			count += 1
			response += "/#{x}/ "
			response += "\n" if count % 5 == 0
		}
		return response
	end

	def ignore(args)
		args = args.gsub(/ /,'.+')
		if !@allow.include? args
			@allow.delete args
		end
	end

	def search(args)
	    	args = args.gsub(/ /,'.+')
	    	output = ""
		@buffer.each {|x| output = x if x.match(/#{args}/i) }
		return output
	end

	def latest
		return @buffer.last
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
      puts "Status  : Added #{count} entries to Dir Watcher - #{@directory.path}" if @scanned_once != true

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
   end

end
