require 'drb'
require 'socket'
require 'timeout'
require 'find'
require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

STDOUT.sync = true
tinderChannels = Array.new

DRb.start_service

class TinderChannelBase
    include DRbUndumped

    attr_accessor :channel, :tinderBot, :nick, :graceful, :uptime, :dumpnicks, :dirWatchers, :rssWatchers, :adminHosts

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
    end

    def poll
    	@uptime += 1
    	@uptime = 5 if @uptime > 604
	@dirWatchers.each{|x| x.poll} if @uptime % 20 == 0
	@rssWatchers.each{|x| x.poll} if @uptime % 120 == 0
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
		    	response += '@php @ruby @tcl @mem '
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
		end

	    	lines += response + "\n"
	}
	lines += 'Type a command to see its usage'
	return lines
    end

    def runCommand(command, args, nick, host, commandtypes)
    	response = ""
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
	    					args.gsub(/mail/, 'm@il')
	    					lang = ext

	    					ENV['IIBOT_DIR'] = filename.split('/')[0..2].join('/')
	    					ENV['IIBOT_TEMP_DIR'] = ENV['IIBOT_DIR'] + '/tmp'
	    					ENV['IIBOT_SCRIPT_DIR'] = ENV['IIBOT_DIR'] + '/scripts'

	    					if args.length > 0
	    						cmdline = "#{lang} #{filename}.#{ext} #{args}"
	    					else
	    						cmdline = "#{lang} #{filename}.#{ext}"
	    					end

	    					@tinderBot.status "Exec    : '" + cmdline + "'"
						begin
							timeout(10) do
								IO.popen(cmdline) do |out|
									response += out.read.to_s
								end
			    					response = "No Output." if response == ""
	    						end
	    					rescue Exception => ex
	    						response = "Command timed out - " + ex.to_s
		    				end
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
				begin
					timeout(10) do
						args = "<?php\n" + args + "\n?>"

						File.open('/tmp/tinderScript', 'w') {|f| f.write(args) }

						IO.popen('php /tmp/tinderScript 2>&1') do |out|
							response += out.read.to_s
						end
	    					response = "No Output." if response == ""
					end
				rescue Exception => ex
					response = "Command timed out - " + ex.to_s
				end
			end
		when /^ruby$/
			if args == ""
				response = 'Usage: @ruby <code to run>' + "\n"
				response += 'Eg: @ruby puts "hi"'
			else
				begin
					timeout(10) do
						File.open('/tmp/tinderScript', 'w') {|f| f.write(args) }

						IO.popen('ruby /tmp/tinderScript 2>&1') do |out|
							response += out.read.to_s
						end
	    					response = "No Output." if response == ""
					end
				rescue Exception => ex
					response = "Command timed out - " + ex.to_s
				end
			end
		when /^tcl$/
			if args == ""
				response = 'Usage: @tcl <code to run>' + "\n"
				response += 'Eg: @tcl puts hi'
			else
				begin
					timeout(10) do
						File.open('/tmp/tinderScript', 'w') {|f| f.write(args) }

						IO.popen('tclsh /tmp/tinderScript 2>&1') do |out|
							response += out.read.to_s
						end
	    					response = "No Output." if response == ""
					end
				rescue Exception => ex
					response = "Command timed out - " + ex.to_s
				end
			end
		when /^mem$/
			usage = memUsage
			response = response + usage
		when /^help$/
			response = help(commandtypes)
	end

	response = "Command not found" if response == ""

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
		response = aOut.sort_by{rand}.first.to_s
	end

	resp = ""
	@rssWatchers.each do |x|
		if x.type.match(/^#{command.chomp}$/i)
			if args.match(/^latest$/i)
				resp = x.latest
			else
				resp = x.search args
				resp = 'No Hits :(' if resp == ""
			end
		end
	end
	response = resp if resp != ""

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
    	hostmask = nick + '!' + host.gsub(/~/,'')

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
		@watcher = DirectoryWatcher.new( url, path, 15 )
	end

	def search(args)
		@watcher.known_files.each {|x|
			if x.match /#{args}/
				return x
				break
			end
		}
	end

	def poll
		@watcher.scan_now
	end

	def latest
		return @watcher.known_files.last.to_s
	end

	def random
		return @watcher.known_files.sort_by{rand}.first.to_s
	end
end

class TinderRSS
	attr_accessor :buffer, :channel, :url, :uptime, :announce, :type

	def initialize(url, channel, type = 'link', announce = false)
		@channel = channel
		@url = url
		@announce = announce
		@type = type
		@buffer = Array.new

		content = open(@url).read
		rss = RSS::Parser.parse(content, false)
		count = 0
		rss.items.each{|x| @buffer.push(x.title + ' - ' + x.link); count += 1}
		puts "Added #{count} entries to RSS Watcher - #{@url}"
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
				@channel.sendChannel "New #{@type}: #{x.title} - #{tinyURL(x.link)}" if @announce
			end
		}
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

   attr_accessor :url

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

   # Creates a new directory watcher.
   #
   # _dir_::    The path (relative to the current working directory) of the
   #            directory to watch, or a Dir instance.
   # _delay_::  The +autoscan_delay+ value to use; defaults to 10 seconds.
   def initialize( url, dir, delay = 10 )
      self.directory = dir
      @url = url
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
         :date => {
            :use=>false,
            :proc=>Proc.new{ |file,stats| stats.mtime }
         },
         :size => {
            :use=>false,
            :proc=>Proc.new{ |file,stats| stats.size }
         },
         :crc => {
            :use=>false,
            :proc=>Proc.new{ |file,stats| 1 }
         }
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

	 furl = url.to_s + fname.to_s
	 @known_files.push furl if !@known_files.include? furl

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
      puts "Added #{count} entries to Dir Watcher - #{@url}" if @scanned_once != true

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
