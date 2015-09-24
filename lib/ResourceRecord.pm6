use v6;

use ResourceRecordData;

class ResourceRecord
{

	has Str                $.domainName       is rw;
	has Str                $.domainNameParsed is rw; # For origin/previous domain
	has Str                $.class            is rw;
	has Int                $.ttl              is rw;
	has Str                $.type             is rw;
	has ResourceRecordData $.rdata            is rw;

	# has Bool               $.changed = False;

	method gist()
	{
		return "(ResourceRecord DomainName="~$!domainName~", class="~$!class~", ttl="~$!ttl~", type="~$!type~", rdata="~$!rdata.gist~")";
	}

	method Str()
	{
		return "Domain name="~$!domainName~", class="~$!class~", ttl="~$!ttl~", type="~$!type~", rdata="~$!rdata;
	}

	method gen()
	{
		return "$.domainName $.class $.ttl $.type "~$.rdata.gen();
	}
}
