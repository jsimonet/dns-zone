use v6;
use Test;

use lib 'lib';

# Test file for zone grammar parsing.

use DNS::Zone::Grammars::Modern;

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

plan @toTestAreOk.elems + @toTestAreNok;
skip-rest 'Will not pass';
exit;

my $dnsparser = DNS::Zone::Grammars::Modern.new;
for (@toTestAreOk) {
	# ok DNS::Zone::Grammars::Modern.parse($_) , $_;
	ok $dnsparser.parse($_),$_;
}

for (@toTestAreNok) {
	nok $dnsparser.parse($_) , $_;
}

done-testing;


# Real test
# my $fh = '/home/kernel/Documents/dnsmanager6/db.simonator.info.internal'.IO.open;
# my $fh = '/home/kernel/Documents/dnsmanager6/db.empty'.IO.open;
# my $fh = '/home/kernel/Documents/dnsmanager6/db.simple'.IO.open;
# my $data = $fh.slurp-rest;
# say $data;
# ok DNS::Zone::Grammars::Modern.parse( $data );
# kfh.close;
