require 'tinderclientbase.rb'
require 'net/http'
require 'open-uri'

class TinderChannel < TinderChannelBase
    include DRbUndumped

    attr_accessor :rss_tvnzb_buffer, :rss_nzbsrus_buffer

    def initialize(channel, tinderBot)
    	@rss_tvnzb_buffer = Array.new
	@rss_nzbsrus_buffer = Array.new
    	super(channel, tinderBot)
    end

    def tinyURL(url)
    	return open('http://tinyurl.viper-7.com/?url=' + url).read
    end

    def startRSS(url, buffer)
	source = url # url or local file
	content = "" # raw content of rss feed will be loaded here
	open(source) do |s| content = s.read end
	rss = RSS::Parser.parse(content, false)
	count = 0

	rss.items.each{|x|
		if !buffer.include?(x.title + ' - ' + x.link)
			buffer.push(x.title + ' - ' + x.link)
			count += 1
		end
	}
	puts "Added #{count} entries to RSS log"
    end

    def updateRSS(url, buffer)
	source = url # url or local file
	content = "" # raw content of rss feed will be loaded here
	open(source) do |s| content = s.read end
	rss = RSS::Parser.parse(content, false)
	count = 0

	rss.items.each{|x|
		if !buffer.include?(x.title + ' - ' + x.link)
			count += 1
			buffer.push(x.title + ' - ' + x.link)
			sendChannel 'New NZB: ' + x.title + ' - ' + tinyURL(x.link)
		end
	}
	puts "Polled RSS, found #{count} entries" if count > 0
    end

    def latestnzb(nzb)
    	output = ""
    	if @rss_tvnzb_buffer.length > 0
		@rss_nzbsrus_buffer.each {|x|
			if x.match(/#{nzb}/i)
				output = x
			end
		}
		@rss_tvnzb_buffer.each {|x|
			if x.match(/#{nzb}/i)
				output = x
			end
		}
	end
	output = 'No Hits, try using .+ between words.' if output == ""
	return output
    end

    def lastnzb
    	output = ""
    	if @rss_tvnzb_buffer.length > 0
		lasttvnzb = @rss_tvnzb_buffer.last.to_s
		lastnzbsrus = @rss_nzbsrus_buffer.last.to_s
		output = 'Latest TVNZB: ' + lasttvnzb + "\n" + 'Latest NZBsRUs: ' + lastnzbsrus
	end
	return output
    end

    def poll
    	super
    	if @channel.to_s == 'nesreca'
	    	startRSS("http://www.tvnzb.com/tvnzb_new.rss",@rss_tvnzb_buffer) if @uptime == 2
	    	updateRSS("http://www.tvnzb.com/tvnzb_new.rss",@rss_tvnzb_buffer) if @uptime % 60 == 0

	    	startRSS("http://www.nzbsrus.com/rssfeed.php",@rss_nzbsrus_buffer) if @uptime == 2
	    	updateRSS("http://www.nzbsrus.com/rssfeed.php",@rss_nzbsrus_buffer) if @uptime % 60 == 0
	end
    end

    def fuckYou(nick)
	vagoo = ["Abyss","Afro clam","Almeja","Axe wound","BAP (Bad Ass Pussy)","Bacon strip","Badly wrapped kebab","Bajingo","Bald man in a boat","Baloney sandwich","Bearded clam","Bearded taco","Beaver","Beaver Cleaver","Beef curtain","Beef garage","Beef jacket","Beefgina","Bermuda triangle","Biff","Biffen","Birdy","Birth cannon","Bitchcake","Bizzle","Black cat with its throat cut","Black hole Of Calcunta","Blood tap","Blurt","Bologna curtains","Bone hone","Bone yard","Boogina","Bottomless pit","Box","Box lunch at Y","Boy in boat","Breakfast","Breakfast of champions","Buhgina","Bulldog's lip","Bunny","Bush","Cake","Camel hoof","Camel toe","Camp coochie","Catcher's mitt","Catfish","Cathedral","Cathouse","Cauliflower","Cave","Cha-cha","Chia pet","Chocha","Choochi snorcher","Chopped ham","Chuff","Chumino","Clam","Clamato fountain","Clamburger","Clodge","Clown's pocket","Cock cave","Cock cozy","Cock garage","Cock holster","Cock milk","Cock pit","Cock pocket","Cock sheath","Cock socket","Cock tub","Cockwash","Cod canal","Concha","Conill","Cooch","Coochie","Cookie","Coon","Coonie","Coont","Cootch","Cooter","Cooz(e)","Cradle of filth","Creamery","Crotch cobbler","Crotch mackerel","Crotch taco","Cum bucket","Cum canal","Cum catcher","Cum dumpster","Cum target","Cunny","Cunt","Cunti","DNA dumpster","DNA slurpee machine","Dank diner","Delta of Venus","Dent","Dick dent","Dick depot","Dick dock","Dick drive","Dick holster","Dick sharpener","Dick shed","Dick's crib","Dicky Dino","Dirty cumpie","Ditch","Divit","Dripping slit","Droog","Dyke snack","Easy bake oven","Everlasting Gobstuffer","Fadge","Fandango","Fertile delta","Festering wound","Filthy hatchet wound","Finger warmer","Fish factory","Fish fanny","Fish hole","Fish pie","Fish taco","Flaming lips","Flange","Flesh curtains","Flesh flute case","Flesh tuxedo","Flesh wallet","Flesh wound","Flounder","Flower","Fluff","Fluffy sausage wallet","Fluttering love wallet","Foo foo","Foof","Foofy bird","Fortune nookie","Foster home of Peter Orphan","Foufoune","Four-lipped man eater","Framazama","French poodle","Front-butt","Frothing gash","Fuck hole","Fuffle","Fun bun","Fun tunnel","Fur pie","Furback turtle","Furburger","Furby","Furry front bottom","Furry horse collar","Fuzz box","Fuzzy cup","Fuzzy lap flounder","Fuzzy puddle","Fuzzy taco","Gange","Gap","Gaper","Gaping hole","Garage of love","Gash","Gator grip","Gina","Ginch","Giner","Giney","Gingerbread","Gleaming mound of Venus","Glory hole","Glory road","Gnash","God's master plan","Golden gully","Goldmine","Goo pot","Gooey man trap","Gouge","Grand Canyon","Gravy boat","Grilled cheese","Growler","Gutted hampster","Gutted rabbit","Gynie","Haddock pasty","Hair pie","Hairy Manilow","Hairy Mary","Hairy beaver","Hairy bike rack","Hairy checkbook","Hairy cherry","Hairy clam","Hairy cream pie","Hairy harmonica","Hairy hatchet wound","Hairy headache","Hairy scar","Hairy taco","Ham sandwich","Hamburger","Hatchet wound","Heart-shaped box","Her","Hey nonny nonny","Hidey hole","Hina","Hinge","Hole","Home plate","Honeyhole","Honeypot","Hoo-ha","Hoo-hoo","Hooch","Hoon","Hootch","Hootchie","Hootchie pop","Horizontal fishcake","Hot Box","Hot pocket","Hot quivering love-purse","Hotdog bun","Hummer hole","Illnana","In hole","Jack Nastyface","Jack in box","Jellyroll","Jizz receptacle","Juice box","Kini","Kit-Kat","Kitty","Knob gobbler","Knots landing","Koo koo","Kookooyumyumpoon","Kooter","Kunt","Labbe","Landing strip","Lap flounder","Lips that never speak","Lobster claw","Lotus flower","Love muffin","Love muscle","Love pudding","Love tunnel","Lower lips","Man's ruin","Map of Tasmania (Tasi)","Meal ticket","Meat curtains","Meat grinder","Meat muffin","Meat napkin","Meat slipper","Meat wallet","Meatloaf","Mejillon","Miffy","Minge","Minnie's pearl","Miss Pussy","Missile silo","Moan pie","Momma's silk purse","Mommy button","Money box","Money maker","Monkey","Mooch","Moose knuckle","Moose's lip","Mother Theresa","Motherload","Mound","Mrs. Sphincter's next door neighbor","Mucker","Muckhole","Mud flaps","Muff","Muff monster","Muffhole","Muffin","Muffler","Muffy","Munch box","Mushy mushy","Mutton chops","Mutton flaps","Na-na","Na-ner na-ner pudding","Nappy canoe","Nappy dugout","Nethermeats","Ninja slipper","Nipper","Nookie","Nooner","Oak tree planter","Old Mother Hubbard","Old bacon strip","Old toothless","Oonie","Orchid boat","Organ grinder","Otter's pocket","Oval office","Oyster taco","Panocha","Panty hamster","Passion flower","Patona","Peach","Peach fish","Pearl pit","Pecan Pattie","Pecker-snot repository","Pee bug","Peeper","Pelt","Penis holster","Penis penitentiary","Penis piranha","Penis pocket","PenisStation","Peter pleaser","Peter's punching bag","Phat rabbit","Pink brownie cake","Pink canoe","Pink lipped custard sucker","Pink lips","Pink palace","Pink panda","Pink petaled posie","Pink pie","Pink pit of pleasure","Pink stink","Pink taco","Pinkly stinkly","Pish","Piss curtains","Piss flaps","Plewie","Po-po","Pocketbook","Poke hole","Pookie","Poon","Poonani","Poontang","Poontang pie","Poosazi","Pooter","Pootie poo","Pootietang","Pootnanny","Pooty poo","Pork danglies","Postage stamp (you lick it, you stick it, you send it on its way)","Pot holder","Prayer muffin","Prick pit","Promised Land","Pu-jar","Puddin pie","Pudi","Pumpkin blossom","Puna","Punani","Puni","Pushin' cushion","Pussy","Putang","Puter","Puty pu","Quiff","Quim","Quinnie","Quivering mound of love pudding","Raw oyster","Receptacle","Red haired lass","Red snapper","Roast beef curtain","Roast beef pita","Rocket pocket","Rod roaster","Rooster fish","Rosebud","Round mound of repound","Rug","Rusty axe wound","Sacapuntas","Sagging bacon cones","Salami sandwich","Salmon scented semen sucker","Sausage wallet","Scrunt","Seafood taco","Sex hole","Shnush","Shooting range","Shrimp boat","Shrimp pie","Shutters of love","Silk igloo","Skunk guts","Slice","Slickety squid","Slime slit","Slimey slot","Slippery sheath","Slit","Slobbering bulldog","Sloppy joe","Sloppy oyster","Slot A","Slug's belly","Smackey","Smelly jelly hole","Smoo","Snack box","Snack pack","Snake charmer","Snapper","Snatch","Snizzle","Snotty lips","Snutch","Soft taco","South mouth","Southern smile","Spam castanet","Sperm bank","Sperm belcher","Sperm harbor","Split knish","Split-faced hair shark","Splittail","Spock-socket","Spunk locker","Spunk pit","Squashed hedgehog","Squirt bucket","Squishy","Stanky","Stench trench","Sticky bun","Stink hole","Stinkinoonie","Stinky krinky","Stinky pink","Stuffed stocking","Sugar walls","Sweaty burrito","Sweet spot","Sword swallower","Taffy puller","Tang","Tasty little morsel","Tinkleflower","Treasure chest","Tri-fold floppy","Trout basket","Tulip","Tuna 'n' whiskers","Tuna melt","Tuna taco","Tuna town","Tuna tunnel","Tunnel","Tunnel of love","Turkey beard","Turkey curtains","Tutu","Twat","Twat waffle","Twisted taco","Two fingered fish mitten","Two-lips","Underwear oyster","Upside down taco","Vadge","Vagittyfidgit","Vagooter","Vaheena","Veeg","Velvet box","Velvet glove","Venus fly trap","Venus jive trap","Vertical bacon slice","Vertical grimace","Vertical smile","Vertical taco","Vice of love","Warm slurpee","Wazza","Weenie wringer","Welly-boot top","Welly-top","Wet wrinkle","Whisker biscuit","Whooha","Wide open spaces","Wide papaya smile","Willy washer","Winkin' pink brownie cake","Wizard's sleeve","Wookie","Wookie hole","Woolen bivalve","Worm hole","Wound that never heals","Wrinkle","Wuzza","X-Box","Ya-ya","Yeast cake","Yo-yo smuggler","Yoni","Yum yum","Zone"].sort_by{rand}.first
	dirty = ["abject", "bedraggled", "befouled", "begrimed", "besmeared", "contemptible", "daggletailed", "defiled", "despicable", "dishonorable", "disreputable", "excrementitious", "feculent", "filthy", "foul", "grimy", "groveling", "insanitary", "loathsome", "nasty", "ordurous", "putrid", "saprogenic", "sleazy", "soiled", "sordid", "squalid", "stercoraceous", "sullied", "unclean", "uncleanly", "unsportsmanlike", "vile"].sort_by{rand}.first
	whore = ["bawd", "courtesan", "cyprian", "demirep", "drab", "harlot", "hooker", "hussy", "pro", "prostitute", "punk", "slut", "streetwalker", "strumpet", "tramp", "wench", "woman of ill fame"].sort_by{rand}.first
	sendChannel "Fuck my #{vagoo.downcase} #{nick.downcase} you #{dirty} #{whore}."
    end

    def channelText(nick, host, msg)
    	super(nick,host,msg)
    	case msg
		when /^ROW ROW$/
			sendChannel "FIGHT THE POWAH!"
		when /fuck you/i
			fuckYou nick
	end
    end
end

tinderClient, tinderBot, tinderChannels = addServer("irc.gamesurge.net","6667","Tinder",["codeworkshop","v7test","ausquake","nesreca"])
addDirectoryWatcher('/mnt/dalec/Documents and Settings/Viper-7/My Documents/My Dropbox/nesreca', 'Dropbox', 'nesreca', 'http://dropbox.intertoobz.com/', tinderChannels)
connect tinderBot, tinderChannels
