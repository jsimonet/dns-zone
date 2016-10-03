use v6;

use Test;

use lib 'lib';
use DNS::Zone::Grammars::Modern;

# Type
my @toTestAreOk = (
	'a 10.0.0.1',
	'A 10.0.0.2',
	'aaaa 1000::2000',
	'a6 2000::aaaa',
	'cname firstcname',
	'CNAme secondcname',
);

my @toTestAreNOk = (
	'',
	'a',
	'aa 1000::2000',
	' cname tooMuchSpaces',
	"\tcname tooMuchSpaces",
);

plan @toTestAreOk.elems + @toTestAreNOk.elems;

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t, rule => 'type' ), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t, rule => 'type' ), $t;
}

done-testing;
