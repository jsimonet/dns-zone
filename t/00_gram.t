use v6;

use lib 'lib';

use DNS::Zone;
#use DNS::Zone::Grammars::Modern;
#use DNS::Zone::Grammars::ModernActions;
#use DNS::Zone::ResourceRecord;
use Test;


sub MAIN(Str :$testFile!)
{
	my $data = $testFile.IO.slurp;
	if $data
	{
		my $zone = DNS::Zone.new;
		$zone.load( :$data );
		my $rdata = DNS::Zone::ResourceRecordData::A.new( ipAdress => '10.0.0.2' );
		my $rr = DNS::Zone::ResourceRecord.new(
				domainName=> 'second',
				rdata => $rdata);
		#say $rr.type;
		$zone.add( :$rr, position => 2 );
		say $zone.gen;
	}

	return 0;
}
