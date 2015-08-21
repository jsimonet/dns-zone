use v6;
use Test;

BEGIN { @*INC.push('lib') };

use Grammars::DNSZone;
use Grammars::DNSZoneAction;

my @toTestAreOk = (
	'2000:1000:1000:1000:2000:1000:1000:1000',
	'2000::2000:1000:1000:1000',
	'2000::2000:1000:1000',
	'::10.10.1.1',
	'2000:123:abcd:123:456:789:10.10.1.1',
	'2000::123:abcd:10.10.1.1',
);

my @toTestAreNOk = (
	'2000:1000:1000:1000:2000:1000:1000::1000', # Too much elements
	'1000:10.0.0.1',                            # Not enough elements
	'1000::2000::3000',                         # Too much ::
	'10.0.0.1:1000::2000',                      # IPv4 must follow IPv6 part
	':1000::2000:10.0.0.1',                     # Cannot begins with :
	'1000::2000:10.0.0',                       # Incomplete IPv4
);

my $action = DNSZoneAction.new;

for @toTestAreOk
{
	ok DNSZone.parse($_, :actions($action), rule => 'ipv6' ), $_;
}

for @toTestAreNOk
{
	nok DNSZone.parse($_, :actions($action), rule => 'ipv6' ), $_;
}
