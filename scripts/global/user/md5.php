<?php
	$str = $argv[1];
	if (strlen($str) < 2) {
		echo 'Usage: @md5 <string to encode> - also available in private message';
	} else {
		echo md5($str);
	}
?>