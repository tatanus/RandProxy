use Proxy;

$p = new Proxy();

while (1) {
	$size = length($p->getURL("http://www.google.com"));
	print "SIZE = [$size]\n";
}
