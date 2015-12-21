use v6;

# use Grammar::Debugger;
use Grammar::Tracer;
use DNS::Zone::Grammars::rfc1035;
use DNS::Zone::Grammars::rfc3596;

=begin pod
=synopsis Grammar to parse a dns zone file, including RFC 1035.
=author Julien Simonet
=version 0.1
=end pod
grammar DNS::Zone::Grammars::Modern
	is DNS::Zone::Grammars::rfc1035 # Original RFC
	does DNS::Zone::Grammars::rfc3596 # IPv6
{
}
