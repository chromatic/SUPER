package DB;

sub uplevel_args { my @foo = caller(2); return @DB::args };

package UNIVERSAL;

sub super {
    my ($class, $method) = @_;

    if (ref $class) { $class = ref $class; }
    my $x;
    for (@{$class."::ISA"}, "UNIVERSAL") {
        return $x if $x = $_->can($method);
    }
}

package SUPER ;
use strict;
use warnings;
our $VERSION = "1.0";
require Exporter;
@SUPER::ISA=qw(Exporter); @SUPER::EXPORT = qw(super);
use Carp;

sub super() { 
    if (@_) {
        # Someone's trying to find SUPER's super. Blah.
        goto &UNIVERSAL::super;
    }
    @_ = DB::uplevel_args();
    my $self = $_[0];
    if (!$self) { carp "super must be called from a method call" }
    my $caller= (caller(1))[3];
    $caller =~ s/.*:://;
    goto &{$self->UNIVERSAL::super($caller)};
}

1;

=head1 NAME

SUPER - Control superclass method despatch

=head1 SYNOPSIS

    sub my_method {
        my $self = shift;
        my $super = $self->super("my_method"); # Who's your daddy?

        if ($want_to_deal_with_this) { ... }
        else { $super->($self, @_) }
    }

Or just, Ruby-style:

    sub my_method {
        my $self = shift;

        if ($want_to_deal_with_this) { ... }
        else { super }
    }

=head1 DESCRIPTION

When subclassing a class, you occasionally want to despatch control to
the superclass - at least conditionally and temporarily. The Perl syntax
for calling your superclass is ugly and unwieldy:
    
    $self->SUPER::method(@_);

Especially when compared with its Ruby equivalent:

    super;

This module provides that equivalent, along with the universal method
C<super> to determine one's own superclass. This allows you do to things
like

    goto &{$_[0]->super("my_method")};

if you don't like wasting precious stack frames. (And since C<super>
returns a coderef, much like L<UNIVERSAL/can>, this doesn't break 
C<use strict 'refs'>.)

=head1 NOTES

It has been pointed out that using C<super> doesn't let you pass
alternate arguments to your superclass's method. If you want to pass
different arguments, well, don't use C<super> then. D'oh.

This module does a small amount of Deep Magic to find out what arguments
the method B<calling> C<super> itself had, and this may confuse things
like C<Devel::Cover>.

=head1 AUTHOR

Simon Cozens, C<simon@cpan.org>

=head1 LICENSE

This silly little module may be distributed under the same terms as Perl
itself.
