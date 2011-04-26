<?

error_reporting(E_ALL);
ini_set('error_reporting', E_ALL);
ini_set('display_errors', true);
//ini_set('auto_detect_line_endings', true);

ob_implicit_flush(true);

set_time_limit(1);

$host = "192.168.0.4";
$port = 5334;
$timeout = 250000;

$fp = fsockopen($host, $port, $errno, $errstr, 1);

stream_set_timeout($fp,0, $timeout); // 500ms

if (!$fp)
{
    echo "$errstr ($errno)<br />\n";
}
else
{
    $out = "X";
    fwrite($fp, $out);

    $contents = "";
    echo "Retreving dyno run from Teensy on $host on port $port ...<br>\n";

	$contents = stream_get_contents($fp);
	fclose($fp);

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

	$fp = fsockopen($host, $port, $errno, $errstr, 1);

	stream_set_timeout($fp,0, $timeout); // 500ms

    $out = "v";
    fwrite($fp, $out);

    $contents = "";
    echo "Retreving 2nd dyno run from Teensy on $host on port $port ...<br>\n";

	$contents = stream_get_contents($fp);
	fclose($fp);

	$pattern = '/([^.\s0-9A-Z])/';
	$replacement = '';

	$contents = preg_replace( $pattern, $replacement, $contents );

	$pattern = '/(EOL)/';
	$replacement = "\n";

	$contents = preg_replace( $pattern, $replacement, $contents );

	echo $contents;

	$filewrite = fopen('stuff2.dat', 'w');
	fwrite($filewrite, $contents);
	fclose($filewrite);

	$fp = fsockopen($host, $port, $errno, $errstr, 1);

	stream_set_timeout($fp,0, $timeout); // 500ms

    $out = "c";
    fwrite($fp, $out);

    $contents = "";
    echo "Retreving 3rd dyno run from Teensy on $host on port $port ...<br>\n";

	$contents = stream_get_contents($fp);
	fclose($fp);

	$pattern = '/([^.\s0-9A-Z])/';
	$replacement = '';

	$contents = preg_replace( $pattern, $replacement, $contents );

	$pattern = '/(EOL)/';
	$replacement = "\n";

	$contents = preg_replace( $pattern, $replacement, $contents );

	echo $contents;

	$filewrite = fopen('stuff3.dat', 'w');
	fwrite($filewrite, $contents);
	fclose($filewrite);

}

echo "<br>Fetch complete, now feeding to gnuPlot<br>\n";

$cmd = './dyno.pg > /home/poseidon/www/graph.png';

//echo system($cmd); // or die('failed to system()<br>');

//echo exec($cmd, $results); // or die("failed to exec()<br>");

//echo shell_exec($cmd); // or die("failed to shell_exec()<br>");

echo exec($cmd); // or die("Failed to execute gnuplot script<br>");

echo "<br>Displaying dyno graph 1920x1200:<br>\n";

echo '<img src="graph.png">';

?>