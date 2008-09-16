require 'tinderclientbase.rb'

class TinderChannel < TinderClientBase
    include DRbUndumped

    def runCommand(command, args, nick, host)
    	puts "Status  : Running command '" + command + " " + args + "'"
    	folders = ["/opt/ii/scripts/user","/opt/ii/scripts/by_nick","/opt/ii/scripts/builtin"]
	hit = false
    	for folder in folders
    		Find.find(folder) do |path|
    			if FileTest.directory?(path)
				next
    			else
    				if command.chomp == File.basename(path.downcase)
    					hit = true

    					args.gsub(/rm/, 'rn')
    					args.gsub(/mail/, 'm@il')
    					lang = path.split('/')[5]

    					ENV['IIBOT_DIR'] = path.split('/')[0..2].join('/')
    					ENV['IIBOT_TEMP_DIR'] = ENV['IIBOT_DIR'] + '/tmp'
    					ENV['IIBOT_SCRIPT_DIR'] = ENV['IIBOT_DIR'] + '/scripts'

    					if args.length > 0
    						args = '"' + args.scan(/ /){|w| w = w + '" "' } + '"'
    						cmdline = "#{lang} #{path} #{args}"
    					else
    						cmdline = "#{lang} #{path}"
    					end

    					puts "Exec    : '" + cmdline + "'"
    					timeout(10) {
    						response = %x[#{cmdline}]
	    					if response.length == 0; response = "No Output."; end
	    					sendChannel response
    					} rescue sendChannel "Command timed out"
    				end
    			end
    		end
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
    	if host == '~druss@viper-7.com'
    		case msg
    			when /^RELOADCLIENT|REHASH$/
    				sendPrivate "Roger that, " + nick, nick
				puts "Status  : Reloaded by request from " + host
				@graceful = true
				@tinderBot.shutDown
				@tinderBot = nil
				break
    			when /^RELOADSERVER$/
    				sendPrivate "Roger that, " + nick, nick
				puts "Status  : Reconnecting by request from " + host
				@graceful = true
				@tinderBot.close
				@tinderBot = nil
				break
    			when /^KILLCLIENT$/
    				sendPrivate "Roger that, " + nick, nick
				puts "Status  : Killed by request from " + host
				@graceful = false
				@tinderBot.shutDown
				@tinderBot = nil
				break
			when /^KILLSERVER$/
    				sendPrivate "Roger that, " + nick, nick
				puts "Status  : Killed server by request from " + host
				@graceful = false
				@tinderBot.close
				@tinderBot = nil
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


puts "Status  : Connecting..."
begin
	tinderClient1 = DRbObject.new(nil, 'druby://'+ ARGV[0] +':7777')
rescue
	puts "Status  : Failed to connect to Tinder server"
	exit 0
end

tinderClient1.connectServer("irc.gamesurge.net", "6667", "Tinder")
tinderBot1 = tinderClient1.addBot

tinderChannel1 = TinderChannel.new("codeworkshop", tinderBot1)
tinderChannel2 = TinderChannel.new("nesreca", tinderBot1)
tinderChannel3 = TinderChannel.new("v7test", tinderBot1)

trap("INT") {
	tinderChannel1.graceful = false
	tinderBot1.close
	tinderBot1 = nil
	sleep(2)
	exit 0
}

puts "Status  : Running..."
while true
	break if !tinderBot1
	break if tinderBot1.open != true
	STDOUT.flush
	sleep(1)
end
if tinderChannel1.graceful == true
	exit 1
else
	exit 0
end