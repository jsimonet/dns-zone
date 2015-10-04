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

	method addResourceRecord( ResourceRecord :$rr, Int :$position=-1 )
	{
		if 0 <= $position <= @.rr.elems
		{
			@.rr.splice( $position-1, 0, $rr );
			# @.rr = splice( @.rr, $position-1, 0, $rr ); # Do not work ?
		}
		else
		{
			push @.rr, $rr;
		}
	}

	method gen()
	{
		my $res = join "\n", map { .gen() }, @.rr;

		return $res;
	}
}
