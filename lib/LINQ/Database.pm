use 5.008003;
use strict;
use warnings;

package LINQ::Database;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

use Class::Tiny qw( dbh );
use Scalar::Util ();

sub BUILDARGS {
	my ( $self ) = ( shift );
	
	if ( @_ == 1 and Scalar::Util::blessed( $_[0] ) ) {
		return { dbh => $_[0] };
	}
	else {
		require DBI;
		return { dbh => 'DBI'->connect( @_ ) };
	}
}

sub table {
	my ( $self ) = ( shift );
	my %args;
	if ( @_ == 1 and ref($_[0]) eq 'HASH' ) {
		%args = %{ $_[0] };
	}
	elsif ( @_ % 2 == 1 ) {
		%args = ( name => @_ );
	}
	else {
		%args = @_;
	}
	
	require LINQ::Database::Table;
	'LINQ::Database::Table'->new( { database => $self, %args } );
}

sub prepare {
	my ( $self, $sql ) = ( shift, @_ );
	$self->{last_sql} = $sql;
	$self->dbh->prepare( $sql );
}

sub quote {
	my ( $self ) = ( shift );
	$self->dbh->quote( @_ );
}

sub quote_identifier {
	my ( $self ) = ( shift );
	$self->dbh->quote_identifier( @_ );
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

LINQ::Database - LINQ extension for working with databases

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=LINQ-Database>.

=head1 SEE ALSO

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2021 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
