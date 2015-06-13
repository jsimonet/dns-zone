use v6;

use ResourceRecord;
use ResourceRecordDataA;
use ResourceRecordDataAAAA;
use ResourceRecordDataMX;
use ResourceRecordDataCNAME;
use ResourceRecordDataNS;
use ResourceRecordDataSOA;
use Zone;
use Type;

class DNSZoneAction
{

	my $parenCount=0;
	method TOP($/)
	{
		# say "bla="~@<line>».ast;
		make Zone.new( rr => @<line>».ast );
	}

	method line($/)
	{
		$parenCount=0;
		# say "resourceRecord = "~$<resourceRecord>.ast.gist;
		make $<resourceRecord>.ast;
	}


	method resourceRecord($/)
	{
		# say "domain name = $<domain_name> ; ttl = "~$<ttl_class><ttl>.Numeric~" ; class = "~$<ttl_class><class>.Str~" ; type = "~$<type><type>.Str~" ; rdata = "~$<type><rdata>~" brut type="~$<type>;
		make ResourceRecord.new( domainName => $<domain_name>.Str,
		                         ttl        => $<ttl_class><ttl>.Numeric,
		                         class      => $<ttl_class><class>.Str,
		                         type       => $<type>.ast.type.Str,
		                         rdata      => $<type>.ast.rdata );
	}

	method ttl($/)
	{
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
		                        mxPref     => $<mxpref>,
		                        domainName => $<domain_name>.Str) );
	}

	method type:sym<CNAME>($/)
	{
		make Type.new( type  => $<sym>.Str,
		               rdata => ResourceRecordDataCNAME.new(
		                        domainName => $<domain_name>.Str) );
	}

	method type:sym<NS>($/)
	{
		make Type.new( type  => $<sym>.Str,
		               rdata => ResourceRecordDataNS.new(
		                        domainName => $<domain_name>.Str) );
	}

	method type:sym<SOA>($/)
	{
		# say "in soa maker";
		make Type.new( type  => $<sym>.Str,
		               rdata => ResourceRecordDataSOA.new(
		                        domainName   => $<rdataSOA>.<domain_name>.Str,
		                        domainAction => $<rdataSOA>.<rdataSOA_action_domain>.Str,
		                        serial       => $<rdataSOA>.<rdataSOA_serial>.Str,
		                        refresh      => $<rdataSOA>.<rdataSOA_refresh>.Str,
		                        retry        => $<rdataSOA>.<rdataSOA_retry>.Str,
		                        expire       => $<rdataSOA>.<rdataSOA_expire>.Str,
		                        min          => $<rdataSOA>.<rdataSOA_min>.Str ) );
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
