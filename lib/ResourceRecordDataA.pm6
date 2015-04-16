use v6;

use ResourceRecordData;

class ResourceRecordDataA is ResourceRecordData
{
	has Str $.ipAdress is rw;

	method gist()
	{ return $.ipAdress; }

	method Str()
	{ return $.ipAdress; }
}
