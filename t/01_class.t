use v6;
use Test;

# use Data::Dump qw( dump );

use lib 'lib';

use Grammars::DNSZone;
use Grammars::DNSZoneAction;
# use ResourceRecordDataA;

# my $rr  = ResourceRecord.new;
# my $rra = ResourceRecordDataA.new(ipAdress => '10.0.0.1');

# say $rra.ipAdress;
# dump( $rra );

my $actions = DNSZoneAction.new;
my $fh = '/home/kernel/Documents/dnsmanager6/db.simple'.IO.open;
my $data = $fh.slurp-rest;
my $match = DNSZone.parse($data, :$actions);

# say $match;
my $rr = ResourceRecord.new( domainName => 'new',
	class => 'IN',
	ttl   => 3600,
	type  => 'A',
	rdata => ResourceRecordDataA.new( ipAdress => '10.0.0.1' )
);
$match.made.addResourceRecord(rr => $rr, position => 3);

say $match.made.gen();
