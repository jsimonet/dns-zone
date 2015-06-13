use v6;

use ResourceRecord;

class Zone
{

	has ResourceRecord @.rr is rw;

	method gist()
	{
		my $res = "(Zone=";
		for @.rr
		{ $res ~= .gist~"; "; }
		$res ~= ")";

		return $res;
	}

	method Str()
	{
		return .Str for @.rr;
	}

}
