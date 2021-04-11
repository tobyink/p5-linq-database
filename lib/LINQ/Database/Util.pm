use 5.008003;
use strict;
use warnings;

package LINQ::Database::Util;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

use Scalar::Util qw( blessed );

sub selection_to_sql {
	my ( $selection, $name_quoter ) = ( shift, @_ );
	
	return unless blessed( $selection );
	return unless $selection->isa( 'LINQ::FieldSet::Selection' );
	return if $selection->seen_asterisk;
	
	$name_quoter ||= sub {
		my $name = shift;
		return sprintf( '"%s"', quotemeta( $name ) );
	};	
	
	my @cols;
	for my $field ( @{ $selection->fields } ) {
		my $orig_name = $field->value;
		my $aliased   = $field->name;
		return if ref( $orig_name );
		# uncoverable branch true
		return if !defined( $aliased );
		
		push @cols, $name_quoter->( $orig_name );
	} #/ for my $field ( @{ $self...})
	
	return join( q[, ], @cols );
} #/ sub _sql_selection


1;
