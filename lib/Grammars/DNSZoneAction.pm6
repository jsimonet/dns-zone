use v6;

use ResourceRecord;
use ResourceRecordDataA;
use ResourceRecordDataAAAA;
use Zone;
use Type;

class DNSZoneAction
{

	my $parenCount=0;
	method TOP($/)
	{
		# for @<line>
		# {
		# 	say "my line = "~$_.ast;
		# }
		make Zone.new( rr => @<line>».ast );
	}

	method line($/)
	{
		$parenCount=0;
		say "rr = "~$<rr>.ast.gist;
		make $<rr>.ast;
	}


	method rr($/)
	{
		# say "domain name = $<domain_name> ; ttl = "~$<ttl_class><ttl>.Numeric~" ; class = "~$<ttl_class><class>.Str~" ; type = "~$<type><type>.Str~" ; rdata = "~$<type><rdata>~" brut type="~$<type>;
		# my $rdata = '';
		# given $<type><sym>
		# {
		# 	when 'A'    { $rdata = ResourceRecordDataA.new(ipAdress => $<type>.rdata); }
		# 	when 'AAAA' { $rdata = ResourceRecordDataAAAA.new(ip6Adress => $<type>.rdata>); }
		# 	default { say 'Unknown type'; }
		# }

		make ResourceRecord.new( domainName => $<domain_name>.Str,
		                         ttl        => $<ttl_class><ttl>.Numeric,
		                         class      => $<ttl_class><class>.Str,
		                         type       => $<type>.ast.type.Str,
		                         rdata      => $<type>.ast.rdata);
	}

	method ttl($/)
	{
		make +$/; # convert to int
	}

	method type:sym<A>($/)
	{
		# my %type = (type => $<sym>, rdata => ResourceRecordDataA.new( ipAdress => $<rdataA> ) );
		# make (type => %type);
		# make type => $<sym>, rdata => $<rdataA>;
		make Type.new( type  => ""~$<sym>,
		               rdata => ResourceRecordDataA.new(ipAdress => $<rdataA>.Str) );
		# make Match.new( type => $<sym>, rdata => ResourceRecordDataA.new( ipAdress => $<rdataA> ) );
	}

	method type:sym<AAAA>($/)
	{
		make Type.new( type  => $<sym>.Str,
		               rdata => ResourceRecordDataAAAA.new(ip6Adress => $<rdataAAAA>.Str) );
	}

	method type:sym<MX>($/)
	{
		# make Type.new( type  => $<sym>.Str,
		#                rdata => ResourceRecordDataMX.new(todo => $<rdataMX>.Str) );
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

	# method paren($/)
	# {
	# 	# say 'Paren rule' ~ $<paren>.elems;
	# }

}
