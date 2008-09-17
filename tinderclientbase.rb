require 'drb'
require 'socket'
require 'timeout'
require 'find'

STDOUT.sync = true

DRb.start_service

class TinderClientBase
    include DRbUndumped

    attr_accessor :channel, :tinderBot, :nick, :graceful, :uptime

    def initialize(channel, tinderBot)
        @channel = channel
        @graceful = false
        @tinderBot = tinderBot
    	@tinderBot.addChannel(self)
    	@uptime = 0
    end

    def poll
    	@uptime += 1
    	@uptime = 5 if @uptime > 500
    end

    def memUsage
	response = %x[ps -eo 'cputime,%cpu,%mem,vsz,sz,command']
	output = ""
	response.each_line {|x|
		z = ""
		x = x.gsub(/  /,'~')
		x = x.split(/~/)
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
	msg.each_line{|line| lines += 1; puts "Output  : \##{@channel} - #{line}"}
    	@tinderBot.sendChannel msg, @channel
    end

    def sendPrivate(msg, nick)
	lines=0
	msg.each_line{|line| lines += 1; puts "Private\>: #{nick} - #{line}"}
    	@tinderBot.sendPrivate msg, nick
    end

    def sendAction(msg)
	lines=0
	msg.each_line{|line| lines += 1; puts "Action \>: \##{@channel} - #{line}"}
    	@tinderBot.sendCTCP "ACTION #{msg}", "\##{@channel}"
    end

    def sendCTCP(msg, nick)
	lines=0
	msg.each_line{|line| lines += 1; puts "CTCP   \>: #{nick} - #{line}"}
    	@tinderBot.sendCTCP msg, nick
    end

    def connected
    	@nick = @tinderBot.nick
    end

    def serverText(msg)
    end

    def runCommand(command, args, nick, host, folders)
    	puts "Status  : Running command '" + command + " " + args + "'"
	hit = false
    	for folder in folders
    		Find.find(folder) do |path|
    			if FileTest.directory?(path)
				next
    			else
				next if !path.include? '.'
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
    						args = args.gsub(/\"/,'\"')
    						args = args.split(/ /).join('" "')
    						args = '"' + args + '"'
    						cmdline = "#{lang} #{filename}.#{ext} #{args}"
    					else
    						cmdline = "#{lang} #{filename}.#{ext}"
    					end

					response = ""
    					puts "Exec    : '" + cmdline + "'"
					begin
						timeout(10) {
	    						response = %x[#{cmdline}]
		    					response = "No Output." if response.length == 0
    						}
    					rescue Exception => ex
    						response = "Command timed out - "
	    				end
    				end
    			end
    		end
    	end
	if command.chomp == 'mem'
		usage = memUsage
		response = response + "\n" + usage + "\n"
	end
	if hit == false
		response = "Command not found"
    	end
	return response
    end

    def channelEvent(channel, host, nick, event, msg)
    	puts "Event   : " + event + ": " + nick + " #" + channel + " - '" + msg + "'"
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
    	end
    end

    def channelText(nick, host, msg)
    	puts "Text    : #" + @channel + " <" + nick + "> - '" + msg + "'"
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
			response = runCommand($1, $2, nick, host, ["/opt/tinderBot/scripts/global/builtin","/opt/tinderBot/scripts/global/user","/opt/tinderBot/scripts/channel/builtin","/opt/tinderBot/scripts/channel/user"])
			sendChannel response
		when /^@(.+)$/
			response = runCommand($1, "", nick, host, ["/opt/tinderBot/scripts/global/builtin","/opt/tinderBot/scripts/global/user","/opt/tinderBot/scripts/channel/builtin","/opt/tinderBot/scripts/channel/user"])
			sendChannel response
    	end
    end

    def privateText(nick, host, msg)
    	puts "Private\<: " + nick + " - '" + msg + "'"
    	if nick + host == 'Viper-7~druss@viper-7.com'
    		case msg
    			when /^RELOADCLIENT|REHASH$/
    				sendPrivate "Roger that, " + nick, nick
				puts "Status  : Reloaded by request from " + host
				@graceful = true
				@tinderBot.rehash
				@tinderBot = nil
				break
			when /^KILLCLIENTS$/
    				sendPrivate "Roger that, " + nick, nick
				puts "Status  : Reloaded by request from " + host
				@graceful = true
				@tinderBot.rehash
				@tinderBot = nil
				exit 0
				break
			when /^KILL$/
    				sendPrivate "Roger that, " + nick, nick
    				sleep(0.4)
				puts "Status  : Killed server by request from " + host
				@graceful = false
				@tinderBot.close
				@tinderBot = nil
				DRb.stop_service
				sleep(2)
				exit 0
				break
			when /^@(.+?) (.+)$/
				response = runCommand($1, $2, nick, host, ["/opt/tinderBot/scripts/global/builtin","/opt/tinderBot/scripts/global/user","/opt/tinderBot/scripts/private/builtin","/opt/tinderBot/scripts/private/user"])
				sendPrivate response, nick
			when /^@(.+)$/
				response = runCommand($1, "", nick, host, ["/opt/tinderBot/scripts/global/builtin","/opt/tinderBot/scripts/global/user","/opt/tinderBot/scripts/private/builtin","/opt/tinderBot/scripts/private/user"])
				sendPrivate response, nick
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
	end
    end
end

def tinderConnect(server,port,nick,channels)
	puts "Status  : Connecting..."
	begin
		tinderClient1 = DRbObject.new(nil, 'druby://'+ ARGV[0] +':7777')
	rescue
		puts "Status  : Failed to connect to Tinder server"
		exit 0
	end

	tinderClient1.connectServer(server, port, nick)
	tinderBot1 = tinderClient1.addBot
	@tinderChannels = Array.new

	channels.each {|x|
		@tinderChannels.push TinderChannel.new(x.to_s, tinderBot1)
	}

	trap("INT") {
		@tinderChannels.first.graceful = false
		tinderBot1.rehash
		tinderBot1 = nil
	}

	dropboxWatcher = Dir::DirectoryWatcher.new( '/mnt/dalec/Documents and Settings/Viper-7/My Documents/My Dropbox/nesreca', 5 )
	dropboxWatcher.name_regexp = /^[^.].*[^db]$/

	dropboxWatcher.on_add = Proc.new{ |the_file, stats_hash|
		@tinderChannels.each{|x|
			if x.channel.to_s == 'nesreca' and x.uptime > 5
				y = the_file.path.to_s.split(/\//).last
				x.sendChannel "#{y} Added to Dropbox!"
			end
		}
	}

	dropboxWatcher.on_modify = Proc.new{ |the_file, stats_hash|
		@tinderChannels.each{|x|
			if x.channel.to_s == 'nesreca' and x.uptime > 5
				y = the_file.path.to_s.split(/\//).last
				x.sendChannel "#{y} Updated in Dropbox!"
			end
		}
	}

	dropboxWatcher.on_remove = Proc.new{ |stats_hash|
		@tinderChannels.each{|x|
			if x.channel.to_s == 'nesreca' and x.uptime > 5
				y = the_file.path.to_s.split(/\//).last
				x.sendChannel "#{y} Deleted from Dropbox!"
			end
		}
	}

	dropboxWatcher.start_watching

	puts "Status  : Running..."
	while tinderBot1
		break if tinderBot1.open != true
		@tinderChannels.each {|x|
			x.poll
		}
		sleep 1
	end
	exit 1 if @tinderChannels.first.graceful == true
	exit 0
end

class Dir
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

	   # Creates a new directory watcher.
	   #
	   # _dir_::    The path (relative to the current working directory) of the
	   #            directory to watch, or a Dir instance.
	   # _delay_::  The +autoscan_delay+ value to use; defaults to 10 seconds.
	   def initialize( dir, delay = 10 )
	      self.directory = dir
	      @autoscan_delay = delay
	      @known_file_stats = {}
	      @onmodify_checks = [ :date ]
	      @onmodify_requiresall = false
	      @onadd_for_existing = true
	      @scanned_once = false
	      @name_regexp = /^[^.].*$/
	   end

	   # Starts the automatic scanning of the directory for changes,
	   # repeatedly calling #scan_now and then waiting +autoscan_delay+
	   # seconds before calling it again.
	   #
	   # Automatic scanning is *not* turned on when you create a new
	   # DirectoryWatcher; you must invoke this method (after setting
	   # the +on_add+/+on_modify+/+on_remove+ callbacks).
	   def start_watching
	      @thread = Thread.new{
	         while true
	            self.scan_now
	            sleep @autoscan_delay
	         end
	      }
	   end

	   # Stops the automatic scanning of the directory for changes.
	   def stop_watching
	      @thread.kill
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
	   end

	end
end