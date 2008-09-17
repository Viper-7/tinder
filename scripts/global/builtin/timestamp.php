<?php

	//print_r($argv);
	//die();

	if (!empty($argv[1]) && ereg("^[0-9]{1,12}$", $argv[1]) && $argv[1] < 2145877200) {

		echo date("d-m-Y H:i:s", $argv[1])."\n";

	} elseif (ereg("^([0-3]{1}[0-9]{1})-([0-1]{1}[0-9]{1})-([0-9]{3,4})$", $argv[1], $date)) {
		
		ereg("^([0-2]{1}[0-9]{1}):([0-5]{1}[0-9]{1}):([0-5]{1}[0-9]{1})$", $argv[2], $time);
	
		$ret = 36000;
		
		if (is_array($date) && count($date) > 0) {
		
			$ret += mktime(0, 0, 0, $date[2], $date[1], $date[3]);
		
		}
		
		if (is_array($time) && count($time) > 0) {
		
			$ret += mktime($time[1], $time[2], $time[3], 1, 1, 1970);
		
		}
		
		echo $ret."\n";
		
	} elseif (ereg("^([0-2]{1}[0-9]{1}):([0-5]{1}[0-9]{1}):([0-5]{1}[0-9]{1})$", $argv[1], $time)) {
		
		$ret = 36000;
	
		if (is_array($time) && count($time) > 0) {
		
			$ret += mktime($time[1], $time[2], $time[3], 1, 1, 1970);
		
		}
		
		echo $ret."\n";

	} elseif (empty($argv[1])) {
		
		echo "[@timestamp usage] enter a date/time (dd-mm-yyyy) and/or (hh:mm:ss) or a timestamp\n";
	
	} elseif (strtolower($argv[1]) == 'now') {

		echo "(now) ".date("d-m-Y H:i:s")." - ".mktime()."\n";

	} else {

		echo "not a timestamp or date shitfase\n";

	}

?>
