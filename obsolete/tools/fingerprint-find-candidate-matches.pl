#!/usr/bin/perl
=head1 NAME

fingerbank-dhcp-most-matches.pl 

=head1 DESCRIPTION

Find what fingerprint matches the most a given DHCP fingerprint.
Supports several strategies to do so and adding new ones should be relatively easy.

=cut
use 5.10.1;

use strict;
#use warnings;

use autodie;
use Algorithm::Diff qw(LCS);
use Config::IniFiles;
use Data::Dumper;
$Data::Dumper::Indent = 0; # don't indent
$Data::Dumper::Varname = "result"; # set variable name
use String::LCSS;

our %dhcp_fingerprints;
our $fingerprint_to_match;
our @fingerprint_to_match; # splitted on ,

main(@ARGV);

=item process_fingerprints

Iterate over all fingerprints calling per_fingerprint_callback()

=cut
sub process_fingerprints {
    my ($dhcp_fingerprint_file, $tests) = @_;
    my $results_ref = {};
    tie %dhcp_fingerprints, 'Config::IniFiles', ( -file => $dhcp_fingerprint_file  );

    foreach my $os ( tied(%dhcp_fingerprints)->GroupMembers("os") ) {
        if ( exists( $dhcp_fingerprints{$os}{"fingerprints"} ) ) {
            if ( ref( $dhcp_fingerprints{$os}{"fingerprints"} ) eq "ARRAY" ) {
                foreach my $dhcp_fingerprint ( @{ $dhcp_fingerprints{$os}{"fingerprints"} } ) {
                    per_fingerprint_callback($results_ref, $dhcp_fingerprint, $os, $tests);
                }
            } else {
                foreach my $dhcp_fingerprint (split(/\n/, $dhcp_fingerprints{$os}{"fingerprints"})) {
                    per_fingerprint_callback($results_ref, $dhcp_fingerprint, $os, $tests);
                }
            }
        }
    }
    return $results_ref;
}

sub show_results {
   my ($results_ref, $tests) = @_;

   foreach my $test (keys %$tests) {
       # grab a couple of the best results according to test's result function
       my @candidate_fingerprints = &{ $tests->{$test}->{'result'} }($results_ref, $test);

       print "\nTest: $test results\n";
       print "Description: $tests->{$test}->{description}\n";
       unless (@candidate_fingerprints) { print "No results...\n"; }

       foreach my $fp (@candidate_fingerprints) {
           my $os = $results_ref->{$fp}->{os};
           my $result = $results_ref->{$fp}->{$test};
           print "$dhcp_fingerprints{$os}{description} ($os): $fp\n" . Dumper($result) . "\n";
       }
   }
}

=item per_fingerprint_callback

This callback calls every process hook sending both the fingerprint string and a splitted fingerprint array.
results_ref is modified in this subroutine

=cut
sub per_fingerprint_callback {
    my ($results_ref, $fp, $os, $tests) = @_;

    $results_ref->{$fp}->{'os'} = $os;

    my @fp = split(',', $fp);
    foreach my $test (keys %$tests) {
        $results_ref->{$fp}->{$test} = &{ $tests->{$test}->{'process'} }($fp, @fp);
    }
}

=item perfect_match

Returns 1 if given fingerprint perfectly matches $fingerprint_to_match. 
0 otherwise.

=cut
sub perfect_match {
    my ($fp, @fp) = @_;

    return 1 if ($fp =~ /^$fingerprint_to_match$/);   
    return 0;
}

=item count_identical_matches

Returns number of options id that matched between given fingerprint and fingerprint to match.
Order of options is not relevant.

=cut
sub count_identical_matches {
    my ($fp, @fp) = @_;
    my %count;
    map $count{$_}++ , @fingerprint_to_match, @fp;
    return scalar grep $count{$_} > 1, @fingerprint_to_match;
}

=item longuest_identical_sequence

Find longuest matching sequence between the two fingerprints using Algorithm::Diff's LCS algorithm.

=cut
sub longuest_identical_sequence {
    my ($fp, @fp) = @_;

    return String::LCSS::lcss( $fingerprint_to_match, $fp );
}

=item algorithm_diff

Find longuest matching sequence between the two fingerprints using Algorithm::Diff's LCS algorithm. 
This algorithm tolerates some differences.

=cut
sub algorithm_diff {
    my ($fp, @fp) = @_;

    return LCS( \@fingerprint_to_match, \@fp );
}

=item sort_by_largest_int_top5

Sort the results as integers under $test_name and return the five entries with the largest result.

=cut
sub sort_by_largest_int_top5 {
    my ($results_ref, $test_name) = @_;

    # sorting fingerprints based on test result stored in result hash
    my @sorted = sort { $results_ref->{$b}->{$test_name} <=> $results_ref->{$a}->{$test_name} } keys %$results_ref;

    # return best 5 entries
    return @sorted[0 .. 5];
}

=item sort_by_largest_str_top5

Sort the results by string size under $test_name and return the five entries with the largest strings.

=cut
sub sort_by_largest_str_top5 {
    my ($results_ref, $test_name) = @_;

    # sorting fingerprints based on test result stored in result hash
    # test result is a string and we are sorting by largest string
    my @sorted = 
        sort { length($results_ref->{$b}->{$test_name}) <=> length($results_ref->{$a}->{$test_name}) } 
        keys %$results_ref
    ;

    # return best 5 entries
    return @sorted[0 .. 5];
}

=item sort_by_largest_arrayref_top5

Sort the results by largest arrayref under $test_name and return the five entries with the largest result.

=cut
sub sort_by_largest_arrayref_top5 {
    my ($results_ref, $test_name) = @_;

    # sorting fingerprints based on the length of the result arrayref stored in result hash
    my @sorted = 
        sort { @{$results_ref->{$b}->{$test_name}} <=> @{$results_ref->{$a}->{$test_name}} } 
        keys %$results_ref
    ;

    # return best 5 entries
    return @sorted[0 .. 5];
}

=item return_all_true_values

Everything that has a true value result under $test_name will be returned.

=cut
sub return_all_true_values {
    my ($results_ref, $test_name) = @_;

    my @true_values;
    foreach my $fp (keys %$results_ref) {
        push @true_values, $fp if ($results_ref->{$fp}->{$test_name});
    }

    return @true_values;
}

sub main {
    my ($fingerprint_database, $fp_from_cli) = @_;
    $fingerprint_to_match = $fp_from_cli;
    @fingerprint_to_match = split(',', $fingerprint_to_match);

    # TODO turn into an array so that I can specify in what order I want to see the tests' output
    my $tests = {
        'count_identical_matches' => {
            'description' => 'Outputs the fingerprint with the most individual requested options matching',
            'process' => \&count_identical_matches,
            'result' => \&sort_by_largest_int_top5,
        },
        'perfect_match' => {
            'description' => 'Fingerprint perfectly matches with an existing fingerprint',
            'process' => \&perfect_match,
            'result' => \&return_all_true_values,
        },
        'algorithm_diff' => {
            'description' => 'Fingerprints that shares a lot of the same sequences with provided fingerprint',
            'process' => \&algorithm_diff,
            'result' => \&sort_by_largest_arrayref_top5,
        },
        'longuest_common_substring' => {
            'description' => 'Fingerprints that shares the longuest sequence with provided fingerprint',
            'process' => \&longuest_identical_sequence,
            'result' => \&sort_by_largest_str_top5,
        },
    };

    my $results_ref = process_fingerprints(
        $fingerprint_database, $tests
    );

    print "Today's candidate is: $fingerprint_to_match\n";
    show_results($results_ref, $tests);
}

=head1 AUTHOR

Olivier Bilodeau <obilodeau@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2011 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set tabstop=4:
# vim: set backspace=indent,eol,start:
