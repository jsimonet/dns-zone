use v6;

use ResourceRecordData;

class ResourceRecordDataNS is ResourceRecordData
{
	has Str $.domain is rw;

	method gist()
	{ return "(Domain=$.domain)"; }

	method Str()
	{ return $.domain; }
}
