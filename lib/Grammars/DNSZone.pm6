use v6;

# use Grammar::Debugger;
use Grammar::Tracer;

grammar DNSZone
{
	my $parenCount=0; # Used to count opened parentheses

	rule TOP { [ <line> ]+ { $parenCount=0; } }
	# rule TOP { [<line> ]+ }

	token line {
		^^ <resourceRecord> \h* <commentWithoutNewline>? |
		<comment>
	}

	# COMMENTS
	token commentWithoutNewline { ';' \N* }     # ;comment
	token comment               { ';' \N* \n? } # ;comment\n

	# Resource record
	token resourceRecord { [ <domainName> <rrSpace>+ ]? <rrSpace>* <ttlOrClass> <type> <rrSpace>* }

	# DOMAIN NAME
	# can be any of :
	# domain subdomain.domain domain.tld. @
	proto token domainName     { * }
	token domainName:sym<fqdn> { [ <[a..zA..Z0..9]>+ \.? ]+ }
	token domainName:sym<@>    { '@' }

	# TTL AND CLASS
	# <ttl> & <class> are optionals
	# A <class> or a <ttl>, is followed by a <rrSpace>.
	# If no class or <ttl> are matched, no <rrSpace> either so parenthese
	# count is ok
	token ttlOrClass {
		[ [ <class> | <ttl> ] <rrSpace>+ ] ** 1..2 <?{ $<class>.elems <= 1 && $<ttl>.elems <= 1; }> |
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
	token type:sym<CNAME>      { <sym> <rrSpace>+ <domainName> }
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
	token type:sym<MX>         { <sym> \h+ <mxPref> \h+ <domainName> }
	# token type:sym<NAPTR>      { <sym> }
	token type:sym<NS>         { <sym> \h+ <domainName> }
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
	token mxPref {
		\d ** 1..2
	}

	# TODO : check domain & rdataSOAActionDomain are correct
	token rdataSOA {
		<domainName> <rrSpace>+ <rdataSOAActionDomain> <rrSpace>*
		<rdataSOASerial> <rrSpace>* <comment>?
		<rrSpace>* <rdataSOARefresh> <rrSpace>* <comment>?
		<rrSpace>* <rdataSOARetry>   <rrSpace>* <comment>?
		<rrSpace>* <rdataSOAExpire>  <rrSpace>* <comment>?
		# <rdataSOAMin>    [<rrSpace>* <comment>? <rrSpace>* ]*
		<rrSpace>* <rdataSOAMin> <rrSpace>* <commentWithoutNewline>*
	}

	token rdataSOAActionDomain { <domainName> }
	token rdataSOASerial       { <d32>        }
	token rdataSOARefresh      { <d32>        }
	token rdataSOARetry        { <d32>        }
	token rdataSOAExpire       { <d32>        }
	token rdataSOAMin          { <d32>        }

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
	token paren:sym<pf> { ')' <?{ $parenCount > 0; }> { $parenCount--; } }
}
