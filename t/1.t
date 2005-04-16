#!perl
use strict;
use warnings;

BEGIN
{
	chdir 't' if -d 't';
}

use lib '../lib';

use Test::More tests => 7;

package Daddy;

Test::More->import();

sub new { bless {}, shift }

sub foo
{
	my $self = shift;
	isa_ok( $self, "Kid" );
	is( $_[0], 123, "Arguments passed OK" );
}

package Kid;

Test::More->import();
@Kid::ISA = 'Daddy';

use SUPER;

sub foo
{
	my $self = shift;
	if ( $_[0] > 100 )
	{
		super;
	}
	else
	{
		is( $_[0], 50, "Arguments retained OK" )
	}
}

my $a = Kid->new();
$a->foo(123);
$a->foo(50);

is( $a->super("new"), \&Daddy::new, "Kid's new is inherited from Daddy" );
is( $a->super("foo"), \&Daddy::foo,
	"... as is its foo, even though that's overriden" );
is( SUPER->super("import"),
	\&Exporter::import, "SUPER's import comes from Exporter" );
is( Test::More->super("import"),
	\&Exporter::import, "... and so does Test::More's" );
