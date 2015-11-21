use v6;

use DNS::Zone::ResourceRecordData::ResourceRecordData;

class ResourceRecordDataTXT is ResourceRecordData
{
	has Str $.txt is rw;

	method gist()
	{ return $.txt; }

	method Str()
	{ return $.txt; }

	method gen()
	{ return $.txt; }
}
