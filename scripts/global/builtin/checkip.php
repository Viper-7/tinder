<?php
for ($x=0;$x<6;$x++) {                                  
$html = file_get_contents("http://www.whatismyip.com.au");                                  
$ip = explode('<td>', $html);
$ip = $ip[1];                                  
$ip = explode(' resolved to', $ip);                                 
$ip = $ip[0];                                  
echo $ip . " ";                                   
}                                    
echo "\n";
?>
