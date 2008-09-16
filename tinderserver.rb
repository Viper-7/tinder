require 'drb'

class TinderClient
    include DRbUndumped

    require 'socket'
    require 'timeout'

    trap("INT") {
    	shutDown
    }

    attr_accessor :server, :nick, :port, :open, :tinderBots, :connected, :buffer

    def initialize
        @joined = Array.new
        @tinderBots = Array.new
        @buffer = Array.new
        @open = false
        @debug = false
    end

    def memUsage
	response = %x[ps -eo 'cputime,%cpu,%mem,vsz,sz,command']
	output = ""
	response.each_line {|x|
		z = ""
		x = x.gsub(/  /,' ')
		x = x.split(/ /)
		x.each {|y|
			if y.length > 3
				z += y.rjust(8, '_')
			else
				z += y.rjust(5, '_')
			end
		}
		x = x.join
		z =~ /(.+?)tinder(.+)/
		if $1 != nil
			output = "#{$1}tinder#{$2}"
		end
	}
	if output == ""
		output = "Fail"
	end
	return output
    end

    def connectServer(server,port,nick)
        @server = server
        @nick = nick
        @port = port

	if !@tcpSocket
		@open = true
		serverListenLoop()
	end
    end

    def addBot
        if @open == true
	        newBot = TinderBot.new(self)
	        @tinderBots.push newBot
	        puts "Added Bot"
	    	return newBot
	    	newBot = nil
	else
		puts 'error: Client tried to create a bot with no server'
	end
    end

    def removeBot(bot)
    	@tinderBots.delete(bot)
    	puts "Removed Bot"
    end

    def serverListenLoop()
        timeout(30) do
        	begin
			@tcpSocket = TCPSocket.new(server,port)
		rescue
			puts "error: #{$!}"
			shutdown
		else
			@open = true
			@tcpSocket.send "NICK #{@nick}\n", 0
			@tcpSocket.send "USER #{@nick} localhost irc.freenode.net :#{@nick}\n", 0
		end
	end
	Thread.start() {
		trap("INT") {
			shutDown
		}
		loop do
			break if !@tcpSocket
			sleep(0.3)
			next if @buffer.length == 0
			if @debug == true
				puts @buffer[0]
			end
			@tcpSocket.send @buffer.shift.to_s, 0
		end
		shutDown
	}
	Thread.start() {
		trap("INT") {
			shutDown
		}
		loop do
			break if !@tcpSocket
			sleep(0.3)
			msg = @tcpSocket.gets
			next if msg == nil
			serverEvent(msg)
		end
		shutDown
	}
    end

    def send(msg)
    	msg = msg.gsub(/lemonparty/, 'rickroll')
        @buffer.push "#{msg}\n"
    end

    def sendCTCP(msg, destination)
	lines=0; if msg.length > 2048; lines = 999; end
	msg.each_line{|line| if line.length > 400; lines = 999; break; end; lines += 1 }
	if lines > 8; msg = "Response too long"; end
	msg.each_line{|line| send "PRIVMSG #{destination} :\x01#{line}\x01"}
    end

    def sendChannel(msg, channel)
	lines=0; if msg.length > 2048; lines = 999; end
	msg.each_line{|line| if line.length > 400; lines = 999; break; end; lines += 1 }
	if lines > 8; msg = "Response too long"; end
	msg.each_line{|line| send "PRIVMSG ##{channel} :#{line}"}
    end

    def sendPrivate(msg, nick)
	lines=0; if msg.length > 2048; lines = 999; end
	msg.each_line{|line| if line.length > 400; lines = 999; break; end; lines += 1 }
	if lines > 8; msg = "Response too long"; end
	msg.each_line{|line| send "PRIVMSG #{nick} :#{line}"}
    end

    def shutDown()
    	@open = false
    	@tcpSocket.close if @tcpSocket != nil
    	@tcpSocket = nil
    	@tinderBots.each {|x|
    		x.shutDown
    	}
    	@tinderBots.clear
	@connected=false
    	DRb.stop_service
    end

    def joinChannel(channel)
        send "JOIN \##{channel}"
        if !@joined.include?(channel)
            @joined.push(channel)
        else
            @joined.delete(channel)
            @joined.push(channel)
        end
    end

    def partChannel(channel)
        if @joined.include?(channel)
            send "PART \##{channel}"
            @joined.delete(channel)
        end
    end

    def serverEvent(msg)
	if @debug == true
	    	puts msg
	end
        case msg.strip
            when /^ERROR :/
		if @debug != true
			puts msg
		end
            	puts "Fatal Error, Closing"
            	shutDown
            when /^error :/
		if @debug != true
			puts msg
		end
            	puts "Fatal Error, Closing"
            	shutDown
            when /^PING :(.+)$/i
                puts "Ping? Pong."
                send "PONG :#{$1}"
            when /^:(.+?)!(.+?)@(.+?) PRIVMSG #{@nick} :\x01PING (.+)\x01$/i
                puts "[ CTCP PING from #{$1}!#{$2}@#{$3} ]"
                send "NOTICE #{$1} :\x01PING #{$4}\x01"
            when /^:(.+?)!(.+?)@(.+?) PRIVMSG #{@nick} :\x01VERSION\x01$/i
                puts "[ CTCP VERSION from #{$1}!#{$2}@#{$3} ]"
                send "NOTICE #{$1} :\x01VERSION TinderBot v0.001\x01"
            when /^:(.+?)!(.+?) PRIVMSG #{@nick} :(.+)$/
                privateText $1, $2, $3
            when /^:(.+?)!(.+?) PRIVMSG \#(.+?) :(.+)$/
                channelText $3, $2, $1, $4
            when /001 #{@nick}/i
		if !@connected
			@tinderBots.each {|x| x.connected()}
			@connected=true
		end
            else
            	serverText msg
        end
    end

    def serverText(msg)
    	break if @tinderBots.length == 0
        @tinderBots.each {|x|
	    	begin
	        	x.serverText(msg)
	    	rescue Exception => ex
			puts ex.message
			removeBot(x)
	    	end
	}
    end

    def channelText(channel, host, nick, msg)
    	break if @tinderBots.length == 0
        @tinderBots.each {|x|
	    	begin
	    		x.channelText channel, host, nick, msg
	    	rescue Exception => ex
			puts ex.message
			removeBot(x)
	    	end
	}
    	if msg == '@mem'
    		response = memUsage
    		sendChannel response, channel
    	end
    end

    def privateText(nick, host, msg)
    	break if @tinderBots.length == 0
        @tinderBots.each {|x|
	    	begin
	    		x.privateText(nick, host, msg)
	    	rescue Exception => ex
			puts ex.message
			removeBot(x)
	    	end
	}
    end
end

class TinderBot
    include DRbUndumped

    attr_accessor :spamTime, :tinderClient, :channels, :open

    def initialize(client)
    	@tinderClient = client
        @channels = Array.new
	@open = true
    end

    def addChannel(channel)
        @channels.push channel

        if @tinderClient.connected == true
        	@open = true
	    	@tinderClient.joinChannel channel.channel.to_s
		channel.connected
	end
    end

    def nick
    	return @tinderClient.nick
    end

    def send(msg)
    	@tinderClient.send msg
    end

    def sendChannel(msg, channel)
    	@tinderClient.sendChannel(msg, channel)
    end

    def sendPrivate(msg, nick)
    	@tinderClient.sendPrivate(msg, nick)
    end

    def sendCTCP(msg, destination)
    	@tinderClient.sendCTCP(msg, destination)
    end

    def serverText(msg)
        case msg.strip
            when /^:(.+)!(.+?) MODE #(.+?) (.+?) :(.+)$/	#User!~ident@host MODE  Channel Mode Message
            	channelEvent $3, $2, $1, $4, $5
            when /^:(.+)!(.+?) TOPIC #(.+?) :(.+)$/		#User!~ident@host TOPIC Channel Message
            	channelEvent $3, $2, $1, "TOPIC", $4
            when /^:(.+)!(.+?) (.+?) #(.+?) (.+?) :(.+)$/ 	#User!~ident@host Event Channel Target Message
            	channelEvent $4, $2, $5, $3, $6
            when /^:(.+)!(.+?) (.+?) #(.+?) (.+?) (.+)$/ 	#User!~ident@host Event Channel Target Mode
            	channelEvent $4, $2, $5, $3, $6
            when /^:(.+)!(.+?) (.+?) #(.+?) (.+)$/		#User!~ident@host Event Channel Mode
            	channelEvent $4, $2, $1, $3, $5
            when /^:(.+)!(.+?) (.+?) #(.+)$/ 			#User!~ident@host Event Channel
            	channelEvent $4, $2, $1, $3, $1
            else
	    	@channels.each {|x| x.serverText msg }
        end
    end

    def channelText(channel, host, nick, msg)
    	@channels.find{|x| x.channel==channel}.channelText(nick, host, msg)
    end

    def channelEvent(channel, host, nick, event, msg)
    	@channels.find{|x| x.channel==channel}.channelEvent(channel, host, nick, event, msg)
    	if event == "KICK" and nick == @tinderClient.nick
    		@tinderClient.joinChannel channel
    	end
    end

    def privateText(nick, host, msg)
    	@channels.first.privateText(nick, host, msg)
    end

    def close
    	@tinderClient.shutDown
    end

    def connected
	@open = true
    	@channels.each {|tinderChannel| @tinderClient.joinChannel tinderChannel.channel.to_s }
    	@channels.each {|tinderChannel| tinderChannel.connected }
    end

    def shutDown()
	@open = false
    	@channels.each {|tinderChannel| tinderChannel.shutDown }
    	@tinderClient.removeBot(self)
    	@channels.clear
    end
end

DRb.start_service("druby://:7777", TinderClient.new)
puts DRb.uri
DRb.thread.join
load 'tinderserver.rb'
