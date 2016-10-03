use v6;

use Test;

use lib 'lib';
use DNS::Zone::Grammars::Modern;

# Domain name
my @toTestAreOk = (
	'domainname',
	'domainname.tld',
	'domainame.tld.',
	'@',
);
my @toTestAreNOk = (
	'domain@',
	'sub@domain',
);

plan @toTestAreOk.elems + @toTestAreNOk;

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t, rule => 'domainName' ), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t, rule => 'domainName' ), $t;
}

done-testing;
