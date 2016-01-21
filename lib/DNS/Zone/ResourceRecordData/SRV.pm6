use v6;

use DNS::Zone::ResourceRecordData;

class DNS::Zone::ResourceRecordData::SRV is DNS::Zone::ResourceRecordData
{
	has Int $.priority is rw;
	has Int $.weight   is rw;
	has Int $.port     is rw;
	has Str $.target   is rw;

	method gist()
	{ return "$.priority $.weight $.port $.target"; }

	method Str()
	{ return "$.priority $.weight $.port $.target"; }

	method gen()
	{ return "$.priority $.weight $.port $.target"; }

	method type()
	{ "SRV" }
}
