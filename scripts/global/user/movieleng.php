<?php
mysql_connect('cerberus','db','db');
mysql_select_db('viper7');

list($total)=mysql_fetch_array(mysql_query("SELECT SUM(duration) FROM imdbfiles"));

$days = floor($total / 86400);
$total = $total % 86400;
$hours = floor($total / 3600);
$total = $total % 3600;
$minutes = floor($total / 60);
$seconds = round($total % 60,1);

echo "$days Days, $hours Hours, $minutes Minutes, $seconds Seconds";
?>