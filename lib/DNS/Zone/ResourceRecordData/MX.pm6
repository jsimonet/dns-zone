use v6;

use DNS::Zone::ResourceRecordData::ResourceRecordData;

class MX is ResourceRecordData
{
	has $.mxPref is rw;
	has Str $.domainName is rw;

	method gist()
	{ return '(MXData mxpref='~$.mxPref~' domain='~$.domainName~')'; }

	method Str()
	{ return $.mxPref~' '~$.domainName; }

	method gen()
	{ return "$.mxPref $.domainName"; }

}
