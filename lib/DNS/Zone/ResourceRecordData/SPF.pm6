use v6;

use DNS::Zone::ResourceRecordData::ResourceRecordData;

class SPF is ResourceRecordData
{
    has Str $.spf is rw;

    method gist()
    { return $.spf; }

    method Str()
    { return $.spf; }

    method gen()
    { return $.spf; }
}
