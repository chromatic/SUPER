#!perl -w
use strict;
use warnings;
use Test::More tests => 4;

# so being able to say super() once is neat, but I want to super all
# the way back up to the root of the tree

package Grandfather;
use Test::More;
sub foo {
    ok( 1, "Called on the Grandfather\n" );
    return 42;
}

package Father;
use Test::More;
use SUPER;
use base qw( Grandfather );
my $called;
sub foo {
    die "Recursed on Father (should have called Grandfather)"
      if ++$called > 1;

    ok( 1, "Called on the Father" );
    super;
}

package Son;
use Test::More;
use SUPER;
use base qw( Father );
sub foo {
    ok( 1, "Called on the Son" );
    super;
}

package main;

is( Son->foo, 42, "called the Son->Father->Grandfather" );
