use Proxy;

$p = new Proxy();

while(<STDIN>) {
	chomp;
	$url = $_;
	$filename = $url;
	$filename =~ s/\//_/g;
	$filename =~ s/:/_/g;
	$filename =~ s/\?/_/g;
	$filename =~ s/&/_/g;
	$filename = "files/$filename";

	# use wget to grab the file
	unless (-e $filename) {
		print "$filename\n";
		$p->getURL2File($url, $filename, 0);
	}
}
exit;

