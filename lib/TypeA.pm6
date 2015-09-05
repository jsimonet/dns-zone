class TypeA
{
	has $.type;
	has $.rdata;

	method gen()
	{
		return "$!type "~$.rdata.gen();
	}
}
