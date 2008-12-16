require 'drb'
require 'socket'
require 'timeout'

class TinderServer
    attr_accessor :server, :nick, :port, :open, :tinderBots, :connected, :buffer, :joined

    def initialize
        @joined = Array.new
        @tinderBots = Array.new
        @buffer = Array.new
        @open = false
        @debug = false
        @ping = true
    end

    def disconnect
        @buffer.push "QUIT :Tinder :D\n"
        sleep 2
        @tcpSocket.close if @tcpSocket != nil
        @tcpSocket = nil
        restart
        DRB.stop_service
        raise Exception
    end

    trap("INT") {
    	disconnect
    }

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
		output = "Server Fail"
	end
	return output[3..-1]
    end

    def connectServer(server,port,nick)
        @server = server
        @nick = nick
        @port = port

	if @open != true
		@open = true
		serverListenLoop()
	end
    end

    def addBot
        if @open == true
        	sleep 0.2
	        newBot = TinderBot.new(self)
	        @tinderBots.push newBot
	        puts "tinderBot - Added Bot" if @debug == true
	        p @tinderBots.length.to_s + ' Bots'
	    	
	    	return newBot
	else
		puts 'error: Client tried to create a bot with no server'
	end
    end

    def removeBot(bot)
    	begin
    		@tinderBots.delete(bot) if @tinderBots.include?(bot)
    	rescue Exception => ex
    		puts ex
		p ex.backtrace
    		@tinderBots.clear
    	end
    	puts "tinderBot - Removed Bot" if @debug == true
    end

    def serverListenLoop()
        timeout(30) do
        	begin
			@tcpSocket = TCPSocket.new(server,port)
		rescue
			puts "error: #{$!}"
			restart
		else
			@open = true
			@tcpSocket.send "NICK #{@nick}\n", 0
			@tcpSocket.send "USER #{@nick} localhost irc.freenode.net :#{@nick}\n", 0
		end
	end
	Thread.start() {
		trap("INT") {
			halt
		}
		loop do
			break if !@tcpSocket
			sleep(0.1)
			if @buffer.length > 12
				puts 'Dumped Buffer'
				@buffer.clear
			end
			next if @buffer.length == 0
			puts @buffer[0] if @debug == true
			@tcpSocket.send @buffer.shift.to_s, 0
			sleep(0.2)
		end
		@open = false
		halt
	}
	Thread.start() {
		trap("INT") {
			halt
		}
		loop do
			break if !@tcpSocket
			sleep(0.1)
			msg = @tcpSocket.gets
			next if msg == nil
			serverEvent(msg)
		end
		@open = false
		halt
	}
    end

    def send(msg)
    	msg = msg.gsub(/lemonparty/, 'rickroll')
        @buffer.push "#{msg}\n"
    end

    def sendCTCP(msg, destination)
	lines = 0
	lines = 999 if msg.length > 4096
	msg.each_line{|line|
		if line.length > 400
			lines = 999
			break
		end
		lines += 1 if line.chomp.length > 2
	}
	msg = "Response too long" if lines > 12
	msg.each_line{|line| send "PRIVMSG #{destination} :\x01#{line}\x01" if line.length > 2}
    end

    def sendChannel(msg, channel)
	lines = 0
	lines = 999 if msg.length > 4096
	msg.each_line{|line|
		if line.length > 400
			lines = 999
			break
		end
		lines += 1 if line.chomp.length > 2
	}
	msg = "Response too long" if lines > 15
	msg.each_line{|line| send "PRIVMSG ##{channel} :#{line}" if line.length > 2}
    end

    def sendPrivate(msg, nick)
	lines = 0
	lines = 999 if msg.length > 4096
	msg.each_line{|line|
		if line.length > 400
			lines = 999
			break
		end
		lines += 1 if line.chomp.length > 2
	}
	msg = "Response too long" if lines > 12
	msg.each_line{|line| send "PRIVMSG #{nick} :#{line}" if line.length > 2}
    end

    def halt
    	@open = false
    	@connected = false
    	@tcpSocket.close if @tcpSocket != nil
	@tcpSocket = nil
    	@tinderBots.each {|x|
		begin
	    		x.shutDown
	    	rescue Exception => ex
			puts ex
		end
	}
	@joined.clear
	@tinderBots.clear
    	DRb.stop_service
    	exit
    end

    def restart
    	@tinderBots.each {|x|
		begin
	    		x.shutDown
	    	rescue Exception => ex
			puts ex
			p ex.backtrace
			removeBot(x)
	    	end
    	}
    	@tinderBots.clear
    	@joined.clear
	load 'tinderServerBase.rb'
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
            puts 'Left Channel'
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
            	puts "tinderBot Fatal Error, Closing"
            	restart
            when /^error :/
		if @debug != true
			puts msg
		end
            	puts "tinderBot Fatal Error, Closing"
            	restart
            when /^PING :(.+)$/i
                send "PONG :#{$1}"
                puts 'PONG ' + Time.now.to_s
                begin
                	@tinderBots.each {|x|
                		timeout(10) do
                			x.ping
                		end
                	}
                rescue Exception => ex
                	# don't die
                end
            when /^:(.+?)![~]?(.+?)@(.+?) PRIVMSG #{@nick} :\x01PING (.+)\x01$/i
                send "NOTICE #{$1} :\x01PING #{$4}\x01"
            when /^:(.+?)![~]?(.+?)@(.+?) PRIVMSG #{@nick} :\x01VERSION\x01$/i
                send "NOTICE #{$1} :\x01VERSION TinderBot v0.001\x01"
            when /^:(.+?)![~]?(.+?) PRIVMSG #{@nick} :(.+)$/
                privateText $1, $2, $3
            when /^:(.+?)![~]?(.+?) PRIVMSG \#(.+?) :(.+)$/
                channelText $3, $2, $1, $4
            when /001 #{@nick}/i
		if !@connected
		    	@tinderBots.each {|x|
			    	begin
					x.connected()
			    	rescue Exception => ex
					removeBot(x)
					puts ex
					p ex.backtrace
			    	end
			}
			@connected = true
		end
            else
            	serverText msg
        end
    end

    def serverText(msg)
        @tinderBots.each {|x|
	    	begin
	        	x.serverText(msg)
	    	rescue Exception => ex
			removeBot(x)
			puts ex
			p ex.backtrace
	    	end
	}
    end

    def channelText(channel, host, nick, msg)
        @tinderBots.each {|x|
	    	begin
	    		x.channelText channel, host, nick, msg
	    	rescue Exception => ex
			removeBot(x)
			puts ex
			p ex.backtrace
	    	end
	}
    	if msg == '@mem'
    		response = memUsage
    		sendChannel response, channel
    	end
    end

    def privateText(nick, host, msg)
        @tinderBots.each {|x|
	    	begin
	    		x.privateText(nick, host, msg)
	    	rescue Exception => ex
			removeBot(x)
			puts ex
			p ex.backtrace
	    	end
	}
    end
end

class TinderBot
    attr_accessor :spamTime, :tinderServer, :channels, :open, :dumpchans, :lastStatus
    attr_reader :nick
    
    def initialize(server)
    	@tinderServer = server
        @channels = Array.new
    	@dumpchans = Array.new
	@open = true
	@lastStatus = ""
    end

    def addChannel(channel)
        @channels.push channel

        if @tinderServer.connected == true
        	@open = true
	    	@tinderServer.joinChannel channel.channel.to_s if channel.channel.to_s != 'www'
	    	@nick = @tinderServer.nick
		channel.connected
	end
    end

    def adddumpchan(tochannel, fromchannel, regexp = /.+/)
    	@dumpchans.push [tochannel, fromchannel, regexp]
    end

    def stopdump
	@dumpchans.clear
    end

    def halt
	@tinderServer.halt
    end

    def ping
	@channels.each {|x|
		begin
			timeout(5) do
				x.ping
			end
		rescue Exception => ex
			# Don't Die
		end
	}
    end

    def clearPing
	@channels.each {|x|
		begin
			timeout(5) do
				x.clearPing
			end
		rescue Exception => ex
			# Don't Die
		end
	}
    end

    def send(msg)
    	@tinderServer.send msg
    end

    def rejoinChannel(channel)
    	@tinderServer.joinChannel channel.to_s
    end

    def sendChannel(msg, channel)
    	@tinderServer.sendChannel(msg, channel)
    end

    def sendPrivate(msg, nick)
    	@tinderServer.sendPrivate(msg, nick)
    end

    def sendCTCP(msg, destination)
    	@tinderServer.sendCTCP(msg, destination)
    end

    def serverText(msg)
    	ping
        case msg.strip
            when /^:(.+)![~]?(.+?) MODE #(.+?) (.+?) :(.+)$/	# User!~ident@host MODE  Channel Mode :Message
            	channelEvent $3, $2, $1, $4, $5
            when /^:(.+)![~]?(.+?) TOPIC #(.+?) :(.+)$/		# User!~ident@host TOPIC Channel :Message
            	channelEvent $3, $2, $1, "TOPIC", $4
            when /^:(.+)![~]?(.+?) PART #(.+?) :(.+)$/		# User!~ident@host PART	Channel :Message
            	channelEvent $3, $2, $1, "PART", $4
            when /^:(.+)![~]?(.+?) (.+?) #(.+?) (.+?) :(.+)$/ 	# User!~ident@host Event Channel Target :Message
            	channelEvent $4, $2, $5, $3, $6
            when /^:(.+)![~]?(.+?) (.+?) #(.+?) (.+?) (.+)$/ 	# User!~ident@host Event Channel Mode Target
            	channelEvent $4, $2, $6, $3, $5
            when /^:(.+)![~]?(.+?) (.+?) #(.+?) (.+)$/		# User!~ident@host Event Channel Mode
            	channelEvent $4, $2, $1, $3, $5
            when /^:(.+)![~]?(.+?) (.+?) #(.+)$/ 		# User!~ident@host Event Channel
            	channelEvent $4, $2, $1, $3, ''
            when /^:(.+)![~]?(.+?) QUIT :(?:Quit )?(?::?(.+))?$/ # User!~ident@host QUIT( :Message)
	    	if $3 != nil # Ignore Quits
	    		# @channels.each {|x| channelEvent x.channel, $2, $1, 'QUIT', $3}
	    	else
	    		# @channels.each {|x| channelEvent x.channel, $2, $1, 'QUIT', ''}
		end
            else
	    	@channels.each {|x| x.serverText msg }
        end
    end

    def channelText(channel, host, nick, msg)
    	ping
    	@channels.find{|x| x.channel==channel}.channelText(nick, host, msg)
	@dumpchans.each{|x| sendChannel "\##{channel} \<#{nick}\> #{msg}", x[0] if channel==x[1] and x[2].match(msg)}
    end

    def channelEvent(channel, host, nick, event, msg = "")
    	ping
    	@channels.find{|x| x.channel==channel}.channelEvent(channel, host, nick, event, msg)
    end

    def privateText(nick, host, msg)
    	ping
    	@channels.first.privateText(nick, host, msg)
    end

    def close
    	@open = false
    	@tinderServer.shutDown
    end

    def rehash
    	@open = false
    	@tinderServer.removeBot(self)
    end

    def connected
	@open = true
    	@channels.each {|tinderChannel| @tinderServer.joinChannel tinderChannel.channel.to_s }
    	@channels.each {|tinderChannel| tinderChannel.connected }
    end

    def shutDown()
	@open = false
	@channels.each {|tinderChannel| tinderChannel.shutDown }
    	@tinderServer.removeBot(self)
    end

    def status(msg)
	@channels.first.statusMsg msg.to_s if msg != @lastStatus
	@lastStatus = msg
    end
end
