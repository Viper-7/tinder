<?php
	if ( !function_exists('sys_get_temp_dir') )
	{
	    // Based on http://www.phpit.net/
	    // article/creating-zip-tar-archives-dynamically-php/2/
	    function sys_get_temp_dir()
	    {
	        // Try to get from environment variable
	        if ( !empty($_ENV['IIBOT_TEMP_DIR']) )
	        {
	            return realpath( $_ENV['IIBOT_TEMP_DIR'] );
	        }
	        else if ( !empty($_ENV['IIBOT_DIR']) )
	        {
	            return realpath( $_ENV['IIBOT_DIR'] . '/tmp/' );
	        }
	        else if ( !empty($_ENV['TEMP']) )
	        {
	            return realpath( $_ENV['TEMP'] );
	        }
	
	        // Detect by creating a temporary file
	        else
	        {
	            // Try to use system's temporary directory
	            // as random name shouldn't exist
	            $temp_file = tempnam( md5(uniqid(rand(), TRUE)), '' );
	            if ( $temp_file )
	            {
	                $temp_dir = realpath( dirname($temp_file) );
	                unlink( $temp_file );
	                return $temp_dir;
	            }
	            else
	            {
	                return FALSE;
	            }
	        }
	    }
	}

	class fourChan {
		
		private $board = "b";
		private $seek_type = "random";
		private $board_details = array();
		private $boards_help = false;
		private $board_cache_file;
		
		public function __construct($args=array()) {
			
			$this->_parse_args($args);
			$this->_cache_board_details();
			
		}
		
		private function _parse_args($args) {
			
			if (count($args)) {
			
				foreach ($args as $index => $arglol) {
			
					$this->board = (strlen($arglol) > 0 && strlen($arglol) <= 3) ? $arglol : $this->board;
					$this->seek_type = (strlen($arglol) == 6) ? $arglol : $this->seek_type;
					$this->boards_help = ($index == 1 && ($arglol == "boards" || $arglol == "help")) ? true : $this->boards_help;
					
				}
			
			}
			
		}
		
		private function _cache_board_details() {
			
			$this->board_cache_file = sys_get_temp_dir() . "/4chan_cache";
			$file = fopen($this->board_cache_file, "r") or die("Could not find " . $this->board_cache_file . "\n");
			$timestamp = 0;
			
			while (($data = fgetcsv($file, 1000, ",")) !== false) {
				
				if ($data[0] == "timestamp") {
					
					$timestamp = $data[1];
					continue;
					
				}
				
				$row++;
				
				$this->board_details[$data[0]] = $data[1];
				
			}
			
			fclose($file);
			
			//echo $timestamp."\n";
			//die();
			
			if (($timestamp + (60*60*24*7)) < mktime()) {
			
				$rawpage = file_get_contents("http://img.4chan.org/b/imgboard.html") or die("http request failed\n");
				
				$arr = explode('<span id="navtop">', $rawpage);
				$arr = explode('</span><span id="navtopr">', $arr[1]);
				
				$linkStr = $arr[0];
				
				$matches = array();
				
				preg_match_all("^http://[a-z]{3}\.4chan\.org/([a-z0-9]{1,3})/imgboard\.html^", $linkStr, $matches, PREG_SET_ORDER);
				
				foreach ($matches as $match) {
					
					$this->board_details[$match[1]] = $match[0];
					
				}
				
				$file = fopen($this->board_cache_file, "w") or die("lol\n");;
				
				fwrite($file, "\"timestamp\",\"".mktime()."\"\n");
				
				foreach ($this->board_details as $index => $value) {
					
					fwrite($file, "\"".$index."\",\"".$value."\"\n");
					
				}
			
				fclose($file);
				
			}
			
		}
		
		public function board_check() {
			
			if ($this->boards_help) {
				
				$boards = array_flip($this->board_details);
				echo "usage: @4chan [ random / newest ] [ ".implode(" / ", $boards)." ] \n";
				die("example: @4chan random b\n");
				
			}
			
			if (empty($this->board_details[$this->board])) {
				
				die("board does not exist\n");
				
			}
			
		}
		
		public function board($board="") {
			
			if (!empty($board)) {
				
				$this->board = $board;
				
			}
			
			$this->board = ($this->board) ? $this->board : "b";
			
			return $this->board;
			
		}
		
		public function seek_type($seek_type="") {
			
			if (!empty($seek_type)) {
				
				$this->seek_type = $seek_type;
				
			}
			
			$this->seek_type = ($this->seek_type) ? $this->seek_type : "random";
			
			return $this->seek_type;
			
		}
		
		public function board_dump() {
			
			print_r($this->board_details);
			die();
			
		}
		
		public function get_image() {
			
			$page = file_get_contents($this->board_details[$this->board]) or die("http request failed\n");
			
			$matches = array();
			
			preg_match_all("^<a href=\".*\" target=\"_blank\">.*</a>-.*</span><br><a href=\"(.*)\" target=_blank><img src=.* border=0 align=left^", $page, $matches, PREG_SET_ORDER);
			
			if (count($matches) > 0) {
				
				switch ($this->seek_type) {
					
					case "random":
					default:
						srand(mktime());
						$index = (rand()%(count($matches) - 1));
						break;
						
					case "newest":
						$index = 0;
						break;
					
				}
				
			} else {
				
				return "could not find an image, something is wrong :/\n";
				
			}
			
			return $matches[$index][1]."\n";
			
		}
		
	}
	
	$lol = new fourChan($argv);
	$lol->board_check();
	
	echo $lol->get_image();

?>