use v6;

use ResourceRecord;
use ResourceRecordDataA;
use ResourceRecordDataAAAA;
use ResourceRecordDataMX;
use ResourceRecordDataCNAME;
use ResourceRecordDataNS;
use ResourceRecordDataSOA;
use ResourceRecordDataPTR;
use ResourceRecordDataTXT;
use ResourceRecordDataSRV;
use ResourceRecordDataSPF;
use Zone;
use Type;

=begin pod
=head1 Synopsis
=para
	The action of the grammar DNSZone. This class aims to create a comprensible AST,
	giving possibility to manipulate it easily (add/remove/alter some lines).
=end pod
class DNSZoneAction
{

	method TOP($/)
	{
		# Add to the Zone object only ResourceRecord entries
		make Zone.new(
			rr => grep( { $_.ast ~~ ResourceRecord }, @<entry> )».ast
		);
		# $<soa>.elems == 1
		# $<NS>.elems > 0
		# Check for errors
	}

	method entry($/)
	{
		if $<resourceRecord>
		{
			make $<resourceRecord>.ast;
		}
	}

	# Include a file into current zone
	# @TODO
	method controlEntryAction:sym<INCLUDE>($/)
	{ }

	method resourceRecord($/)
	{
		# say "domain name = $<domainName> ; ttl = "~$<ttlOrClass><ttl>~ " ; class = "~ $<ttlOrClass><class>.Str~ " ; type = "~$<type>.ast.type.Str~ " ; rdata = "~$<type>.ast.rdata;
		my $domainName = '';
		$domainName = $<domainName>.Str if $<domainName>.chars;
		make ResourceRecord.new( domainName => $domainName,
		                         ttl        => $<ttlOrClass><ttl>.Str,
		                         class      => $<ttlOrClass><class>.Str,
		                         type       => $<type>.ast.type.Str,
		                         rdata      => $<type>.ast.rdata );
	}

	method domainName:sym<fqdn>($/)
	{ make $/.Str; }

	method domainName:sym<labeled>($/)
	{ make $/.Str; }

	method domainName:sym<@>($/)
	{ make $/.Str; }

	method ttl($/)
	{
		make +$/; # The + convert to int
	}

	method type:sym<A>($/)
	{
		make Type.new( type  => $<typeName>.Str,
		               rdata => ResourceRecordDataA.new(ipAdress => $<rdataA>.Str) );
	}

	method type:sym<AAAA>($/)
	{
		make Type.new( type  => $<typeName>.Str,
		               rdata => ResourceRecordDataAAAA.new(ip6Adress => $<rdataAAAA>.Str) );
	}

	method type:sym<MX>($/)
	{
		make Type.new( type  => $<typeName>.Str,
		               rdata => ResourceRecordDataMX.new(
		                        mxPref     => $<mxPref>,
		                        domainName => $<domainName>.Str) );
	}

	method type:sym<CNAME>($/)
	{
		make Type.new( type  => $<typeName>.Str,
		               rdata => ResourceRecordDataCNAME.new(
		                        domainName => $<domainName>.Str) );
	}

	method type:sym<NS>($/)
	{
		make Type.new( type  => $<typeName>.Str,
		               rdata => ResourceRecordDataNS.new(
		                        domainName => $<domainName>.Str) );
	}

	method type:sym<SOA>($/)
	{
		make Type.new( type  => $<typeName>.Str,
		               rdata => ResourceRecordDataSOA.new(
		                        domainName   => $<rdataSOA>.<domainName>.Str,
		                        domainAction => $<rdataSOA>.<rdataSOAActionDomain>.Str,
		                        serial       => $<rdataSOA>.<rdataSOASerial>.Str,
		                        refresh      => $<rdataSOA>.<rdataSOARefresh>.Str,
		                        retry        => $<rdataSOA>.<rdataSOARetry>.Str,
		                        expire       => $<rdataSOA>.<rdataSOAExpire>.Str,
		                        min          => $<rdataSOA>.<rdataSOAMin>.Str ) );
	}

	method type:sym<PTR>($/)
	{
		make Type.new( type => $<typeName>.Str,
		               rdata => ResourceRecordDataPTR.new(
		                        domainName => $<domainName>.Str) );
	}

	method type:sym<TXT>($/)
	{
		make Type.new( type => $<typeName>.Str,
		               rdata => ResourceRecordDataTXT.new(
		                        txt => $<rdataTXT>.Str ) );
	}

	method type:sym<SRV>($/)
	{
		make Type.new( type => $<typeName>.Str,
		               rdata => ResourceRecordDataSRV.new(
		                        priority => $<rdataSRV>.<rdataSRVPriority>.Int,
		                        weight   => $<rdataSRV>.<rdataSRVWeight>.Int,
		                        port     => $<rdataSRV>.<rdataSRVPort>.Int,
		                        target   => $<rdataSRV>.<rdataSRVTarget>.Str
		                        )
		             );
	}

	method type:sym<SPF>($/)
	{
		make Type.new( type => $<typeName>.Str,
		               rdata => ResourceRecordDataSPF.new(
		                        spf => $<rdataTXT>.Str ) );
	}

}
