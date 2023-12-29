#!/usr/bin/perl

use Test::More;

use lib '.';
use main;

is(main::part01("sample.txt"), 5, "Part 01 was computed correctly for sample.txt");
is(main::part01("input.txt"), 395, "Part 01 was computed correctly for input.txt");
is(main::part02("sample.txt"), 7, "Part 02 was computed correctly for sample.txt");
is(main::part02("input.txt"), 64714, "Part 02 was computed correctly for input.txt");

done_testing;
