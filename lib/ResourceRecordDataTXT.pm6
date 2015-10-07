use v6;

use ResourceRecordData;

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
