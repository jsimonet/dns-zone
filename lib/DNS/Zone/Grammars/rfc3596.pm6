use v6;

# use Grammar::Debugger;
use Grammar::Tracer;

=begin pod
=synopsis Grammar to parse a dns zone file, including RFC 1035.
=author Julien Simonet
=version 0.1
=end pod
role DNS::Zone::Grammars::rfc3596 {
	token type:sym<AAAA>       { $<typeName> = [ :i 'aaaa' ] <rrSpace>+ <ipv6> }
	token type:sym<A6>         { $<typeName> = [ :i 'a6' ] <rrSpace>+ <ipv6> } # deprecated ?

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
		<doubleColon> <ipv4> |
		[
			<h16>                                        <doubleColon>   <ipv4> |
			<h16> ** 2 %         <doubleColon>   [ ':' | <doubleColon> ] <ipv4> |
			<h16> ** 3 % [ ':' | <doubleColon> ] [ ':' | <doubleColon> ] <ipv4> |
			<h16> ** 4 % [ ':' | <doubleColon> ] [ ':' | <doubleColon> ] <ipv4> |
			<h16> ** 5 % [ ':' | <doubleColon> ] [ ':' | <doubleColon> ] <ipv4> |
			<h16> ** 6 % [ ':' | <doubleColon> ] [ ':' | <doubleColon> ] <ipv4> |
			<doubleColon>? <h16> ** 0..8 % [ ':' | <doubleColon> ]
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

	# hexadecimal 16 bits
	token h16 {
		<:hexdigit> ** 1..4
	}

	token doubleColon {
		'::'
	}

	# IPv4
	token ipv4 {
		<d8> ** 4 % '.' # From http://rosettacode.org/wiki/Parse_an_IP_Address#Perl_6
	}
	token d8 {
		\d+ <?{ $/ < 256 }> # or $/ < 2 ** 8
	}
}
