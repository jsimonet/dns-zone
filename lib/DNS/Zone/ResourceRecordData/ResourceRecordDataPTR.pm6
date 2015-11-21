use v6;

use DNS::Zone::ResourceRecordData::ResourceRecordData;

class ResourceRecordDataPTR is ResourceRecordData
{
	has Str $.domainName is rw;

	method gist()
	{ return "(Domain=$.domainName)"; }

	method Str()
	{ return $.domainName; }

	method gen()
	{ return "$.domainName"; }
}
