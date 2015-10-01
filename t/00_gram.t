use v6;

use lib 'lib';

use Grammars::DNSZone;
use Grammars::DNSZoneAction;
use Test;


sub MAIN(Str :$testFile!)
{
	my $data = $testFile.IO.slurp;
	if $data
	{
		my $actions = DNSZoneAction.new;
		my $parsed = DNSZone.parse( $data, :$actions );
		if $parsed
		{
			say "File $testFile parsed, dumping it:";
			say $parsed.made;
		}
		else
		{
			say "File $testFile not parsed."
		}
	}

	return 0;
}
