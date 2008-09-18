<?php
	if ($argv[1] . $argv[2] == "") {
		die("Usage: @googlefight word1 word2\n");
	}
	
	$words=explode(' ',$words);
	$word1=$argv[1];
	$word2=$argv[2];
	
	$body = file_get_contents("http://googlefight.com/query.php?lang=en_GB&word1=" . $word1 . "&word2=" . $word2);
	//echo $body;
	$body=explode('<span>',$body);
	$body2=$body[1];
	$body2=explode('</span>',$body2);
	$result1=$body2[0];
	$body=$body[2];
	$body=explode('</span>',$body);
	$result2=$body[0];
	
	$result1=str_replace(' results','',$result1);
	$result2=str_replace(' results','',$result2);
	
	$response = $result1 . " vs " . $result2;
	$response .= "\n";
	if (str_replace(',','',$result1) > str_replace(',','',$result2)) {
		$response .= $word1 . " Wins!\n";
	} else {
		$response .= $word2 . " Wins!\n";
	}
	echo $response;
?>