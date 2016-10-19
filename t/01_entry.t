use v6;

use Test;

use lib 'lib';
use DNS::Zone::Grammars::Modern;

my @toTestAreOk = (
	'testcomment A 10.0.0.1 ; this is a comment',
	'; only a comment',
	'( dname a 10.0.0.3 )',
	'()',
);

my @toTestAreNOk = (
	'(',
);

plan @toTestAreOk.elems + @toTestAreNOk.elems;

# Need to set up a ttl to check the rule "entry"
my $parser = DNS::Zone::Grammars::Modern.new;
$parser.parse( '$ttl 1234', :rule<entry> );

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t, rule => 'entry' ), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t, rule => 'entry' ), $t;
}
