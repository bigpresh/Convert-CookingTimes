#!perl
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

use Convert::CookingTimes;
plan tests => 3;

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
        { adjusted_time => 30, name => "Chicken breasts", time_until_next => 2 },
        { adjusted_time => 28, name => "Oven chips", time_until_next => 14 },
        { adjusted_time => 14, name => "Roast veg" },
    ],
    "Got expected steps correctly",
);

my $instructions = Convert::CookingTimes->summarise_instructions(
    Convert::CookingTimes->adjust_times(@items)
);

my $expect_instructions = join "\n",
    "Warm oven up to 200 degrees.",
    "Cooking the whole meal will take 30 minutes.",
    "Add Chicken breasts and cook for 2 minutes",
    "Add Oven chips and cook for 14 minutes",
    "Add Roast veg and cook for 14 minutes";

is($instructions, $expect_instructions, "Text instructions as expected");

done_testing;


