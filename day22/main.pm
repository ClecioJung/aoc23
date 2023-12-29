#!/usr/bin/perl

use strict;
use warnings;

package main;

sub parse_input {
    my $filename = shift;
    open my $file_handle, '<', $filename or die "Cannot open file $filename: $!";
    my @list_of_bricks;
    while (my $line = <$file_handle>) {
        chomp $line;
        my @line_parts = split('~', $line);
        my @initial_point = map { int($_) } split(',', $line_parts[0]);
        my @final_point = map { int($_) } split(',', $line_parts[1]);
        my $brick = {
            initial_point => \@initial_point,
            final_point => \@final_point,
        };
        push @list_of_bricks, $brick;
    }
    my @sorted_list_of_bricks = sort { $a->{initial_point}[2] <=> $b->{initial_point}[2] } @list_of_bricks;
    return @sorted_list_of_bricks;
}

sub is_intersecting_xy {
    my ($brick_a, $brick_b) = @_;
    my @initial_a = @{$brick_a->{initial_point}};
    my @final_a = @{$brick_a->{final_point}};
    my @initial_b = @{$brick_b->{initial_point}};
    my @final_b = @{$brick_b->{final_point}};
    if ($final_a[0] < $initial_b[0] || $final_a[1] < $initial_b[1] ||
        $final_b[0] < $initial_a[0] || $final_b[1] < $initial_a[1]) {
        return 0;
    }
    return 1;
}

sub distance_to_fall {
    my ($list_of_bricks, $brick_index) = @_;
    my $brick = @$list_of_bricks[$brick_index];
    my $height = 0;
    for my $i (0..$brick_index-1) {
        my $current_brick = @$list_of_bricks[$i];
        if (is_intersecting_xy($current_brick, $brick)) {
            if ($height < @{$current_brick->{final_point}}[2]) {
                $height = @{$current_brick->{final_point}}[2];
            }
        }
    }
    my $distance = @{$brick->{initial_point}}[2] - ($height+1);
    return $distance;
}

sub fall {
    my @list_of_bricks = @_;
    my $number_of_bricks = scalar @list_of_bricks;
    for my $i (0..$number_of_bricks-1) {
        my $distance = distance_to_fall(\@list_of_bricks, $i);
        if ($distance > 0) {
            my $initial_point = $list_of_bricks[$i]->{initial_point};
            my $final_point = $list_of_bricks[$i]->{final_point};
            @$initial_point[2] =  @$initial_point[2] - $distance;
            @$final_point[2] = @$final_point[2] - $distance;
        }
    }
    my @sorted_list_of_bricks = sort { $a->{initial_point}[2] <=> $b->{initial_point}[2] } @list_of_bricks;
    return @sorted_list_of_bricks;
}

sub get_supported_bricks_for_indice {
    my ($list_of_bricks, $brick_index) = @_;
    my $number_of_bricks = scalar @$list_of_bricks;
    my $brick = @$list_of_bricks[$brick_index];
    my @supported_indices;
    for my $i ($brick_index+1..$number_of_bricks-1) {
        my $current_brick = @$list_of_bricks[$i];
        if (@{$current_brick->{initial_point}}[2] > (@{$brick->{final_point}}[2]+1)) {
            last; # Break the loop
        } elsif (@{$current_brick->{initial_point}}[2] == (@{$brick->{final_point}}[2]+1)) {
            if (is_intersecting_xy($current_brick, $brick)) {
                push @supported_indices, $i;
            }
        }
    }
    return @supported_indices;
}

# Returns a hash map of the supported bricks for each brick indice
sub get_supported_bricks {
    my ($list_reference) = @_;
    my @list_of_bricks = @$list_reference;
    my $number_of_bricks = scalar @list_of_bricks;
    my %supported_bricks;
    for my $i (0..$number_of_bricks) {
        my @current_supported_bricks = get_supported_bricks_for_indice($list_reference, $i);
        $supported_bricks{$i} = \@current_supported_bricks;
    }
    return %supported_bricks;
}

sub get_count_supporting_bricks {
    my ($supported_reference) = @_;
    my %supported_bricks = %$supported_reference;
    my %count_supporting_bricks;
    for my $i (0..scalar %supported_bricks-1) {
        my @list_of_bricks = @{$supported_bricks{$i}};
        for my $j (@list_of_bricks) {
            $count_supporting_bricks{$j}++;
        }
    }
    return %count_supporting_bricks;
}

# Returns one array containing the indexes of unsafe bricks to disintegrate
sub get_unsafe_bricks {
    my ($supported_reference, $supporting_reference) = @_;
    my %supported_bricks = %$supported_reference;
    my %count_supporting_bricks = %$supporting_reference;
    my @unsafe_bricks;
    for my $i (0..scalar %supported_bricks-1) {
        my @list_of_bricks = @{$supported_bricks{$i}};
        for my $j (@list_of_bricks) {
            if ($count_supporting_bricks{$j} == 1) {
                push @unsafe_bricks, $i;
                last; # Beak the loop
            }
        }
    }
    return @unsafe_bricks;
}

sub number_of_safe_bricks {
    my ($list_of_bricks) = @_;
    my $number_of_bricks = scalar @$list_of_bricks;
    my %supported_bricks = get_supported_bricks($list_of_bricks);
    my %count_supporting_bricks = get_count_supporting_bricks(\%supported_bricks);
    my @unsafe_bricks = get_unsafe_bricks(\%supported_bricks, \%count_supporting_bricks);
    return $number_of_bricks - scalar @unsafe_bricks;
}

sub chain_reaction {
    my ($supported_reference, $supporting_reference, $index) = @_;
    my %supported_bricks = %$supported_reference;
    my %count_supporting_bricks = %$supporting_reference;
    my @queue_of_falling_bricks;
    my %count_bricks;
    my $falling_bricks = 0;
    push @queue_of_falling_bricks, $index;
    while (scalar @queue_of_falling_bricks > 0) {
        my $brick_index = shift @queue_of_falling_bricks;
        my @list_of_bricks = @{$supported_bricks{$brick_index}};
        for my $j (@list_of_bricks) {
            $count_bricks{$j}++;
            if ($count_bricks{$j} == $count_supporting_bricks{$j}) {
                push @queue_of_falling_bricks, $j;
                $falling_bricks++;
            }
        }
    }
    return $falling_bricks;
}

sub sum_of_falling_bricks {
    my ($list_reference) = @_;
    my @list_of_bricks = @$list_reference;
    my $number_of_bricks = scalar @list_of_bricks;
    my %supported_bricks = get_supported_bricks($list_reference);
    my %count_supporting_bricks = get_count_supporting_bricks(\%supported_bricks);
    my @unsafe_bricks = get_unsafe_bricks(\%supported_bricks, \%count_supporting_bricks);
    my $sum_of_falling_bricks = 0;
    for my $i (@unsafe_bricks) {
        my $falling_bricks = chain_reaction(\%supported_bricks, \%count_supporting_bricks, $i);
        $sum_of_falling_bricks += $falling_bricks;
    }
    return $sum_of_falling_bricks;
}

sub part01 {
    my $filename = shift;
    my @list_of_bricks = parse_input($filename);
    my @list_of_bricks_after_fall = fall(@list_of_bricks);
    return number_of_safe_bricks(\@list_of_bricks_after_fall);
}

sub part02 {
    my $filename = shift;
    my @list_of_bricks = parse_input($filename);
    my @list_of_bricks_after_fall = fall(@list_of_bricks);
    return sum_of_falling_bricks(\@list_of_bricks_after_fall);
}

sub main {
    print "Part 01: ", part01("input.txt"), "\n";
    print "Part 02: ", part02("input.txt"), "\n";
}

if (!caller) {
    main
}

1;
