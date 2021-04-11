use 5.008003;
use strict;
use warnings;

package LINQ::Database::Table;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

use Class::Tiny qw( database name sql_select sql_where );

use LINQ ();
use LINQ::Util::Internal ();
use LINQ::Database::Util ();
use Object::Adhoc ();

use Role::Tiny::With ();
Role::Tiny::With::with 'LINQ::Collection';

sub _clone {
	my ( $self ) = ( shift );
	
	my %args = ( %$self, @_ );
	delete $args{'_linq_iterator'};
	ref( $self )->new( %args );
}

sub select {
	my ( $self ) = ( shift );
	my $selection = LINQ::Util::Internal::assert_code( @_ );
	
	if ( !$self->sql_select ) {
		my $columns = LINQ::Database::Util::selection_to_sql( $selection );
		return $self->_clone( sql_select => $selection ) if $columns;
	}
	
	$self->LINQ::Collection::select( $selection );
}

sub where {
	my ( $self ) = ( shift );
	my $assertion = LINQ::Util::Internal::assert_code( @_ );
	
	if ( !$self->sql_where ) {
		my $filter = LINQ::Database::Util::assertion_to_sql( $assertion );
		return $self->_clone( sql_where => $filter ) if $filter;
	}
	
	$self->LINQ::Collection::where( $assertion );
}

sub to_iterator {
	my ( $self ) = ( shift );
	$self->_linq_iterator->to_iterator;
}

sub to_list {
	my ( $self ) = ( shift );
	$self->_linq_iterator->to_list;
}

sub to_array {
	my ( $self ) = ( shift );
	$self->_linq_iterator->to_array;
}

sub _linq_iterator {
	my ( $self ) = ( shift );
	$self->{_linq_iterator} ||= $self->_build_linq_iterator;
}

sub _build_linq_iterator {
	my ( $self ) = ( shift );
	
	my $sth = $self->_build_sth;
	my $map = defined( $self->sql_select )
		? $self->sql_select
		: sub { Object::Adhoc::object( $_ ) };
	my $started = 0;
	
	LINQ::LINQ( sub {
		if ( not $started ) {
			$sth->execute;
			++$started;
		}
		local $_ = $sth->fetchrow_hashref or return LINQ::END;
		return $map->( $_ );
	} );
}

sub _build_sth {
	my ( $self ) = ( shift );
	
	my $sql_select = defined($self->sql_select) ? $self->sql_select : '*';
	if ( ref( $sql_select ) ) {
		$sql_select = LINQ::Database::Util::selection_to_sql(
			$sql_select,
			sub { $self->database->quote_identifier( @_ ) },
		) || '*';
	}
	
	my $sql_where = defined($self->sql_where) ? $self->sql_where : '';
	if ( ref( $sql_where ) ) {
		$sql_where = LINQ::Database::Util::selection_to_sql(
			$sql_where,
			sub { $self->database->quote_identifier( @_ ) },
			sub { $self->database->quote( @_ ) },
		) || '';
	}
	
	$self->database->prepare( sprintf(
		'SELECT %s FROM %s%s',
		$sql_select,
		$self->name,
		( $sql_where ? " WHERE $sql_where" : $sql_where ),
	) );
}

1;
