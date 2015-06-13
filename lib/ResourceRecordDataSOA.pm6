use v6;

use ResourceRecordData;

class ResourceRecordDataSOA is ResourceRecordData
{
	has $.domainName   is rw;
	has $.domainAction is rw;
	has $.serial       is rw;
	has $.refresh      is rw;
	has $.retry        is rw;
	has $.expire       is rw;
	has $.min          is rw;

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
}
