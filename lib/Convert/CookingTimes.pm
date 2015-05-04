package Convert::CookingTimes;

use 5.006;
use strict;
use warnings FATAL => 'all';

use List::Util;
use Math::Round;

our $VERSION = '0.01';

=head1 NAME

Convert::CookingTimes - work out cooking times adjusted for temperature


=head1 SYNOPSIS

Given a set of item names, temperatures and durations, works out the average
temperature and adjusts the times to suit that temperature, then returns a list
of suggested timings.


    my ($temperature, @steps) = @steps = Convert::CookingTimes->adjust_times(
        { name => 'Chicken breasts', temp => 200, time => 20 },
        { name => 'Chips', temp => 220, time = 25 },
    );
    say "Warm oven up to $temperature degrees first.";
    for my $step (@steps) {
        say "Put $step->{name} in the oven, and wait for $step->{time_to_next}";
    }

    # You can also feed the result of adjust_times to summarise_instructions to
    # provide a simple set of instructions, e.g.:
    say Convert::CookingTimes->summarise_instructions(
        Convert::CookingTimes->adjust_times(\@items)
    );


=head1 DESCRIPTION

Often find yourself cooking a variety of things, the cooking instructions for
each requiring a different temperature and time?

This module attempts to work out the appropriate oven temperature as an average
of all the items, and adjusts their cooking times based on that temperature -
so if they're going to be at a higher temperature the time is reduced and vice
versa.

Results may vary - providing items with a wide variation of temperatures could
result in some foods being cooked at sub-optimal temperatures, and obviously you
need to sanity-check the results, and be particularly careful to check that meat
and poultry has reached a safe internal temperature etc.  This is an algorhythm,
not a cook!


=head1 SUBROUTINES/METHODS

=head2 adjust_times

Takes a list or arrayref of hashrefs, each of which contains details of an 
item being cooked, with the keys:

=over

=item name

The name of the item

=item temp

The temperature the item's cooking instructions call for, in degrees Celcius

=item time

The cooking time the item's cooking instructions call for, in minutes

=back

Returns a suggested oven temperature, and an arrayref of cooking times adjusted
to suit that temperature.

=cut

sub adjust_times {
    my $class = shift;
    my @items = ref $_[0] eq 'ARRAY' ? @{$_[0]} : @_;

    # First off: pick our desired temperature, as an average of all the
    # temperatures, rounded to the nearest 10
    my $desired_temp = Math::Round::nearest_ceil(10, 
        List::Util::sum(map { $_->{temp} } @items) / scalar @items
    );

    # Now, for each item, work out its adjusted time and add to the output list:
    my @times;
    for my $item (@items) {
        push @times, {
            name => $item->{name},
            adjusted_time => ($item->{temp} * $item->{time}) / $desired_temp,
        };
    }

    # Finally, return the items, sorted by longest cooking duration first,
    # with the time until the next item should be started included
    my @output;
    @times = sort { $b->{adjusted_time} <=> $a->{adjusted_time} } @times;
    while (my $item = shift @times) {
        if (my $next_item = $times[0]) {
            $item->{time_until_next} = $item->{adjusted_time} - $next_item->{adjusted_time};
        }
        push @output, $item;
    }
    
    return $desired_temp, \@output;    
}


=item summarise_instructions

Given the results of adjust_times, produce a list of instructions.

For instance:

  - Warm oven up to 200 degrees
  - Add Chicken Breasts, cook for 5 minutes
  - Add Oven Chips, cook for 20 minutes

Returns a list of instruction steps if called in list context, or that list
joined with newlines if called in scalar context.

=cut

sub summarise_instructions {
    my $self = shift;
    my $temp = shift;
    my @items = ref $_[0] eq 'ARRAY' ? @$_[0] : @_;
    
    my $total_mins = List::Util::sum( map { $_->{adjusted_time} } @items );
    my @instructions;
    push @instructions, "Warm oven up to $temp degrees.";
    push @instructions, "Cooking the whole meal will take $total_mins minutes.";

    for my $item (@items) {
        push @instructions, sprintf "Add %s and cook for %d minutes",
            @$item{qw(name time_until_next)};
    }
    
    return wantarray ? @instructions : join "\n", @instructions;
}



=head1 AUTHOR

David Precious, C<< <davidp at preshweb.co.uk> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-convert-cookingtimes at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Convert-CookingTimes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Convert::CookingTimes


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Convert-CookingTimes>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Convert-CookingTimes>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Convert-CookingTimes>

=item * Search CPAN

L<http://search.cpan.org/dist/Convert-CookingTimes/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 David Precious.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Convert::CookingTimes
