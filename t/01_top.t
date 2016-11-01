use v6;

use Test;

use lib 'lib';
use DNS::Zone::Grammars::Modern;

my @toTestAreOk = (
	'',
	"\n",
	"\$ttl 123",
	"\$ttl 123\n",
	"\$ttl 123\ndomain in a 10.0.0.1",
);

my @toTestAreNOk = (
	"\$ttl 3600 domain in a 10.0.0.1",
);

# plan @toTestAreOk.elems + @toTestAreNOk.elems;

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t), $t;
}

# See Issue #2
todo 'Will not pass because $currentTTL is static';
nok DNS::Zone::Grammars::Modern.parse( 'domain in a 10.0.0.1' ); # No ttl defined

done-testing;
