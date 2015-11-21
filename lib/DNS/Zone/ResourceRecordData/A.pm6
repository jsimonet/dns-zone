use v6;

use DNS::Zone::ResourceRecordData::ResourceRecordData;

class A is ResourceRecordData
{
	has Str $.ipAdress is rw;

	has $.changed = False;

	method ipAdress { self!proxy($!ipAdress) }

	method !proxy(\attr) {
		Proxy.new(
			FETCH => { attr },
			STORE => -> $, $value { $!changed = True; attr = $value }
		);
	}

	method gist()
	{ return $.ipAdress; }

	method Str()
	{ return $.ipAdress; }

	method gen()
	{ return $.ipAdress; }
}
