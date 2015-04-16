use v6;

use ResourceRecord;

class Zone
{

	has ResourceRecord @.rr is rw;

	method gist()
	{
		print "(Zone=";
		.print for @.rr;
		print ")";
	}

}
