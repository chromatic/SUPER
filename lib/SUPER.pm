package DB;

sub uplevel_args { my @foo = caller(2); return @DB::args }

package UNIVERSAL;

use strict;
use warnings;

use Scalar::Util 'blessed';

sub super
{
	return ( SUPER::find_parent( @_ ) )[0];
}

sub SUPER
{
	my $self             = $_[0];
	my $blessed          = blessed( $self );
	my $self_class       = $blessed ? $blessed : $self;
	my ($class, $method) = ( caller( 1 ) )[3] =~ /(.+)::(\w+)$/;
	my ($sub, $parent)   = SUPER::find_parent( $self_class, $method, $class );

	return unless $sub;
	goto &$sub;
}

package SUPER;

use strict;
use warnings;

our $VERSION = '1.11';
use base 'Exporter';

@SUPER::ISA    = qw(Exporter);
@SUPER::EXPORT = qw(super);

use Carp;
use Scalar::Util 'blessed';

sub find_parent
{
	my ($class, $method, $prune)   = @_;
	my $blessed                    = blessed( $class );
	$class                         = $blessed if $blessed;
	$prune                       ||= '';

	my $subref;

	no strict 'refs';

	for my $parent ( @{ $class . '::ISA' }, 'UNIVERSAL' )
	{
		return find_parent( $parent, $method ) if $parent eq $prune;
		return ( $subref, $parent ) if $subref = $parent->can($method);
	}
}

sub super()
{
	if (@_)
	{
		# Someone's trying to find SUPER's super. Blah.
		goto &UNIVERSAL::super;
	}

	@_ = DB::uplevel_args();

	carp 'You must call super() from a method call' unless $_[0];

	my $caller = ( caller(1) )[3];
	my $self   = caller();
	$caller    =~ s/.*:://;

	goto &{ $self->UNIVERSAL::super($caller) };
}

1;

=head1 NAME

SUPER - control superclass method dispatch

=head1 SYNOPSIS

Find the parent method that would run if this weren't here:

    sub my_method
    {
        my $self = shift;
        my $super = $self->super('my_method'); # Who's your daddy?

        if ($want_to_deal_with_this)
        {
            # ...
        }
        else
        {
            $super->($self, @_)
        }
    }

Or Ruby-style:

    sub my_method
    {
        my $self = shift;

        if ($want_to_deal_with_this)
        {
            # ...
        }
        else
        {
            super;
        }
    }

Or call the super method manually, with respect to inheritance, and passing
different arguments:

    sub my_method
    {
        my $self = shift;

        # parent handles args backwardly
        $self->SUPER( reverse @_ );
    }

=head1 DESCRIPTION

When subclassing a class, you occasionally want to dispatch control to the
superclass -- at least conditionally and temporarily. The Perl syntax for
calling your superclass is ugly and unwieldy:

    $self->SUPER::method(@_);

especially when compared to its Ruby equivalent:

    super;

It's even worse in that the normal Perl redispatch mechanism only dispatches to
the parent of the class containing the method I<at compile time>.  That doesn't work very well for mixins and roles.

This module provides nicer equivalents, along with the universal method
C<super> to determine a class' own superclass. This allows you to do things
such as:

    goto &{$_[0]->super('my_method')};

if you don't like wasting precious stack frames. (Because C<super> returns a
coderef, much like L<UNIVERSAL/can>, this doesn't break C<use strict 'refs'>.)

If you are using roles or mixins or otherwise pulling in methods from other
packages that need to dispatch to their super methods, or if you want to pass
different arguments to the super method, use the C<SUPER()> method:

    $self->SUPER( qw( other arguments here ) );

=head1 FUNCTIONS and METHODS

This module provides the following functions and methods:

=over

=item C<super()>

This function calls the super method of the currently-executing method, no
matter where the super method is in the hierarchy.

This takes no arguments; it passes the same arguments passed to the
currently-executing method.

The module exports this function by default.

=item C<find_parent( $class, $method, $prune )>

Attempts to find a parent implementation of C<$method> starting with C<$class>.
If you pass C<$prune>, it will not ignore the method found in that package, if
it exists there.

The module does not export this function by default.  Call it directly.

=item C<SUPER()>

Calls the super method of the currently-executing method.  You I<can> pass
arguments.  This is a method.

=back

=head1 NOTES

Using C<super> doesn't let you pass alternate arguments to your superclass's
method. If you want to pass different arguments, use C<SUPER> instead.  D'oh.

This module does a small amount of Deep Magic to find the arguments of method
I<calling> C<super()> itself.  This may confuse tools such as C<Devel::Cover>.

=head1 AUTHOR

Created by Simon Cozens, C<simon@cpan.org>.

Maintained by chromatic, E<lt>chromatic at wgz dot orgE<gt> after version 1.01.

=head1 LICENSE

You may use and distribute this silly little module under the same terms as
Perl itself.
