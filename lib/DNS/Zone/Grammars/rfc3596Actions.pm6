use v6;

class DNS::Zone::Grammars::rfc3596Actions {
	method type:sym<AAAA>($/)
	{
		make Type.new( type  => $<typeName>.Str,
		               rdata => DNS::Zone::ResourceRecordData::AAAA.new(ip6Adress => $<rdataAAAA>.Str) );
	}
}
