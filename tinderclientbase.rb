require 'drb'
require 'socket'
require 'timeout'
require 'find'

STDOUT.sync = true

DRb.start_service

class TinderClientBase
    include DRbUndumped

    attr_accessor :channel, :tinderBot, :nick, :graceful

    def initialize(channel, tinderBot)
        @channel = channel
        @graceful = false
        @tinderBot = tinderBot
    	@tinderBot.addChannel(self)
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
end

def tinderConnect(server,port,nick,channels,channelclass)
	puts "Status  : Connecting..."
	begin
		tinderClient1 = DRbObject.new(nil, 'druby://'+ ARGV[0] +':7777')
	rescue
		puts "Status  : Failed to connect to Tinder server"
		exit 0
	end

	tinderClient1.connectServer(server, port, nick)
	tinderBot1 = tinderClient1.addBot
	tinderChannels = Array.new

	channels.each {|x|
		tinderChannels.push channelclass.new(x.to_s, tinderBot1)
	}

	trap("INT") {
		tinderChannels.first.graceful = false
		tinderBot1.close
		tinderBot1 = nil
		sleep(2)
		exit 0
	}

	puts "Status  : Running..."
	DRb.thread.join
	if tinderChannels.first.graceful == true
		exit 1
	else
		exit 0
	end
end