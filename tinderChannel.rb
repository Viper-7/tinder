require 'tinderChannelBase.rb'
require 'net/http'
require 'open-uri'
require 'mysql'


class TinderChannel < TinderChannelBase
    include DRbUndumped

    def fuckYou(nick)
	vagoo = ["Abyss","Afro clam","Almeja","Axe wound","BAP (Bad Ass Pussy)","Bacon strip","Badly wrapped kebab","Bajingo","Bald man in a boat","Baloney sandwich","Bearded clam","Bearded taco","Beaver","Beaver Cleaver","Beef curtain","Beef garage","Beef jacket","Beefgina","Bermuda triangle","Biff","Biffen","Birdy","Birth cannon","Bitchcake","Bizzle","Black cat with its throat cut","Black hole Of Calcunta","Blood tap","Blurt","Bologna curtains","Bone hone","Bone yard","Boogina","Bottomless pit","Box","Box lunch at Y","Boy in boat","Breakfast","Breakfast of champions","Buhgina","Bulldog's lip","Bunny","Bush","Cake","Camel hoof","Camel toe","Camp coochie","Catcher's mitt","Catfish","Cathedral","Cathouse","Cauliflower","Cave","Cha-cha","Chia pet","Chocha","Choochi snorcher","Chopped ham","Chuff","Chumino","Clam","Clamato fountain","Clamburger","Clodge","Clown's pocket","Cock cave","Cock cozy","Cock garage","Cock holster","Cock milk","Cock pit","Cock pocket","Cock sheath","Cock socket","Cock tub","Cockwash","Cod canal","Concha","Conill","Cooch","Coochie","Cookie","Coon","Coonie","Coont","Cootch","Cooter","Cooz(e)","Cradle of filth","Creamery","Crotch cobbler","Crotch mackerel","Crotch taco","Cum bucket","Cum canal","Cum catcher","Cum dumpster","Cum target","Cunny","Cunt","Cunti","DNA dumpster","DNA slurpee machine","Dank diner","Delta of Venus","Dent","Dick dent","Dick depot","Dick dock","Dick drive","Dick holster","Dick sharpener","Dick shed","Dick's crib","Dicky Dino","Dirty cumpie","Ditch","Divit","Dripping slit","Droog","Dyke snack","Easy bake oven","Everlasting Gobstuffer","Fadge","Fandango","Fertile delta","Festering wound","Filthy hatchet wound","Finger warmer","Fish factory","Fish fanny","Fish hole","Fish pie","Fish taco","Flaming lips","Flange","Flesh curtains","Flesh flute case","Flesh tuxedo","Flesh wallet","Flesh wound","Flounder","Flower","Fluff","Fluffy sausage wallet","Fluttering love wallet","Foo foo","Foof","Foofy bird","Fortune nookie","Foster home of Peter Orphan","Foufoune","Four-lipped man eater","Framazama","French poodle","Front-butt","Frothing gash","Fuck hole","Fuffle","Fun bun","Fun tunnel","Fur pie","Furback turtle","Furburger","Furby","Furry front bottom","Furry horse collar","Fuzz box","Fuzzy cup","Fuzzy lap flounder","Fuzzy puddle","Fuzzy taco","Gange","Gap","Gaper","Gaping hole","Garage of love","Gash","Gator grip","Gina","Ginch","Giner","Giney","Gingerbread","Gleaming mound of Venus","Glory hole","Glory road","Gnash","God's master plan","Golden gully","Goldmine","Goo pot","Gooey man trap","Gouge","Grand Canyon","Gravy boat","Grilled cheese","Growler","Gutted hampster","Gutted rabbit","Gynie","Haddock pasty","Hair pie","Hairy Manilow","Hairy Mary","Hairy beaver","Hairy bike rack","Hairy checkbook","Hairy cherry","Hairy clam","Hairy cream pie","Hairy harmonica","Hairy hatchet wound","Hairy headache","Hairy scar","Hairy taco","Ham sandwich","Hamburger","Hatchet wound","Heart-shaped box","Her","Hey nonny nonny","Hidey hole","Hina","Hinge","Hole","Home plate","Honeyhole","Honeypot","Hoo-ha","Hoo-hoo","Hooch","Hoon","Hootch","Hootchie","Hootchie pop","Horizontal fishcake","Hot Box","Hot pocket","Hot quivering love-purse","Hotdog bun","Hummer hole","Illnana","In hole","Jack Nastyface","Jack in box","Jellyroll","Jizz receptacle","Juice box","Kini","Kit-Kat","Kitty","Knob gobbler","Knots landing","Koo koo","Kookooyumyumpoon","Kooter","Kunt","Labbe","Landing strip","Lap flounder","Lips that never speak","Lobster claw","Lotus flower","Love muffin","Love muscle","Love pudding","Love tunnel","Lower lips","Man's ruin","Map of Tasmania (Tasi)","Meal ticket","Meat curtains","Meat grinder","Meat muffin","Meat napkin","Meat slipper","Meat wallet","Meatloaf","Mejillon","Miffy","Minge","Minnie's pearl","Miss Pussy","Missile silo","Moan pie","Momma's silk purse","Mommy button","Money box","Money maker","Monkey","Mooch","Moose knuckle","Moose's lip","Mother Theresa","Motherload","Mound","Mrs. Sphincter's next door neighbor","Mucker","Muckhole","Mud flaps","Muff","Muff monster","Muffhole","Muffin","Muffler","Muffy","Munch box","Mushy mushy","Mutton chops","Mutton flaps","Na-na","Na-ner na-ner pudding","Nappy canoe","Nappy dugout","Nethermeats","Ninja slipper","Nipper","Nookie","Nooner","Oak tree planter","Old Mother Hubbard","Old bacon strip","Old toothless","Oonie","Orchid boat","Organ grinder","Otter's pocket","Oval office","Oyster taco","Panocha","Panty hamster","Passion flower","Patona","Peach","Peach fish","Pearl pit","Pecan Pattie","Pecker-snot repository","Pee bug","Peeper","Pelt","Penis holster","Penis penitentiary","Penis piranha","Penis pocket","PenisStation","Peter pleaser","Peter's punching bag","Phat rabbit","Pink brownie cake","Pink canoe","Pink lipped custard sucker","Pink lips","Pink palace","Pink panda","Pink petaled posie","Pink pie","Pink pit of pleasure","Pink stink","Pink taco","Pinkly stinkly","Pish","Piss curtains","Piss flaps","Plewie","Po-po","Pocketbook","Poke hole","Pookie","Poon","Poonani","Poontang","Poontang pie","Poosazi","Pooter","Pootie poo","Pootietang","Pootnanny","Pooty poo","Pork danglies","Postage stamp (you lick it, you stick it, you send it on its way)","Pot holder","Prayer muffin","Prick pit","Promised Land","Pu-jar","Puddin pie","Pudi","Pumpkin blossom","Puna","Punani","Puni","Pushin' cushion","Pussy","Putang","Puter","Puty pu","Quiff","Quim","Quinnie","Quivering mound of love pudding","Raw oyster","Receptacle","Red haired lass","Red snapper","Roast beef curtain","Roast beef pita","Rocket pocket","Rod roaster","Rooster fish","Rosebud","Round mound of repound","Rug","Rusty axe wound","Sacapuntas","Sagging bacon cones","Salami sandwich","Salmon scented semen sucker","Sausage wallet","Scrunt","Seafood taco","Sex hole","Shnush","Shooting range","Shrimp boat","Shrimp pie","Shutters of love","Silk igloo","Skunk guts","Slice","Slickety squid","Slime slit","Slimey slot","Slippery sheath","Slit","Slobbering bulldog","Sloppy joe","Sloppy oyster","Slot A","Slug's belly","Smackey","Smelly jelly hole","Smoo","Snack box","Snack pack","Snake charmer","Snapper","Snatch","Snizzle","Snotty lips","Snutch","Soft taco","South mouth","Southern smile","Spam castanet","Sperm bank","Sperm belcher","Sperm harbor","Split knish","Split-faced hair shark","Splittail","Spock-socket","Spunk locker","Spunk pit","Squashed hedgehog","Squirt bucket","Squishy","Stanky","Stench trench","Sticky bun","Stink hole","Stinkinoonie","Stinky krinky","Stinky pink","Stuffed stocking","Sugar walls","Sweaty burrito","Sweet spot","Sword swallower","Taffy puller","Tang","Tasty little morsel","Tinkleflower","Treasure chest","Tri-fold floppy","Trout basket","Tulip","Tuna 'n' whiskers","Tuna melt","Tuna taco","Tuna town","Tuna tunnel","Tunnel","Tunnel of love","Turkey beard","Turkey curtains","Tutu","Twat","Twat waffle","Twisted taco","Two fingered fish mitten","Two-lips","Underwear oyster","Upside down taco","Vadge","Vagittyfidgit","Vagooter","Vaheena","Veeg","Velvet box","Velvet glove","Venus fly trap","Venus jive trap","Vertical bacon slice","Vertical grimace","Vertical smile","Vertical taco","Vice of love","Warm slurpee","Wazza","Weenie wringer","Welly-boot top","Welly-top","Wet wrinkle","Whisker biscuit","Whooha","Wide open spaces","Wide papaya smile","Willy washer","Winkin' pink brownie cake","Wizard's sleeve","Wookie","Wookie hole","Woolen bivalve","Worm hole","Wound that never heals","Wrinkle","Wuzza","X-Box","Ya-ya","Yeast cake","Yo-yo smuggler","Yoni","Yum yum","Zone"].sort_by{rand}.first
	dirty = ["abject", "bedraggled", "befouled", "begrimed", "besmeared", "contemptible", "daggletailed", "defiled", "despicable", "dishonorable", "disreputable", "excrementitious", "feculent", "filthy", "foul", "grimy", "groveling", "insanitary", "loathsome", "nasty", "ordurous", "putrid", "saprogenic", "sleazy", "soiled", "sordid", "squalid", "stercoraceous", "sullied", "unclean", "uncleanly", "unsportsmanlike", "vile"].sort_by{rand}.first
	whore = ["bawd", "courtesan", "cyprian", "demirep", "drab", "harlot", "hooker", "hussy", "pro", "prostitute", "punk", "slut", "streetwalker", "strumpet", "tramp", "wench", "woman of ill fame"].sort_by{rand}.first
	sendChannel "Fuck my #{vagoo.downcase} #{nick.downcase} you #{dirty} #{whore}."
    end

    def stoned
	mysql = Mysql.init()
	mysql.connect('kodiak','db','db')
	mysql.select_db('viper7')
    	result = mysql.query("SELECT Line FROM `stonerjokes` ORDER BY RAND() LIMIT 1")
    	row = result.fetch_row
    	return row[0]
    	mysql.close
    end

    def drunk
	mysql = Mysql.init()
	mysql.connect('kodiak','db','db')
	mysql.select_db('viper7')
    	result = mysql.query("SELECT Line FROM `drunkjokes` ORDER BY RAND() LIMIT 1")
    	row = result.fetch_row
    	return row[0]
    	mysql.close
    end

    def channelText(nick, host, msg)
    	super(nick,host,msg)
    	case msg
		when /^ROW ROW$/
			sendChannel "FIGHT THE POWAH!"
		when /fuck (?:you|u|me)/i
			fuckYou nick
		when /^you (?:know|might) (?:you[^\s]{0,3} ){0,1}(?:are|be ){0,1}(?:stoned|high|baked) (?:when|if) (.+)/i
			line = $1.chomp
			line.gsub(/\"/,'\"')
			if line.length > 1
				mysql = Mysql.init()
				mysql.connect('kodiak','db','db')
				mysql.select_db('viper7')
				result = mysql.query("SELECT COUNT(*) FROM stonerjokes WHERE Line LIKE \"#{line}\"")
				count = result.fetch_row
				p count[0]
				if count[0] == "0"
					mysql.query("INSERT INTO stonerjokes SET Line=\"#{line}\"")
					sendChannel 'Added joke'
				end
			end
		when /^you (?:know|might) (?:you[^\s]{0,3} ){0,1}(?:are|be ){0,1}(?:drunk|smashed|hammered) (?:when|if) (.+)/i
			line = $1.chomp
			line.gsub(/\"/,'\"')
			if line.length > 1
				mysql = Mysql.init()
				mysql.connect('kodiak','db','db')
				mysql.select_db('viper7')
				result = mysql.query("SELECT COUNT(*) FROM drunkjokes WHERE Line LIKE \"#{line}\"")
				count = result.fetch_row
				p count[0]
				if count[0] == "0"
					mysql.query("INSERT INTO drunkjokes SET Line=\"#{line}\"")
					sendChannel 'Added joke'
				end
			end
		when /stoned|high|baked/
			sendChannel "You know you're stoned when " + stoned
		when /drunk|smashed|hammered/
			sendChannel "You know you're drunk when " + drunk
	end
    end
end


tinderClient, tinderBot = addServer("irc.gamesurge.net","6667","Tinder")
tinderChannels = addChannels(["codeworkshop","v7test","ausquake","premiumgamer"],tinderBot,'TinderChannelBase')
tinderChannels = tinderChannels.concat(addChannels(["nesreca"],tinderBot,'TinderChannel'))
addDirectoryWatcher('/mnt/thorc/Documents and Settings/Viper-7/My Documents/My Dropbox/nesreca', 'Dropbox', 'nesreca', 'http://www.viper-7.com/nesreca/', tinderChannels)
addDirectoryWatcher('/mnt/thorc/Documents and Settings/Viper-7/My Documents/My Dropbox/nesreca/Spaz', 'Dropbox', 'nesreca', 'http://www.viper-7.com/nesreca/spaz/', tinderChannels)
addDirectoryWatcher('/mnt/thorc/Documents and Settings/Viper-7/My Documents/My Dropbox/nesreca/msn drawings', 'Dropbox', 'nesreca', 'http://www.viper-7.com/nesreca/msn%20drawings/', tinderChannels)
addRSSWatcher("http://www.tvnzb.com/tvnzb_new.rss", 'nesreca', tinderChannels, 'nzb', true)
addRSSWatcher("http://www.nzbsrus.com/rssfeed.php", 'nesreca', tinderChannels, 'nzb', false)
addAdminHost('Viper-7!druss@viper-7.com', tinderChannels)
connect tinderClient, tinderBot, tinderChannels
