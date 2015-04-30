use v6;

use ResourceRecordData;

class ResourceRecordDataMX is ResourceRecordData
{
	has $.mxPref is rw;
	has Str $.domain is rw;

	method gist()
	{ return '(MXData mxpref='~$.mxPref~' domain='~$.domain~')'; }

	method Str()
	{ return $.mxPref~' '~$.domain; }
}
