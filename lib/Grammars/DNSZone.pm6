use v6;

# use Grammar::Debugger;
use Grammar::Tracer;

grammar DNSZone
{
	my $parenCount=0; # Used to count opened parentheses

	method isParenCountOK( Str :$str )
	{
		my $parenO = +$str.comb: /\(/;
		my $parenF = +$str.comb: /\)/;
		$parenO == $parenF;
	}

	# rule TOP { [ <line> ]+ { $parenCount=0; } }
	rule TOP { [<line> ]+ }

	token line {
		^^ <resourceRecord> \h* <commentWithoutNewline>? |
			# { say "ParenCount is = $parenCount";} |
		# ^^ <resourceRecord> \h* <commentWithoutNewline>? <?{ self.isParenCountOK( str => $/.Str ) ; }> |
		# ^^ <resourceRecord> \h* <commentWithoutNewline>? |
		<comment> #|
	}

	# COMMENTS
	token commentWithoutNewline { ';' \N* }     # ;comment
	token comment               { ';' \N* \n? } # ;comment\n

	# Resource record
	token resourceRecord { [ <domain_name> <rrSpace>+ ]? <rrSpace>* <ttl_class> <type> <rrSpace>* }

	# DOMAIN NAME
	# can be any of :
	# domain subdomain.domain domain.tld. @
	proto token domain_name     { * }
	token domain_name:sym<fqdn> { [ <[a..z0..9]>+ \.? ]+ }
	token domain_name:sym<@>    { '@' }

	# TTL AND CLASS
	# <ttl> & <class> are optionals
	# TODO this token is problematic for parentheses count
	# I stupidely increment & decrement $parenCount to know if a \n is legal but,
	# two rules are parsed to check the existence of the second token
	# --> <rrSpace> is called twice too, so $parenCount is incorrect.
	# token ttl_class{
	# 	<class> <rrSpace>+ <ttl>   <rrSpace>+ |
	# 	<ttl>   <rrSpace>+ <class> <rrSpace>+ |
	# 	<class>                    <rrSpace>+ |
	# 	<ttl>                      <rrSpace>+ |
	# 	''
	# }

	token ttl_class {
		[ <class> | <ttl> ] ** 1..2 % [ <rrSpace>+ ] <rrSpace>+ <?{ $<class>.elems <= 1 && $<ttl>.elems <= 1; }> |
		''
	}

	# TTL, can be:
	# 42 1s 2m 3h 4j 5w 6y
	token ttl {
		<[0..9]>+ <[smhjwy]>?
	}

	# CLASS
	# TODO : case insensitive
	proto token class   { * }
	token class:sym<IN> { <sym> } # The Internet
	token class:sym<CH> { <sym> } # Chaosnet
	token class:sym<HS> { <sym> } # Hesiod

	# TYPE
	proto token type           { * }
	token type:sym<A>          { <sym> <rrSpace>+ <rdataA> }
	token type:sym<AAAA>       { <sym> <rrSpace>+ <rdataAAAA> }
	# token type:sym<AFSDB>      { <sym> }
	# token type:sym<APL>        { <sym> }
	token type:sym<A6>         { <sym> <rrSpace>+ <rdataAAAA> }
	# token type:sym<CERT>       { <sym> }
	token type:sym<CNAME>      { <sym> <rrSpace>+ <domain_name> }
	# token type:sym<DHCID>      { <sym> }
	# token type:sym<DNAME>      { <sym> }
	# token type:sym<DNSKEY>     { <sym> }
	# token type:sym<DS>         { <sym> }
	# token type:sym<GPOS>       { <sym> }
	# token type:sym<HINFO>      { <sym> }
	# token type:sym<IPSECKEY>   { <sym> }
	# token type:sym<ISDN>       { <sym> }
	# token type:sym<KEY>        { <sym> }
	# token type:sym<KX>         { <sym> }
	# token type:sym<LOC>        { <sym> }
	token type:sym<MX>         { <sym> \h+ <mxpref> \h+ <domain_name> }
	# token type:sym<NAPTR>      { <sym> }
	token type:sym<NS>         { <sym> \h+ <domain_name> }
	# token type:sym<NSAP>       { <sym> }
	# token type:sym<NSEC>       { <sym> }
	# token type:sym<NSEC3>      { <sym> }
	# token type:sym<NSEC3PARAM> { <sym> }
	# token type:sym<NXT>        { <sym> }
	# token type:sym<PTR>        { <sym> }
	# token type:sym<PX>         { <sym> }
	# token type:sym<RP>         { <sym> }
	# token type:sym<RRSIG>      { <sym> }
	# token type:sym<RT>         { <sym> }
	token type:sym<SOA>        { <sym> \h+ <rdataSOA> }
	# token type:sym<SIG>        { <sym> }
	# token type:sym<SPF>        { <sym> }
	# token type:sym<SRV>        { <sym> }
	# token type:sym<SSHFP>      { <sym> }
	# token type:sym<TXT>        { <sym> }
	# token type:sym<WKS>        { <sym> }
	# token type:sym<X25>        { <sym> }


	# RDATA
	# depends on TYPE
	token rdataA {<ipv4>}
	token rdataAAAA {<ipv6>}

	# IPv4
	token ipv4 {
		<d8> ** 4 % '.' # From http://rosettacode.org/wiki/Parse_an_IP_Address#Perl_6
	}

	# IPV6
	# TODO Only one semi-colon, and the count of <h16> have to be < 8
	# If only "single" semi-colon are present, the count of <h16> have to be == 8
	token ipv6 {
		<h16> ** 2..8 % [ ':' | '::' ]
	}


	# MX
	token mxpref {
		\d ** 1..2
	}

	# TODO : check domain & rdataSOA_action_domain are correct
	token rdataSOA {
		<domain_name> <rrSpace>+ <rdataSOA_action_domain> <rrSpace>*
		<rdataSOA_serial> <rrSpace>* <comment>?
		<rrSpace>* <rdataSOA_refresh> <rrSpace>* <comment>?
		<rrSpace>* <rdataSOA_retry>   <rrSpace>* <comment>?
		<rrSpace>* <rdataSOA_expire>  <rrSpace>* <comment>?
		# <rdataSOA_min>    [<rrSpace>* <comment>? <rrSpace>* ]*
		<rrSpace>* <rdataSOA_min> <rrSpace>* <commentWithoutNewline>*
	}

	token rdataSOA_action_domain { <domain_name> }
	token rdataSOA_serial        { <d32>         }
	token rdataSOA_refresh       { <d32>         }
	token rdataSOA_retry         { <d32>         }
	token rdataSOA_expire        { <d32>         }
	token rdataSOA_min           { <d32>         }

	# int 8 bits
	token d8 {
		\d+ <?{ $/ < 256 }> # or $/ < 2 ** 8
	}

	# int 32 bits
	token d32 {
		\d+ <?{ $/ < 4294967296 }> # or $/ < 2 ** 32
	}

	# hexadecimal 16 bits
	token h16 {
		<:hexdigit> ** 1..4
	}

	# RRSPACE
	# Can be a classic space, or a ( or )
	# for \n space, at least one ( have to be matched
	token rrSpace {
		\h                         |
		# \n <?{ $parenCount > 0; }> |
		\n |
		<paren>
	}

	# PAREN
	# Parenthese definition
	proto token paren { * }
	# token paren:sym<po> { '(' { $parenCount++; } }
	token paren:sym<po> { '(' }
	# token paren:sym<pf> { ')' { $parenCount--; } <?{ $parenCount > 0; }>}
	token paren:sym<pf> { ')' }

}

