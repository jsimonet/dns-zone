use v6;

use DNS::Zone::ResourceRecordData::ResourceRecordData;

class ResourceRecord
{

	has Str                $.domainName       is rw = '';
	has Str                $.domainNameParsed is rw = ''; # For origin/previous domain
	has Str                $.class            is rw = '';
	has Str                $.ttl              is rw = '';
	has ResourceRecordData $.rdata            is rw;

	# has Bool               $.changed = False;

	method type
	{ $!rdata.WHAT.^name }

	method gist()
	{
		return "(ResourceRecord DomainName="~$!domainName~", class="~$!class~", ttl="~$!ttl~", type="~self.type~", rdata="~$!rdata.gist~")";
	}

	method Str()
	{
		return "Domain name="~$!domainName~", class="~$!class~", ttl="~$!ttl~", type="~self.type~", rdata="~$!rdata;
	}

	method gen()
	{
		return "$.domainName $.class $.ttl "~self.type~" "~$.rdata.gen();
	}
}
