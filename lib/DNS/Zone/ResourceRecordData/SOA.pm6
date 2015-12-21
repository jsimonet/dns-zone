use v6;

use DNS::Zone::ResourceRecordData;

class DNS::Zone::ResourceRecordData::SOA is DNS::Zone::ResourceRecordData
{
	has $.domainName;
	has $.domainAction;
	has $.serial;
	has $.refresh;
	has $.retry;
	has $.expire;
	has $.min;

	has $!changed = False;

	method isChanged { $!changed }

	method domainName   { self!proxy($!domainName) }
	method domainAction { self!proxy($!domainName) }
	method serial       { self!proxy($!serial)     }
	method refresh      { self!proxy($!refresh)    }
	method retry        { self!proxy($!retry)      }
	method expire       { self!proxy($!expire)     }
	method min          { self!proxy($!min)        }

	method !proxy(\attr)
	{
		Proxy.new(
			FETCH => { attr },
			STORE => -> $, $value { $!changed = True; attr = $value }
		);
	}

	method gist()
	{
		return "(ResourceRecordDataSOA domainName="~$!domainName~" "~
		        "domainAction="~$!domainAction~" "~
		        "serial="~$!serial~" "~
		        "refresh="~$!refresh~" "~
		        "retry="~$!retry~" "~
		        "expire="~$!expire~" "~
		        "min="~$!min~")";
	}

	method Str()
	{ }

	method gen()
	{
		return "$.domainName $.domainAction $.serial $.refresh $.retry $.expire $.min";
	}
}
