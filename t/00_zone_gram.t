use v6;
use Test;

use lib 'lib';

# Test file for zone grammar parsing.

use Grammars::DNSZone;

# General format of "resource record" :
# DOMAIN_NAME CLASS TTL TYPE DATA ; COMMENTS
# DOMAIN_NAME, CLASS, & TTL are optionals
# If they are not specified, it means that their value is the previous one

# These tests have to be ok
my @toTestAreOk = (
	'bla IN A 10.10.0.42',
	"bla IN A 10.10.0.42\n",
	"bla A 10.10.0.42",
	'IN AAAA  2000:1000:1000:1000:2000:1000:1000:1000',
	'testttl IN 42s A 10.0.0.42',
	'testttl	 IN     42m A 10.0.0.42 ; different spaces',
	'testttl MX 10 bla ; \'10 bla\' is part of MX RDATA',
	'testcomment A 10.0.0.42 ; this is a comment',
	'; only a comment',
	"testmultiline(
	IN(
	42s)
	AAAA
) 1000:1000:1000:1000:2000:1000:1000:1000",
	"testmultiline (
	IN (
	)) AAAA ::1",
	'@ IN SOA ns0.simonator.info. kernel.simonator.info. 2015020801 604800 86400 2419200 604800 ; oneline soa',
	'@ IN SOA ns0.simonator.info. kernel.simonator.info. (
	2015020801 ; serial
	604800     ; refresh
	86400      ; retry
	2419200    ; expire
	604800 )   ; negative cache ttl
	; soa is generally writed in multiline, with comments
	; only one soa by zone definition',
	'1.0.0.10.IN-ADDR.ARPA	IN	PTR	pointed',
);

my @toTestAreNok = (
	'bla IN
	A 10.0.0.42 ; must have a parenthese to be multi-line',
	'bla IN IN A 10.0.0.42';
);

say '----------------------------';
say 'Following test must succeed.';
my $dnsparser = DNSZone.new;
for (@toTestAreOk) {
	# ok DNSZone.parse($_) , $_;
	ok $dnsparser.parse($_),$_;
}

say '--------------------------';
say 'Following test must fails.';
for (@toTestAreNok) {
	nok DNSZone.parse($_) , $_;
}

# Tests for specific rules
# ok DNSZone.parse(";bla 42;2", rule => "comment" ),";bla 42;2";
# ok DNSZone.parse( "domainname ", rule=>'domainName' );
# ok DNSZone.parse( "domainname ", rule=>'domainName' );
# ok DNSZone.parse( "domainname.tld ", rule=>'domainName' );
# ok DNSZone.parse( "domainname.tld. ", rule=>'domainName' );
# ok DNSZone.parse( "@ ", rule=>'domainName' );
# nok DNSZone.parse( 'domain@ ', rule => 'domainName' );

# ok DNSZone.parse( '10.0.0.0',    rule => 'ipv4' );
# ok DNSZone.parse( '30.0.0.100',  rule => 'ipv4' );
# nok DNSZone.parse( '10.0',       rule => 'ipv4' );
# nok DNSZone.parse( '10.',        rule => 'ipv4' );
# nok DNSZone.parse( '10.0.0.257', rule => 'ipv4' );
# ok DNSZone.parse( 'aaaa:1234:4567:7898:aaaa:1234:4567:7898', rule => 'ipv6' );
# ok DNSZone.parse( 'aaaa:1234:4567:7898:aaaa::4567:7898',     rule => 'ipv6' );
# nok DNSZone.parse( 'aaaa:1234:4567::aaaa::1234:4567:7898',   rule => 'ipv6' );

# my $any = "\n  	";
# ok DNSZone.parse( $any, rule => 'rrSpace' );


# Real test
# my $fh = '/home/kernel/Documents/dnsmanager6/db.simonator.info.internal'.IO.open;
# my $fh = '/home/kernel/Documents/dnsmanager6/db.empty'.IO.open;
# my $fh = '/home/kernel/Documents/dnsmanager6/db.simple'.IO.open;
# my $data = $fh.slurp-rest;
# say $data;
# ok DNSZone.parse( $data );
# kfh.close;
