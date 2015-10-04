use v6;

use ResourceRecord;
use ResourceRecordDataA;
use ResourceRecordDataAAAA;
use ResourceRecordDataMX;
use ResourceRecordDataCNAME;
use ResourceRecordDataNS;
use ResourceRecordDataSOA;
use ResourceRecordDataPTR;
use Zone;
use Type;

class DNSZoneAction
{

	my $parenCount = 0;

	# Origin will be used to complete a domain name if it is not FQDN
	has $!origin = '';

	has $!currentTTL = '';
	has $!currentDomainName = '';


	# @TODO Semantic analysis
	method TOP($/)
	{
		# Add to the Zone object only ResourceRecord entries
		make Zone.new(
			rr => grep( { $_.ast ~~ ResourceRecord }, @<line> )».ast
		);
		# $<soa>.elems == 1
		# $<NS>.elems > 0
		# Check for errors
	}

	method line($/)
	{
		$parenCount=0;
		# say "resourceRecord = "~$<resourceRecord>.ast.gist;
		if $<resourceRecord>
		{
			make $<resourceRecord>.ast;
		}
	}

	method controlEntryAction:sym<TTL>($/)
	{
		$!currentTTL = $<ttl>;
	}

	method controlEntryAction:sym<ORIGIN>($/)
	{
		$!origin = $<domainName>.Str;
	}

	# Include a file into current zone
	# @TODO
	method controlEntryAction:sym<INCLUDE>($/)
	{ }

	method resourceRecord($/)
	{
		#say "currentDomainName="~$!currentDomainName~" ; currentTTL="~$!currentTTL;
		# say "domain name = $<domainName> ; ttl = "~$<ttlOrClass><ttl>~ " ; class = "~ $<ttlOrClass><class>.Str~ " ; type = "~$<type>.ast.type.Str~ " ; rdata = "~$<type>.ast.rdata;
		my $domainName = '';
		$domainName = $<domainName>.Str if $<domainName>;;
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
		$!currentTTL = +$/;
		make +$/; # The + convert to int
	}

	method type:sym<A>($/)
	{
		make Type.new( type  => ""~$<sym>,
		               rdata => ResourceRecordDataA.new(ipAdress => $<rdataA>.Str) );
	}

	method type:sym<AAAA>($/)
	{
		make Type.new( type  => $<sym>.Str,
		               rdata => ResourceRecordDataAAAA.new(ip6Adress => $<rdataAAAA>.Str) );
	}

	method type:sym<MX>($/)
	{
		make Type.new( type  => $<sym>.Str,
		               rdata => ResourceRecordDataMX.new(
		                        mxPref     => $<mxPref>,
		                        domainName => $<domainName>.Str) );
	}

	method type:sym<CNAME>($/)
	{
		make Type.new( type  => $<sym>.Str,
		               rdata => ResourceRecordDataCNAME.new(
		                        domainName => $<domainName>.Str) );
	}

	method type:sym<NS>($/)
	{
		make Type.new( type  => $<sym>.Str,
		               rdata => ResourceRecordDataNS.new(
		                        domainName => $<domainName>.Str) );
	}

	method type:sym<SOA>($/)
	{
		# say "in soa maker";
		make Type.new( type  => $<sym>.Str,
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
		make Type.new( type => $<sym>.Str,
		               rdata => ResourceRecordDataPTR.new(
		                        domainName => $<domainName>.Str) );
	}

	method rrSpace($/)
	{
		# say 'is a paren' if /\(|\)/;
		my $tt = $/.Str;
		given ( $/.Str )
		{
			$parenCount++ when '(';
			$parenCount-- when ')';
		}
	}
}
