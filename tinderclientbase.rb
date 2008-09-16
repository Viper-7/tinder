require 'drb'
require 'socket'
require 'timeout'
require 'find'

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

    def shutDown()
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

