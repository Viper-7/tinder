<?php
	if ($argv[1] == "") {
		echo "Usage: @sharefile http://www.viper-7.com/myfile.zip -::- Hosts files on Rapidshare and 4 other servers"
	} else {
		$url=$argv[1];
		echo "Downloading " . $url . ". This may take a few minutes : ";
		$result=file_get_contents("http://tinyload.com/api/1.0/transload.txt?url=" . $url . "&sites=1,2,3,4,5");
		echo $result;
		echo "Done Uploading!";
	}
?>