use v6;

use DNS::Zone::ResourceRecordData::ResourceRecordData;

class AAAA is ResourceRecordData
{
	has Str $.ip6Adress is rw;

	method gist()
	{ return $.ip6Adress; }

	method Str()
	{ return $.ip6Adress; }

	method gen()
	{ return $.ip6Adress; }
}