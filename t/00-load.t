#!perl
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 3;

BEGIN {
    use_ok( 'Convert::CookingTimes' ) || print "Bail out!\n";
}

diag( "Testing Convert::CookingTimes $Convert::CookingTimes::VERSION, Perl $], $^X" );


my @items = (
    { name => "Chicken breasts", temp => 200, time => 30, },
    { name => "Oven chips",      temp => 220, time => 25, },
    { name => "Roast veg",       temp => 180, time => 16, },
);

my ($temp, $steps) = Convert::CookingTimes->adjust_times(@items);

is($temp, 200, "Suggested cooking temp averaged out correctly");

is_deeply($steps,
    [
        { adjusted_time => 30, name => "Chicken breasts", time_until_next => 2.5 },
        { adjusted_time => 27.5, name => "Oven chips", time_until_next => 13.1 },
        { adjusted_time => 14.4, name => "Roast veg" },
    ],
    "Got expected steps correctly",
);

done_testing;


