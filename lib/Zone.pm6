use v6;

use ResourceRecord;

class Zone
{

	has ResourceRecord @.rr is rw;

	method gist()
	{
		my $res = "(Zone=\n";
		for @.rr
		{ $res ~= "\t"~.gist~"\n"; }
		$res ~= ")";

		return $res;
	}

	method Str()
	{
		return .Str for @.rr;
	}

}
