#!/usr/bin/perl
=head1 NAME

fingerbank-dhcp-most-matches.pl 

=head1 DESCRIPTION

Find what fingerprint matches the most a given DHCP fingerprint.
Supports several strategies to do so and adding new ones should be relatively easy.

=cut
use 5.10.1;

use strict;
use warnings;

use autodie;
use Config::IniFiles;

our %dhcp_fingerprints;
our @find_closest_of;

main(@ARGV);

=item process_fingerprints

Iterate over all fingerprints calling per_fingerprint_callback()

=cut
sub process_fingerprints {
    my ($dhcp_fingerprint_file, $tests) = @_;
    my $results = {};
    tie %dhcp_fingerprints, 'Config::IniFiles', ( -file => $dhcp_fingerprint_file  );

    foreach my $os ( tied(%dhcp_fingerprints)->GroupMembers("os") ) {
        if ( exists( $dhcp_fingerprints{$os}{"fingerprints"} ) ) {
            if ( ref( $dhcp_fingerprints{$os}{"fingerprints"} ) eq "ARRAY" ) {
                foreach my $dhcp_fingerprint ( @{ $dhcp_fingerprints{$os}{"fingerprints"} } ) {
                    per_fingerprint_callback($results, $dhcp_fingerprint, $os, $tests);
                }
            } else {
                foreach my $dhcp_fingerprint (split(/\n/, $dhcp_fingerprints{$os}{"fingerprints"})) {
                    per_fingerprint_callback($results, $dhcp_fingerprint, $os, $tests);
                }
            }
        }
    }
    return $results;
}

sub show_results {
   my ($results, $tests) = @_;

   foreach my $test (keys %$tests) {
       # grab a couple of the best results according to test's result function
       my @candidate_fingerprints = &{ $tests->{$test}->{'result'} }($results, $test);

       print "\nTest: $test results\n";
       foreach my $fp (@candidate_fingerprints) {
           my $os = $results->{$fp}->{os};
           my $result = $results->{$fp}->{$test};
           print "$fp: $os ($dhcp_fingerprints{$os}{description}) as candidate match with result: $result\n";
       }
   }
}

=item per_fingerprint_callback

results is modified in this subroutine

=cut
sub per_fingerprint_callback {
    my ($results, $fp, $os, $tests) = @_;

    $results->{$fp}->{'os'} = $os;

    my @fp = split(',', $fp);
    foreach my $test (keys %$tests) {
        $results->{$fp}->{$test} = &{ $tests->{$test}->{'process'} }(@fp);
    }
}

sub processing_finished_callback {
    my ($results) = @_;
}

# XXX implement this one too
sub perfect_match {

}

sub count_identical_matches {
    my (@fp) = @_;
    my %count;
    map $count{$_}++ , @find_closest_of, @fp;
    return scalar grep $count{$_} > 1, @find_closest_of;
}

sub longuest_identical_sequence {
    my (@fp) = @_;
}

sub sort_by_largest_top5 {
    my ($results, $test_name) = @_;

    # sorting fingerprints based on test result stored in result hash
    my @sorted = sort { $results->{$b}->{$test_name} <=> $results->{$a}->{$test_name} } keys %$results;

    # return best 5 entries
    return @sorted[0 .. 5];
}


sub main {
    my ($fingerprint_database, $new_fingerprint) = @_;
    @find_closest_of = split(',', $new_fingerprint);

    my $tests = {
        'count_identical_matches' => {
            'description' => 'Outputs the fingerprint with the most individual requested options matching',
            'process' => \&count_identical_matches,
            'result' => \&sort_by_largest_top5,
        },
    };

    my $results = process_fingerprints(
        $fingerprint_database, $tests
    );

    print "Today's candidate is: $new_fingerprint\n";
    show_results($results, $tests);
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
