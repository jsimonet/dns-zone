use v6;

# use Grammar::Debugger;
use Grammar::Tracer;

grammar DNSZone
{
	my $parenCount = 0; # Used to count opened parentheses
	my $maxDomainNameLengh      = 254;
	my $maxRdataTXTLengh        = 255;
	my $maxLabelDomainNameLengh = 63;

	my $currentDomainName;
	my $currentTTL;

	token TOP { [ <line> ]+ { $parenCount = 0; } }
	# rule TOP { [<line> ]+ }

	token line {
		^^ <resourceRecord> \h* <commentWithoutNewline>? \v* <?{ $parenCount == 0; }> |
		<controlEntry> \v* |
		<commentWithoutNewline> \v*
	}

	# COMMENTS
	token commentWithoutNewline { ';' \N*     } # ;comment
	token comment               { ';' \N* \n? } # ;comment\n

	token controlEntry {
		'$' <controlEntryAction>
	}

	proto token controlEntryAction { * }
	token controlEntryAction:sym<TTL>     {
		<sym> \h+ <ttl>
		{ $currentTTL = $<ttl>.Str.Numeric; }
	}

	token controlEntryAction:sym<ORIGIN>  { <sym> \h+ <domainName> }
	#token controlEntryAction:sym<INCLUDE> { <sym> \h+ <fileName>   }

	# Resource record
	# A domainName is needed, even if it is empty. In this case, the line have to begin
	# with a space.
	token resourceRecord {
		[ <domainName> | '' ] <rrSpace>+ <ttlOrClass> <type> <rrSpace>*
		{ $currentDomainName = $<domainName>.Str if $<domainName>; }
		<?{ $currentTTL && $currentDomainName; }>
	}

	# DOMAIN NAME
	# can be any of :
	# domain subdomain.domain domain.tld. @
	proto token domainName { * }

	token domainName:sym<fqdn> {
		# Same as labeled but with a final dot
		<domainNameLabel> ** { 1 .. $maxDomainNameLengh/2 }  % '.' '.'
		<?{
			$/.Str.chars <= $maxDomainNameLengh;
		}>
	}

	token domainName:sym<labeled> {
		<domainNameLabel> ** { 1 .. $maxDomainNameLengh/2 }  % '.'
		#<?{ $/.Str.chars + 1 + $origin.chars < $maxDomainNameLengh; }>
	}

	token domainName:sym<@> { '@' }

	token domainNameLabel {
		<alnum> [ <alnum> | '-' ] ** {0 .. $maxLabelDomainNameLengh - 1}
	}

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
	token class:sym<IN> { $<sym> = [ :i 'in' ] } # The Internet
	token class:sym<CH> { $<sym> = [ :i 'ch' ] } # Chaosnet
	token class:sym<HS> { $<sym> = [ :i 'hs' ] } # Hesiod

	# TYPE
	proto token type           { * }
	token type:sym<A>          { $<typeName> = [ :i 'a' ] <rrSpace>+ <rdataA> }
	token type:sym<AAAA>       { $<typeName> = [ :i 'aaaa' ] <rrSpace>+ <rdataAAAA> }
	# token type:sym<AFSDB>      { <$typeName> = '' }
	# token type:sym<APL>        { <$typeName> = '' }
	token type:sym<A6>         { $<typeName> = [ :i 'a6' ] <rrSpace>+ <rdataAAAA> }
	# token type:sym<CERT>       { <$typeName> = '' }
	token type:sym<CNAME>      { $<typeName> = [ :i 'cname' ] <rrSpace>+ <domainName> }
	# token type:sym<DHCID>      { <$typeName> = '' }
	# token type:sym<DNAME>      { <$typeName> = '' }
	# token type:sym<DNSKEY>     { <$typeName> = '' }
	# token type:sym<DS>         { <$typeName> = '' }
	# token type:sym<GPOS>       { <$typeName> = '' }
	# token type:sym<HINFO>      { <$typeName> = '' }
	# token type:sym<IPSECKEY>   { <$typeName> = '' }
	# token type:sym<ISDN>       { <$typeName> = '' }
	# token type:sym<KEY>        { <$typeName> = '' }
	# token type:sym<KX>         { <$typeName> = '' }
	# token type:sym<LOC>        { <$typeName> = '' }
	token type:sym<MX>         { $<typeName> = [ :i 'mx' ] \h+ <mxPref> \h+ <domainName> }
	# token type:sym<NAPTR>      { <$typeName> = '' }
	token type:sym<NS>         { $<typeName> = [ :i 'ns' ] \h+ <domainName> }
	# token type:sym<NSAP>       { <$typeName> = '' }
	# token type:sym<NSEC>       { <$typeName> = '' }
	# token type:sym<NSEC3>      { <$typeName> = '' }
	# token type:sym<NSEC3PARAM> { <$typeName> = '' }
	# token type:sym<NXT>        { <$typeName> = '' }
	token type:sym<PTR>        { $<typeName> = [ :i 'ptr' ] <rrSpace>+ <domainName> }
	# token type:sym<PX>         { <$typeName> = '' }
	# token type:sym<RP>         { <$typeName> = '' }
	# token type:sym<RRSIG>      { <$typeName> = '' }
	# token type:sym<RT>         { <$typeName> = '' }
	token type:sym<SOA>        { $<typeName> = [ :i 'soa' ] \h+ <rdataSOA> }
	# token type:sym<SIG>        { <$typeName> = '' }
	token type:sym<SPF>        { $<typeName> = [ :i 'spf' ] ' test' }
	token type:sym<SRV>        { $<typeName> = [ :i 'srv' ] <rrSpace>+ <rdataSRV> }
	# token type:sym<SSHFP>      { <$typeName> = '' }
	token type:sym<TXT>        { $<typeName> = [ :i 'txt' ] <rrSpace>+ <rdataTXT> }
	# token type:sym<WKS>        { <$typeName> = '' }
	# token type:sym<X25>        { <$typeName> = '' }

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

		{
			unless defined $currentTTL {
				$currentTTL = $<rdataSOAMin>.Str.Numeric unless $currentTTL;
			}
		}
	}

	token rdataSOAActionDomain { <domainName> }
	token rdataSOASerial       { <d32>        }
	token rdataSOARefresh      { <d32>        }
	token rdataSOARetry        { <d32>        }
	token rdataSOAExpire       { <d32>        }
	token rdataSOAMin          { <d32>        }

	token rdataTXT {
		[ <text> | <quotedText> ]+
		<?{ $/.Str.chars < $maxRdataTXTLengh }>
	}

	# A suit of chars, without spaces
	token text {
		[ <-[ ( ) \v " \ ]> | <rrSpace> | '\"']+
	}

	# A suit of chars, with space availables
	token quotedText {
		'"' [ <-[ \n " ]> | "\\\n" | '\"' ]* '"'
	}

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
