package ACL::Lite;

use 5.006;
use strict;
use warnings;

=head1 NAME

ACL::Lite - Liteweight and flexible ACL checks

=head1 VERSION

Version 0.0002

=cut

our $VERSION = '0.0002';

=head1 SYNOPSIS

    use ACL::Lite;

    $acl = ACL::Lite->new(permissions => 'foo,bar');

    $acl->check('foo');

    if ($ret = $acl->check([qw/baz bar/])) {
        print "Check successful with permission $ret\n";
    }

    unless ($acl->check('baz')) {
        print "Permission denied\n";
    }

=head1 CONSTRUCTOR

=head2 new

Creates an ACL::Lite object by passing the following parameters:

=over 4

=item uid

User identifier for authenticated users.

=item permissions

Granted permissions.

=item separator

Separator used to parse permission strings. Defaults to C<,>.

=back

=cut

sub new {
	my ($class, $self, $type, %args);
	
	$class = shift;

	%args = @_;
	
	$self = {separator => $args{separator} || ',',
			 permissions => {},
			 uid => $args{uid},
			 volatile => 0};
	
	bless $self, $class;
	
	if (exists $args{permissions}) {
		$type = ref($args{permissions});

		if ($type eq 'ARRAY') {
			for my $perm (@{$args{permissions}}) {
				$self->{permissions}->{$perm} = 1;
			}
		}
		elsif ($type eq 'CODE') {
			$self->{volatile} = 1;
			$self->{sub} = $args{permissions};
		}
		else {
			my @perms;

			for my $perm (split(/$self->{separator}/, $args{permissions})) {
				$perm =~ s/^\s+//;
				$perm =~ s/\s+$//;
				next unless length($perm);

				$self->{permissions}->{$perm} = 1;
			}
		}
	}

	return $self;
}

=head2 check $permissions, $uid

Checks whether any of the permissions in $permissions is granted.
Returns first permission which grants access.

=cut

sub check {
	my ($self, $permissions, $uid) = @_;
	my (@check, $user_permissions);

	if (ref($permissions) eq 'ARRAY') {
		@check = @$permissions;
	}
	else {
		@check = ($permissions);
	}

	if ($uid && $uid ne $self->{uid}) {
		# mismatch on user identifier
		return;
	}

    $user_permissions = $self->permissions;

	for my $perm (@check) {
		if (exists $user_permissions->{$perm}) {
			return $perm;
		}
	}

	return;
}

=head2 permissions

Returns permissions as hash reference:

    $perms = $acl->permissions;

Returns permissions as list:

    @perms = $acl->permissions;

=cut

sub permissions {
    my ($self) = @_;

    if ($self->{volatile}) {
        $self->{permissions} = $self->{sub}->();
    }

    if (wantarray) {
        return keys %{$self->{permissions}};
    }

    return $self->{permissions};
}

=head1 CAVEATS

Please anticipate API changes in this early state of development.

=head1 AUTHOR

Stefan Hornburg (Racke), C<racke@linuxia.de>

=head1 BUGS

Please report any bugs or feature requests to C<bug-acl-lite at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ACL-Lite>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ACL::Lite


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ACL-Lite>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ACL-Lite>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ACL-Lite>

=item * Search CPAN

L<http://search.cpan.org/dist/ACL-Lite/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011-2013 Stefan Hornburg (Racke).

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of ACL::Lite
