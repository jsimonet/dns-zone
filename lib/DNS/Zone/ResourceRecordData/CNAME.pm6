use v6;

use DNS::Zone::ResourceRecordData;

class DNS::Zone::ResourceRecordData::CNAME is DNS::Zone::ResourceRecordData
{
	has Str $.domainName is rw;

	method gist()
	{ return "(Domain=$.domainName)"; }

	method Str()
	{ return $.domainName; }

	method gen()
	{ return $.domainName; }
}
