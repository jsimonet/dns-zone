use v6;
use Test;

BEGIN { @*INC.push('lib') };

# Test file for zone grammar parsing.

use Grammars::DNSZone;
use Grammars::DNSZoneAction;
use ResourceRecordDataA;

# General format of "resource record" :
# DOMAIN_NAME CLASS TTL TYPE DATA ; COMMENTS
# DOMAIN_NAME, CLASS, & TTL are optionals
# If they are not specified, it means that their value is the previous one

# These tests have to be ok
my @toTestAreOk = (
	'bla IN A 10.10.0.42',
	'IN AAAA  2000:1000:1000:1000:2000:1000:1000:1000',
);


my $actions = DNSZoneAction.new;

say '----------------------------';
say 'Following test must succeed.';
my $zones;
# for (@toTestAreOk) {
# 	$zones = DNSZone.parse($_, :actions($actions)).ast.flat;
# }

# $zones = DNSZone.parse(@toTestAreOk[0], :actions($actions));
# say "my zones = "~$zones.ast.gist;

my $test = 'bla IN A 10.0.0.42
bouh IN MX 10 bla
c IN CNAME bla';
$zones = DNSZone.parse($test, :actions($actions));
say "my zones = "~$zones.ast.gist;
# Tests for specific rules
# ok DNSZone.parse(";bla 42;2", rule => "comment" ),";bla 42;2";
# ok DNSZone.parse( "domainname ", rule=>'rr_domain_name' );
# ok DNSZone.parse( "domainname.tld ", rule=>'rr_domain_name' );
# ok DNSZone.parse( "domainname.tld. ", rule=>'rr_domain_name' );
# ok DNSZone.parse( "@ ", rule=>'rr_domain_name' );
# nok DNSZone.parse( 'domain@ ', rule => 'rr_domain_name' );

# ok DNSZone.parse( '10.0.0.0',    rule => 'ipv4' );
# ok DNSZone.parse( '30.0.0.100',  rule => 'ipv4' );
# nok DNSZone.parse( '10.0',       rule => 'ipv4' );
# nok DNSZone.parse( '10.',        rule => 'ipv4' );
# nok DNSZone.parse( '10.0.0.257', rule => 'ipv4' );
# ok DNSZone.parse( 'aaaa:1234:4567:7898:aaaa:1234:4567:7898', rule => 'ipv6' );
# ok DNSZone.parse( 'aaaa:1234:4567:7898:aaaa::4567:7898',     rule => 'ipv6' );
# nok DNSZone.parse( 'aaaa:1234:4567::aaaa::1234:4567:7898',   rule => 'ipv6' );

# my $any = "\n  	";
# ok DNSZone.parse( $any, rule => 'anySpace' );


# Real test
# my $fh = '/home/kernel/Documents/dnsmanager6/db.simonator.info.internal'.IO.open;
# my $fh = '/home/kernel/Documents/dnsmanager6/db.empty'.IO.open;
# my $fh = '/home/kernel/Documents/dnsmanager6/db.simple'.IO.open;
# my $data = $fh.slurp-rest;
# say $data;
# ok DNSZone.parse( $data );
# kfh.close;

