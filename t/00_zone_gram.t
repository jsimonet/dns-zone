use v6;
use Test;

BEGIN { @*INC.push('lib') };

# Test file for zone grammar parsing.

use Grammars::DNSZone;

my @toTestAreOk = (
	# "bla IN A 10.10.0.42\n",
	# "bla IN A(
# 10.10.0.42)",
	# "bla IN A 10.10.0.42",
	# 'IN AAAA  2000:1000:1000:1000:2000:1000:1000:1000',
	q:to/EOEXP/,
IN (
	AAAA) 2000:1000:1000:1000:2000:1000:1000:1000
EOEXP
	# "testttl(
	# IN(
   	# 42s)
	# AAAA
# ) 1000:1000:1000:1000:2000:1000:1000:1000",
	# "testttl IN 42s MX 10 bla",
);

for (@toTestAreOk) {
	ok DNSZone.parse($_) , $_;
}

# ok DNSZone.parse(";bla 42;2", rule => "comment" ),";bla 42;2";
# ok DNSZone.parse( "domainname ", rule=>'rr_domain_name' );
# ok DNSZone.parse( "domainname.tld ", rule=>'rr_domain_name' );
# ok DNSZone.parse( "domainname.tld. ", rule=>'rr_domain_name' );
# ok DNSZone.parse( "@ ", rule=>'rr_domain_name' );
# nok DNSZone.parse( 'domain@ ', rule => 'rr_domain_name' );

# ok DNSZone.parse( '10.0.0.0', rule => 'ipv4' );
# ok DNSZone.parse( '30.0.0.100', rule => 'ipv4' );
# nok DNSZone.parse( '10.0', rule => 'ipv4' );
# nok DNSZone.parse( '10.', rule => 'ipv4' );
# nok DNSZone.parse( '10.0.0.257', rule => 'ipv4' );

# my $any = "\n  	";
# ok DNSZone.parse( $any, rule => 'anySpace' );
my $soa = q:to/SOAEND/;
@       IN      SOA     ns0.simonator.info. kernel.simonator.info.(
                        2015020801      ; Serial
                            604800      ; Refresh
                             86400      ; Retry
                           2419200      ; Expire
                            604800 )    ; Negative Cache TTL
bla IN A 10.0.0.1
SOAEND

my $soa2 = '@ IN SOA ns0.simonator.info. kernel.simonator.info. 2015020801 604800 86400 2419200 604800';

# ok DNSZone.parse( $soa );
# ok DNSZone.parse( $soa2 );
# ok DNSZone.parse( 'aaaa:1234:4567:7898:aaaa:1234:4567:7898', rule => 'ipv6' );
# ok DNSZone.parse( 'aaaa:1234:4567::aaaa::1234:4567:7898', rule => 'ipv6' );

my $empty = ' 
	
';
# ok DNSZone.parse( $empty );

# Mega test
# my $fh = '/home/kernel/Documents/dnsmanager6/db.simonator.info.internal'.IO.open;
# my $fh = '/home/kernel/Documents/dnsmanager6/db.empty'.IO.open;
# my $fh = '/home/kernel/Documents/dnsmanager6/db.simple'.IO.open;
# my $data = $fh.slurp-rest;
# say $data;
# ok DNSZone.parse( $data );
# $fh.close;

