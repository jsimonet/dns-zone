use v6;

use ResourceRecordData;

class ResourceRecordDataSPF is ResourceRecordData
{
    has Str $.spf is rw;

    method gist()
    { return $.spf; }

    method Str()
    { return $.spf; }

    method gen()
    { return $.spf; }
}
