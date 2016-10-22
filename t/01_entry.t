use v6;

use Test;

use lib 'lib';
use DNS::Zone::Grammars::Modern;

my @toTestAreOk = (
	'testcomment A 10.0.0.1 ; this is a comment', # A resource record with a comment
	'; only a comment',
	' ; comment preceded by space',
	"(\n) 	; comment preceded by some rrSpace",
	'( dname a 10.0.0.3 )',
	'()',
	' ',
);

my @toTestAreNOk = (
	'(',                                 # Parentheses count fails
	"  ; comment ending with newline\n",
	"; comment ending with newline",
	'notype',
	'notype in',
	'notype in 1234',
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
