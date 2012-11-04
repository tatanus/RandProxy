#!/usr/bin/perl

use LWP::Simple;
use LWP::UserAgent;
use HTTP::Request::Common;
use HTML::Entities;

package Proxy;
	my @pasties;
	my @seenPasties;
	my @proxies;

	sub new {
		my $class = shift;
		my $self = {};
		if (@proxies == 0) {
			getProxies();
		}

		bless $self, $class;
		return $self;
	}
	
	sub uniq (@) {
	    my %h;
	        map { $h{$_}++ == 0 ? $_ : () } @_;
	}

	sub getProxies {
	        print "- loading proxies\n";

		readGoodProxiesFile();
		if (@proxies <= 5) {
			loadProxiesFromWeb();
		}
		@proxies = uniq(@proxies);

        	print "-- loaded [".@proxies."] proxies\n";

		removeBadProxies();
		writeGoodProxiesFile();

        	print "-- there are [".@proxies."] proxies\n";
	}

	sub loadProxiesFromWeb {
		my $ua = new LWP::UserAgent;

		my $countBefore = $#proxies;

	        print "- loading proxies from the WEB\n";

		### ##########################################################################
		###
		### Load Proxies from [ http://www.malwaregroup.com/Proxies ]
		###
		### ##########################################################################
#		$ua = new LWP::UserAgent;
#		$ua->agent("Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1");
#
#		$count = $#proxies;
#
#        	print "-- Reading proxies from [http://www.malwaregroup.com/Proxies]\n";
#		my $req = new HTTP::Request GET => 'http://www.malwaregroup.com/Proxies';
#		my $res = $ua->request($req);
#		my $proxylist= $res->content;
#
#		if (defined $proxylist){
#			@data = $proxylist;
#			foreach $line (@data){
#				if ($line =~ /\">([\d\.]{7,}.*?)\<\/a\>\<\/td\>\s\<td\>(.*?)\<\/td\>/i){
#					while ($line =~ m/\">([\d\.]{7,}.*?)\<\/a\>\<\/td\>\s\<td\>(.*?)\<\/td\>/ig){
#						push(@proxies, 'http://'.$1.':'.$2);
#					}
#				} else {
#					print "Fail\n";
#				}
#			}
#			@proxies = uniq(@proxies);
#			print "-- Loaded [".($#proxies - $count)."] proxies.\n";
#		} else {
#        		print "-- No proxies read from [http://www.malwaregroup.com/Proxies]\n";
#		}
#
#		### ##########################################################################
#		###
#		### Load Proxies from [ http://www.freeproxylists.com/anonymous.html ]
#		###
#		### ##########################################################################
#		$ua = new LWP::UserAgent;
#		$ua->agent("Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1");
#
#		$count = scalar $#proxies;
#
#		print "-- Reading proxies from [http://www.freeproxylists.com/anonymous.html]\n";
#		my $req = new HTTP::Request GET => 'http://www.freeproxylists.com/anonymous.html';
#		my $res = $ua->request($req);
#		my $proxylist= $res->content;
#
#		if (defined $proxylist){
#			@data = $proxylist;
#			foreach $line (@data){
#				while ($line =~ /anon\/(\d+)\.html/g) {
#					my $req2 = new HTTP::Request GET => 'http://www.freeproxylists.com/load_anon_'.$1.'.html';
#					my $res2 = $ua->request($req2);
#					my $proxylist2 = $res2->content;
#		
#					if (defined $proxylist2){
#						@data2 = $proxylist2;
#						foreach $line2 (@data2){
#							while ($line2 =~ /gt;(\d+\.\d+\.\d+\.\d+)&lt;\/td&gt;&lt;td&gt;(\d+)&lt/g) {
#								push(@proxies, 'http://'.$1.':'.$2);
#							}
#						}
#					}
#				}
#			}
#			@proxies = uniq(@proxies);
#			print "-- Loaded [".($#proxies - $count)."] proxies.\n";
#		} else {
#        		print "-- No proxies read from [http://www.freeproxylists.com/anonymous.html]\n";
#		}

		### ##########################################################################
		###
		### Load Proxies from [ http://www.xroxy.com/proxyrss.xml ]
		###
		### ##########################################################################
		$ua = new LWP::UserAgent;
		$ua->agent("Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1");

		$count = $#proxies;

        	print "-- Reading proxies from [http://www.xroxy.com/proxyrss.xml]\n";
		my $req = new HTTP::Request GET => 'http://www.xroxy.com/proxyrss.xml';
		my $res = $ua->request($req);
		my $proxylist= $res->content;

		if (defined $proxylist){
			@data = $proxylist;
			$tempStr = join('', @data);
			$tempStr =~ s/\n//g;
			while ($tempStr =~ /prx:ip>([^<]+)<\/prx:ip><prx:port>([^<]+)<\/prx:port><prx:type>Anonymous/g){
				push(@proxies, 'http://'.$1.':'.$2);
			}
			@proxies = uniq(@proxies);
			print "-- Loaded [".($#proxies - $count)."] proxies.\n";
		} else {
        		print "-- No proxies read from [http://www.xroxy.com/proxyrss.xml]\n";
		}

		### ##########################################################################

		@proxies = uniq(@proxies);
        	print "-- loaded [".($#proxies-$countBefore)."] proxies from the WEB\n";

        	return(1);
	}
	
	sub readGoodProxiesFile {
        	open (FILE, "GoodProxies.txt");
		while (<FILE>) {
			chomp;
			push(@proxies, $_);
		}
		close FILE;
	}

	sub writeGoodProxiesFile {
        	open (FILE, ">GoodProxies.txt");
		foreach $proxy (@proxies) {
			print FILE $proxy."\n";
		}
		close FILE;
	}

	sub removeBadProxies {
        	print "-- removing bad proxies\n";
		open (FILE, "BadProxies.txt");
		while (<FILE>) {
			chomp;
			$tempProxy = $_;
        		print "--- removing proxy [".$tempProxy."]\n";
        		@proxies = grep {$_ ne $tempProxy} @proxies;
		}
		close FILE;
	}

	sub removeProxy {
	        my $tempProxy = shift;

        	print "-- removing proxy [".$tempProxy."]\n";

        	@proxies = grep {$_ ne $tempProxy} @proxies;

        	open (FILE, ">>BadProxies.txt");
		print FILE $tempProxy."\n";
		close FILE;

        	print "--- Removed! [".@proxies."] remaining\n";

		if (@proxies <= 5) {
			#	getProxies();
		}
	}

	sub selectRandomProxy {
        	my $randomIdx = rand($#proxies);

        	print "-- using proxy [". $proxies[$randomIdx] ."]\n";

        	return $proxies[$randomIdx];
	}
	
	sub getURL {
		my $self = shift;
		my $url = shift;
		
		my $ua = LWP::UserAgent->new;
        	print "- getting URL [".$url."]\n";
        	$ua->timeout(10);

        	if (@proxies) {
        	        $tempProxy = selectRandomProxy();
        	        $ua->proxy('http', $tempProxy);
        	} else {
        	        $ua->env_proxy;
        	}
		
        	$ua->agent("Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1");
        	my $response = $ua->get($url);

		if ($response->status_line !~ /200/) { 
	       	        removeProxy($tempProxy);
			getURL($self,$url);
			return;
        	}
		print "$tempProxy -- STATUSLINE = [".$response->status_line."]";
		
		if ($response->is_success) {
			return $response->decoded_content;
		}
		
        	return 0;
	}

	sub getURL2File {
		my $self = shift;
		my $url = shift;
		my $file = shift;

		return(0) unless defined($file);

        	print "- getting URL [".$url."]\n";

		my $ua = new LWP::UserAgent;
        	$ua->agent("Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1");
        	$ua->timeout(10);

        	if (@proxies) {
        	        $tempProxy = selectRandomProxy();
        	        $ua->proxy('http', $tempProxy);
        	} else {
        	        $ua->env_proxy;
        	}
		
        	my $response = $ua->get($url);
        	if ($response->status_line !~ /200/) {
        	        removeProxy($tempProxy);
			getURL2File($self,$url,$file);
			return;
        	}

		#my $data_content = $response->content;
		my $data_content = $response->decoded_content;

		if ($response->is_success) {
			if (defined $data_content){
				open(OUTFILE_FD, ">$file") || die "-- Cannot open file [$file] : $!";
				@data = $data_content;
				foreach $line (@data){
					print OUTFILE_FD $line;
				}
				close(OUTFILE_FD);
			}
			return;
		} else {
			print "-- Could not obtain the web site [$url] : $!";
			print $response;
		}
		
        	return 0;
	}	
																	
1;
