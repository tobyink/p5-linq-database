=pod

=encoding utf-8

=head1 PURPOSE

Test that LINQ::Database works.


=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2021 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test::Modern;
use FindBin '$Bin';

use LINQ;
use LINQ::Util -all;
use LINQ::Database;

my $db = 'LINQ::Database'->new( "dbi:SQLite:dbname=$Bin/data/disney.sqlite", "", "" );

my @people =
	$db
		->table( 'person' )
		->select( fields 'id', 'name', -as => 'moniker' )
		->order_by( -numeric, sub { $_->id } )
		->to_list;

is_deeply(
	[ map $_->moniker, @people ],
	[ qw( Anna Elsa Kristoff Sophia Rapunzel Lottie ) ],
);

is(
	$db->{last_sql},
	'SELECT "id", "name" FROM person',
);

done_testing;
