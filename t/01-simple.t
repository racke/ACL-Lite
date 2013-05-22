#! perl -T

use strict;
use warnings;
use Test::More tests => 21;

use ACL::Lite;

my ($perms, $acl, @parr, $pref);

# permissions in a string
$perms = 'foo,bar';

$acl = ACL::Lite->new(permissions => $perms);

isa_ok($acl, 'ACL::Lite');

ok($acl->check('foo') eq 'foo');
ok($acl->check('bar') eq 'bar');
ok($acl->check(['foo', 'bar']) eq 'foo');
ok(! defined($acl->check('baz')));

test_return_of_permissions($acl);

# permissions in an array reference
$perms = [qw/foo bar/];

$acl = ACL::Lite->new(permissions => $perms);

isa_ok($acl, 'ACL::Lite');

ok($acl->check('foo') eq 'foo');
ok($acl->check('bar') eq 'bar');
ok($acl->check(['foo', 'bar']) eq 'foo');
ok(! defined($acl->check('baz')));

test_return_of_permissions($acl);

# permissions from a provider
$perms = sub {my %p = (foo => 1, bar => 1); return \%p};

$acl = ACL::Lite->new(permissions => $perms);

isa_ok($acl, 'ACL::Lite');

ok($acl->check('foo') eq 'foo');
ok($acl->check('bar') eq 'bar');
ok($acl->check(['foo', 'bar']) eq 'foo');
ok(! defined($acl->check('baz')));

test_return_of_permissions($acl);

sub test_return_of_permissions {
    my $acl = shift;

    @parr = $acl->permissions;

    is_deeply([sort @parr], ['bar', 'foo'], "Test return value of permissions method (array).");

    $pref = $acl->permissions;

    is_deeply([sort keys %$pref], ['bar', 'foo'], "Test return value of permissions method (hash reference).");
}
