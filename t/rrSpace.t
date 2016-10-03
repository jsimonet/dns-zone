use v6;

use Test;

use lib 'lib';
use DNS::Zone::Grammars::Modern;

my @toTestAreOk = (
	' ',
	'  ',
	'	',
	" 	",
	'(',
	')',
	'()',
);

my @toTestAreNOk = (
	"\n",
);

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t, rule => 'rrSpace' ), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t, rule => 'rrSpace' ), $t;
}

done-testing;
