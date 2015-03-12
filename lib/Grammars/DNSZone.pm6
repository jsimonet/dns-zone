use v6;

# use Grammar::Debugger;

grammar DNSZone
{
	my $parenCount=0;

	method isParenCountOK( Str :$str )
	{
		my $parenO = +$str.comb: /\(/;
		my $parenF = +$str.comb: /\)/;
		$parenO == $parenF;
	}

	# rule TOP { [<line> ]+ { $parenCount=0; } }
	rule TOP { [<line> ]+ }

	token line {
		# ^^ <rr> \h* <commentWithoutNewline>? <?{ ! $parenCount }> |
		# ^^ <rr> \h* <commentWithoutNewline>? <?{ self.isParenCountOK( str => $/.Str ) ; }> |
		^^ <rr> \h* <commentWithoutNewline>? |
		<comment> #|
		# <emptyLine>
	}

	# token emptyLine {
	# 	^^ [\h | \v | \n]+ $$ |
	# 	^^ \h* $$ |
	# 	^ $ |
	# 	\h* \n
	# }

	token commentWithoutNewline { ';' \N* } # ;comment
	token comment               { ';' \N* \n? }    # ;comment\n

	token rr { [ <domain_name> <rrSpace>+ ]? <rrSpace>* <ttl_class> <type> <rrSpace>* }

	# DOMAIN NAME
	# token rr_domain_name {
	# 	^^ <domain_name> \h+ |
	# 	''
	# }

	# can be null, or any of :
	# domain subdomain.domain domain.tld. @
	proto token domain_name     { * }
	token domain_name:sym<fqdn> { [ <[a..z0..9]>+ \.? ]+ }
	token domain_name:sym<@>    { '@' }
	# token domain_name:sym<null> { '' }

	# TTL AND CLASS
	token ttl_class{
		<class> <rrSpace>+ <ttl>   <rrSpace>+ |
		<ttl>   <rrSpace>+ <class> <rrSpace>+ |
		<class>                    <rrSpace>+ |
		<ttl>                      <rrSpace>+ |
		''
	}

	# TTL, can be:
	# 42 1s 2m 3h 4j 5w 1y
	token ttl {
		<[0..9]>+ <[smhjwy]>?
	}

	# CLASS
	proto token class   { * }
	token class:sym<IN> { <sym> } # The Internet
	token class:sym<CH> { <sym> } # Chaosnet
	token class:sym<HS> { <sym> } # Hesiod

	# TYPE
	proto token type           { * }
	token type:sym<A>          { <sym> <rrSpace>+ <rdataA> <rrSpace>* }
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
	token rdataA {<ipv4>}
	token rdataAAAA {<ipv6>}

	# IPv4
	token ipv4 {
		<d8> ** 4 % '.' # From http://rosettacode.org/wiki/Parse_an_IP_Address#Perl_6
	}

	# IPV6
	# TODO add count of <hexdigit> & :: : for each ::, one :hexdigit less
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

	# int 8 bits
	token d32 {
		\d+ <?{ $/ < 4294967296 }> # or $/ < 2 ** 32
	}

	# hexadecimal 16 bits
	token h16 {
		<:hexdigit> ** 1..4
	}

	# rrSpace can be a classic space, or a ( or )
	# for \n space, at least one ( have to be matched
	token rrSpace {
		\h                         |
		# \n <?{ $parenCount > 0; }> |
		\n |
		<paren>
	}

	token anySpace {
		[\h|\v]*
	}

	proto token paren { * }
	token paren:sym<po> { '(' }
	token paren:sym<pf> { ')' }

}

