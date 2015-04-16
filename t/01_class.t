use v6;
use Test;

# use Data::Dump qw( dump );

BEGIN { @*INC.push('lib') };

use ResourceRecordDataA;

# my $rr  = ResourceRecord.new;
my $rra = ResourceRecordDataA.new(ipAdress => '10.0.0.1');

say $rra.ipAdress;
# dump( $rra );
