use v6;

use ResourceRecordData;

class ResourceRecordDataMX is ResourceRecordData
{
	has $.mxPref is rw;
	has Str $.domainName is rw;

	method gist()
	{ return '(MXData mxpref='~$.mxPref~' domain='~$.domainName~')'; }

	method Str()
	{ return $.mxPref~' '~$.domainName; }
}
