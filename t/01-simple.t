#! perl -T

use strict;
use warnings;
use Test::More tests => 15;

use ACL::Lite;

my ($perms, $acl);

# permissions in a string
$perms = 'foo,bar';

$acl = ACL::Lite->new(permissions => $perms);

isa_ok($acl, 'ACL::Lite');

ok($acl->check('foo') eq 'foo');
ok($acl->check('bar') eq 'bar');
ok($acl->check(['foo', 'bar']) eq 'foo');
ok(! defined($acl->check('baz')));

# permissions in an array reference
$perms = [qw/foo bar/];

$acl = ACL::Lite->new(permissions => $perms);

isa_ok($acl, 'ACL::Lite');

ok($acl->check('foo') eq 'foo');
ok($acl->check('bar') eq 'bar');
ok($acl->check(['foo', 'bar']) eq 'foo');
ok(! defined($acl->check('baz')));

# permissions from a provider
$perms = sub {my %p = (foo => 1, bar => 1); return \%p};

$acl = ACL::Lite->new(permissions => $perms);

isa_ok($acl, 'ACL::Lite');

ok($acl->check('foo') eq 'foo');
ok($acl->check('bar') eq 'bar');
ok($acl->check(['foo', 'bar']) eq 'foo');
ok(! defined($acl->check('baz')));
