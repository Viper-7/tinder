require 'tinderChannelBase.rb'

tinderClient, tinderBot, tinderChannels = addServer("irc.gamesurge.net","6667","Tinder",["codeworkshop","v7test","nesreca"],TinderChannelBase)
addAdminHost('Viper-7!druss@viper-7.com', tinderChannels)
connect tinderClient, tinderBot, tinderChannels
