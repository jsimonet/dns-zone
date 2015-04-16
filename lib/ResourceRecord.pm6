use v6;

use ResourceRecordData;

class ResourceRecord
{

	has Str                $.domainName is rw;
	has Str                $.class      is rw;
	has Int                $.ttl        is rw;
	has Str                $.type       is rw;
	has ResourceRecordData $.rdata      is rw;

	method gist()
	{
		return "(ResourceRecord Domain name="~$!domainName~", class="~$!class~", ttl="~$!ttl~", type="~$!type~", rr="~$!rdata~")";
	}

	method Str()
	{
		return "Domain name="~$!domainName~", class="~$!class~", ttl="~$!ttl~", type="~$!type~", rr="~$!rdata;
	}

}
