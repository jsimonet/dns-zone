use v6;

use ResourceRecordData;

class ResourceRecordDataCNAME is ResourceRecordData
{
	has Str $.domainName is rw;

	method gist()
	{ return "(Domain=$.domainName)"; }

	method Str()
	{ return $.domainName; }
}
