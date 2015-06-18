#!/usr/bin/perl

use strict;
use CGI;
use Convert::CookingTimes;

my $cgi = CGI->new;
print $cgi->header;
print <<HEADER;
<html><head><title>Cooking Times calculator</title></head>
<body>
<h1>Cooking Times calculator</h1>
HEADER

my @items;

for my $num (1..10) {
    if (my $name = $cgi->param("name$num")) {
        push @items, {
            name => $name,
            time => $cgi->param("time$num"),
            temp => $cgi->param("temp$num"),
        };
    }
}

if (@items) {
    print "<h2>Adjusted times and temperatures calculated</h2>";
    my $instructions = Convert::CookingTimes->summarise_instructions(
        Convert::CookingTimes->adjust_times(@items)
    );
    print "<pre>$instructions</pre>";
}


print <<FORMSTART;
<form method="post">
<table border="1">
<tr><th>Name</th><th>Time (mins)</th><th>Temp (C)</th></tr>
FORMSTART

for my $num (1..10) {
    print <<ROW;
<tr>
<td><input type="text" name="name$num"></td>
<td><input type="number" name="time$num"></td>
<td><input type="number" name="temp$num"></td>
</tr>
ROW
}

print <<FORMEND;
</table>
<input type="submit" name="calculate" value="Calculate times">
</form>
FORMEND
