use v6;

# use Grammar::Debugger;
# use Grammar::Tracer;

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

	# Do not correct the problem because <rrSpace> is parsed anyway...
	# token ttl_class {
	# 	[ <class> | <ttl> ] ** 1..2 % [ <rrSpace>+ ] <rrSpace>+ <?{ $<class>.elems <= 1 && $<ttl>.elems <= 1; }> |
	# 	''
	# }

	# A <class> or a <ttl>, is followed by a <rrSpace>.
	# If no class or <ttl> are matched, no <rrSpace> either so parenthese
	# count is ok
	token ttl_class {
		[ [ <class> | <ttl> ] <rrSpace>+ ] ** 1..2 <?{ $<class>.elems <= 1 && $<ttl>.elems <= 1; }> |
		# [ [ <class> | <ttl> ] <rrSpace>+ ] [ [ <class> | <ttl> ] <rrSpace>+ ]? <?{ $<class>.elems <= 1 && $<ttl>.elems <= 1; }> |
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
	# If only "single" semi-colon are present, the count of <h16> have to be == 8
	# Only one "double" semi-colon, and the count of <h16> have to be < 8
	# IPv6 can end with IPv4 notation:
	#   exemple: 0:0:0:0:0:FFFF:129.144.52.38
	# http://tools.ietf.org/html/rfc2373#section-2.2
	# IPv4 possible regex:
	#   ^(^(([0-9A-F]{1,4}(((:[0-9A-F]{1,4}){5}::[0-9A-F]{1,4})|((:[0-9A-F]{1,4}){4}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,1})|((:[0-9A-F]{1,4}){3}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,2})|((:[0-9A-F]{1,4}){2}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,3})|(:[0-9A-F]{1,4}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,4})|(::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,5})|(:[0-9A-F]{1,4}){7}))$|^(::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,6})$)|^::$)|^((([0-9A-F]{1,4}(((:[0-9A-F]{1,4}){3}::([0-9A-F]{1,4}){1})|((:[0-9A-F]{1,4}){2}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,1})|((:[0-9A-F]{1,4}){1}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,2})|(::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,3})|((:[0-9A-F]{1,4}){0,5})))|([:]{2}[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,4})):|::)((25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{0,2})\.){3}(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{0,2})$$
	# @see t/ipv6.t

	# Need to test sequencely <h16> part because some <d8> can be interpreted as <h16> tokens, like 
	# 1000::10.0.0.1 The "10" is interpreted as <h16> and <ipv6> token fails.
	token ipv6 {
		<doubleColon> <ipv4>
		|
		[
			<h16> ** 1 % [ ':' | <doubleColon> ] [ ':' | <doubleColon> ] <ipv4>
			|
			<h16> ** 2 % [ ':' | <doubleColon> ] [ ':' | <doubleColon> ] <ipv4>
			|
			<h16> ** 3 % [ ':' | <doubleColon> ] [ ':' | <doubleColon> ] <ipv4>
			|
			<h16> ** 4 % [ ':' | <doubleColon> ] [ ':' | <doubleColon> ] <ipv4>
			|
			<h16> ** 5 % [ ':' | <doubleColon> ] [ ':' | <doubleColon> ] <ipv4>
			|
			<h16> ** 6 % [ ':' | <doubleColon> ] [ ':' | <doubleColon> ] <ipv4>
				# <?{
				# 	($<doubleColon>.elems == 0 && $<h16>.elems == 6)
				# 	|| ( $<doubleColon>.elems == 1 && $<h16>.elems < 6 )
				# }>
			|
			<doubleColon>? <h16> ** 0..8 % [ ':' | <doubleColon> ]
				# <?{
				# 	($<doubleColon>.elems == 0 && $<h16>.elems == 8)
				# 	|| ($<doubleColon>.elems == 1 && $<h16>.elems < 8)
				# }>
		]
		<?{
			(
				(
					$<doubleColon>.elems == 0 && (
						( $<h16>.elems == 8 ) ||
						( $<h16>.elems == 6 && $<ipv4><d8>.elems == 4 )
					)
				)
				||
				(
					$<doubleColon>.elems == 1 && (
						( $<h16>.elems < 8 ) ||
						( $<h16>.elems < 6  && $<ipv4><d8>.elems ==  4 )
					)
				)
			)
		}>

	}

	token doubleColon {
		'::'
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
		\n <?{ $parenCount > 0; }> |
		<paren>
	}

	# PAREN
	# Parenthese definition
	proto token paren { * }
	token paren:sym<po> { '(' { $parenCount++; } }
	# token paren:sym<po> { '(' }
	token paren:sym<pf> { ')' <?{ $parenCount > 0; }> { $parenCount--; } }
	# token paren:sym<pf> { ')' }

}

