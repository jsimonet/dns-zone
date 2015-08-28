use v6;
use Test;

# use Data::Dump qw( dump );

BEGIN { @*INC.push('lib') };

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

say $match;
say $match.made;
