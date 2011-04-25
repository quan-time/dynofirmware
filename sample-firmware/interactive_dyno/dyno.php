<?

error_reporting(E_ALL);

ob_implicit_flush(true);

set_time_limit(5);

$host = "192.168.0.4";
$port = 5334;
//$port = 6655;

/*if (($sock = socket_create(AF_INET, SOCK_STREAM, SOL_TCP)) === false) {
    echo "socket_create() failed: reason: " . socket_strerror(socket_last_error()) . "\n";
}

socket_set_block($sock) or die("cant set block");

socket_set_option( $sock, SOL_SOCKET, SO_SNDTIMEO, array("sec"=>10, "usec"=>0) )
	or die("Unable to set timeout\n");

socket_connect($sock, $host, $port)
	or die("Unable to connect to $host on $port socket\n");

$message="z";
$len = strlen($message);
$offset = 0;
while ($offset < $len) {
    $sent = socket_write($sock, substr($message, $offset), $len-$offset);
    if ($sent === false) {
        // Error occurred, break the while loop
        break;
    }
    $offset += $sent;
}
if ($offset < $len) {
    $errorcode = socket_last_error();
    $errormsg = socket_strerror($errorcode);
    echo "SENDING ERROR: $errormsg";
} else {
        // Data sent ok
}

if($sent === false) {
	return false;
}

while($buffer=@socket_read($sock,512,PHP_NORMAL_READ)){
    echo $buffer;
}
if(socket_last_error($sock) == 104) {
    echo "Connection closed";
}*/

// start/end

$fp = fsockopen($host, $port, $errno, $errstr, 5);

if (!$fp)
{
    echo "$errstr ($errno)<br />\n";
}
else
{
    $out = "z";
    fwrite($fp, $out);

while (!feof($fp))
{
	echo "Retreving dyno run from Teensy on $ip:$host...<br>\n";
	$contents = fgets($fp, 4096);
}

$pattern = '/([^.\s0-9A-Z])/';
$replacement = '';

$contents = preg_replace( $pattern, $replacement, $contents );

$pattern = '/(EOL)/';
$replacement = "\n";

$contents = preg_replace( $pattern, $replacement, $contents );

echo $contents;

$filewrite = fopen('stuff.dat', 'w');
fwrite($filewrite, $contents);
fclose($filewrite);




fclose($fp);

}

echo "<br>Fetch complete, now feeding to gnuPlot<br>\n";

echo exec('./dyno.pg');

echo "<br>Displaying dyno graph 1920x1200:<br>\n";

?>

<img src="graph.png">