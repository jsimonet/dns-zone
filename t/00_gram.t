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
		#my $actions = ModernActions.new;
		#my $parsed = Modern.parse( $data, :$actions );
		#if $parsed
		#{
		#	say "File $testFile parsed, dumping it:";
		#	say $parsed.made;
		#	# Try to add a line
		#	my $rdata = ResourceRecordDataA.new( ipAdress => '10.0.0.2' );
		#	my $rr = ResourceRecord.new(
		#		domainName=> 'second',
		#		type => 'A',
		#		rdata => $rdata);
		#	my $rr2 = ResourceRecord.new(
		#		domainName => 'another',
		#		type => 'A',
		#		rdata => $rdata );
		#	my ResourceRecord @rrs = $rr, $rr2;
		#	#$parsed.ast.addResourceRecord( :$rr );
		#	$parsed.ast.add( rrs => @rrs, position => 2 );
		#	say "After adding new line :";
		#	say $parsed.ast.gen;
		#	say "deleting an element : ";
		#	$parsed.ast.del( position => 5 );
		#	say $parsed.ast.gen;
		#}
		#else
		#{
		#	say "File $testFile not parsed."
		#}

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
