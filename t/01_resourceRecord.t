use v6;

use Test;

use lib 'lib';
use DNS::Zone::Grammars::Modern;

# IPv4
my @toTestAreOk = (
);

my @toTestAreNOk = (
);

plan @toTestAreOk.elems + @toTestAreNOk.elems;

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t, rule => 'resourceRecord' ), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t, rule => 'resourceRecord' ), $t;
}
