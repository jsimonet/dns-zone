use v6;

use Test;

use lib 'lib';
use DNS::Zone::Grammars::Modern;

# Comments
my @toTestAreOk = (
	";\n",
	";comment\n",
	";comment",
);
my @toTestAreNOk = (
	' ;fail\n',
	";comm\n\n", # Only one newline
);

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t, rule => 'comment' ), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t, rule => 'comment' ), $t;
}

done-testing;
