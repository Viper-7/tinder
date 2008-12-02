<?php
	function get_field($instr, $sep, $index=0) {
		for($i=0;$i<$index;$i++)
			$tok = strpos($instr,$sep,$tok)+1;
		$val = substr($instr,$tok,strpos($instr,$sep,$tok)-$tok);
		return $val;
	}

	$instr="1,hello,world,my,name,is";
	$time=mktime() + microtime();

	for($x=0;$x<100000;$x++) {
		$tok = strpos($instr,',',$tok)+1;
		$val = substr($instr,$tok,strpos($instr,',',$tok)-$tok);
	}

	echo 'PHP token ' . ((mktime() + microtime()) - $time) . '<BR>';
	$time=(mktime() + microtime());

	for($x=0;$x<100000;$x++) {
		$val = get_field($instr,',',1);
	}

	echo 'PHP token function ' . ((mktime() + microtime()) - $time) . '<BR>';
	$time=(mktime() + microtime());

	for($x=0;$x<100000;$x++) {
		$val = split(',',$instr);
		$val = $val[1];
	}
	echo 'PHP split ' . ((mktime() + microtime()) - $time) . '<BR>';
	$time=(mktime() + microtime());

	for($x=0;$x<100000;$x++) {
		$val = preg_match('/^.+?,(.+?),/',$instr);
		$val = $val[1];
	}
	echo 'PHP regex ' . ((mktime() + microtime()) - $time) . '<BR>';
?>
