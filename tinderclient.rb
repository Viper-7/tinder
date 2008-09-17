require 'tinderclientbase.rb'

class TinderChannel < TinderClientBase
    include DRbUndumped

    def runCommand(command, args, nick, host)
    	puts "Status  : Running command '" + command + " " + args + "'"
    	folders = ["/opt/tinderBot/scripts/global/builtin","/opt/tinderBot/scripts/global/user","/opt/tinderBot/scripts/channel/builtin","/opt/tinderBot/scripts/channel/user"]
	hit = false
    	for folder in folders
    		Find.find(folder) do |path|
    			if FileTest.directory?(path)
				next
    			else
    				path =~ /^(.+)\.(.+?)$/
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
    						cmdline = "#{lang} #{filename} #{args}"
    					else
    						cmdline = "#{lang} #{filename}"
    					end

    					puts "Exec    : '" + cmdline + "'"
    					r, w = IO.pipe
    					pid = fork {
						STDOUT.reopen w
						w.close
    						system(cmdline)
					}
					begin
						timeout(11) {
	    						w.close
	    						response = ""
	    						while ((line=r.readline))
	    							response += line + "\n"
	    						end
		    					if response.length == 0; response = "No Output."; end
		    					sendChannel response
    						}
    					rescue Timeout::Error => ex
    						sendChannel "Command timed out - " + pid
	    				end
    				end
    			end
    		end
    	end
	if command.chomp == 'mem'
		response = memUsage
		sendChannel response
	end
	if hit == false
		sendChannel "Command not found"
    	end
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
			runCommand $1, $2, nick, host
		when /^@(.+)$/
			runCommand $1, "", nick, host
		when /^ROW ROW$/
			sendChannel "FIGHT THE POWAH!"
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
		else
			sendPrivate msg, nick
	end
    end
end

tinderConnect("irc.gamesurge.net","6667","Tinder",["codeworkshop","nesreca","v7test"])
