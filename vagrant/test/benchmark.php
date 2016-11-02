<?php
/*
##########################################################################
#                      PHP Benchmark Performance Script                  #
#                         � 2010 Code24 BV                               #
#                                                                        #
#  Author      : Alessandro Torrisi                                      #
#  Company     : Code24 BV, The Netherlands                              #
#  Date        : July 31, 2010                                           #
#  version     : 1.0                                                     #
#  License     : Creative Commons CC-BY license                          #
#  Website     : http://www.php-benchmark-script.com                     #
#                                                                        #
##########################################################################
*/

function test_Math($count = 140000) {
	$time_start = microtime(true);
	$mathFunctions = array("abs", "acos", "asin", "atan", "bindec", "floor", "exp", "sin", "tan", "pi", "is_finite", "is_nan", "sqrt");
	foreach ($mathFunctions as $key => $function) {
		if (!function_exists($function)) unset($mathFunctions[$key]);
	}
	for ($i=0; $i < $count; $i++) {
		foreach ($mathFunctions as $function) {
			$r = call_user_func_array($function, array($i));
		}
	}
	return number_format(microtime(true) - $time_start, 3);
}


function test_StringManipulation($count = 130000) {
	$time_start = microtime(true);
	$stringFunctions = array("addslashes", "chunk_split", "metaphone", "strip_tags", "md5", "sha1", "strtoupper", "strtolower", "strrev", "strlen", "soundex", "ord");
	foreach ($stringFunctions as $key => $function) {
		if (!function_exists($function)) unset($stringFunctions[$key]);
	}
	$string = "the quick brown fox jumps over the lazy dog";
	for ($i=0; $i < $count; $i++) {
		foreach ($stringFunctions as $function) {
			$r = call_user_func_array($function, array($string));
		}
	}
	return number_format(microtime(true) - $time_start, 3);
}


function test_Loops($count = 19000000) {
	$time_start = microtime(true);
	for($i = 0; $i < $count; ++$i);
	$i = 0; while($i < $count) ++$i;
	return number_format(microtime(true) - $time_start, 3);
}


function test_IfElse($count = 9000000) {
	$time_start = microtime(true);
	for ($i=0; $i < $count; $i++) {
		if ($i == -1) {
		} elseif ($i == -2) {
		} else if ($i == -3) {
		}
	}
	return number_format(microtime(true) - $time_start, 3);
}


$total = 0;
$functions = get_defined_functions();
$line = str_pad("-",38,"-");
exec('lsb_release -as', $lsb);
echo "<!DOCTYPE html>
<html>
  <head>
    <meta charset=\"utf-8\">
    <title>Bench: ";
echo gethostname();
echo "</title>
  </head>
  <body>
";
echo "<pre>\n$line\n|".str_pad("PHP BENCHMARK SCRIPT",36," ",STR_PAD_BOTH)."|\n$line\n";
echo "Start    : ".date("Y-m-d H:i:s")."\n";
echo "URL      : {$_SERVER['SERVER_NAME']}\n";
echo "IP       : {$_SERVER['SERVER_ADDR']}\n";
echo "Platform : ".PHP_OS. "\n";
echo "Release  : {$lsb[1]}\n";
echo "PHP vers : ".PHP_VERSION."\n";
echo "$line\n";
foreach ($functions['user'] as $user) {
	if (preg_match('/^test_/', $user)) {
		$total += $result = $user();
          echo str_pad($user, 25) . " : " . $result ." sec.\n";
      }
}
echo str_pad("-", 38, "-") . "\n" . str_pad("Total time:", 25) . " : " . $total ." sec.\n</pre>\n";
echo "  </body>
</html>";
