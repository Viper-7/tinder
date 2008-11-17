<?php
	$monthlyusage = Array();
	$log = Array();
	
	exec("curl -k -d username='viper7' -d password='24pqsshth' -d history=1 -d iso=1 https://customer-webtools-api.internode.on.net/cgi-bin/padsl-usage > /tmp/usage.txt 2>/dev/null");
	exec("curl -k -d username='viper7' -d password='24pqsshth' -d iso=1 https://customer-webtools-api.internode.on.net/cgi-bin/padsl-usage > /tmp/meteredusage.txt 2>/dev/null");

	$fp = fopen('/tmp/usage.txt','r');
	if($fp) {
		while(!feof($fp)) {
			$line = @fgets($fp);
			array_push($log, $line);
			$month = substr($line,0,2);
			$monthlyusage[$month] += round(substr($line,strpos($line,' ')+1)/1024,2);
		}
		//array_pop($monthlyusage);
		array_pop($log);
		fclose($fp);

		$count=0;
		$weeklyusage=0;
		while($count < 7) {
			$line = array_pop($log);
			if(strlen($line) > 2) {
				$weeklyusage += substr($line,strpos($line,' ')+1)/1024;
				$count += 1;
			}
		}
		$weeklyusage=round($weeklyusage,2);
	}

	$fp = fopen('/tmp/meteredusage.txt','r');
	if($fp) {
		$line = @fgets($fp);
		$meteredusage = round(substr($line,0,strpos($line,' '))/1024,2);
		fclose($fp);
	}

	if($meteredusage && $weeklyusage)
		echo 'Last 7 days data usage: ' . $weeklyusage . 'gb, Monthly Metered Traffic: ' . $meteredusage . 'gb,  Monthly Total: ' . array_pop($monthlyusage) . 'gb' . "\n";
?>
