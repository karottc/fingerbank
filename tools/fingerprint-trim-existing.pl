#!/usr/bin/perl
=head1 NAME

fingerprint-trim-existing.pl

=head1 DESCRIPTION

Output the unknown fingerprints from a given file.

=cut
use 5.10.1;

use strict;
use warnings;

use autodie;
use Config::IniFiles;
use IO::File;

our %dhcp_fingerprints;
# TODO expose behind cli flag
my $show_found = 0;

main(@ARGV);

=item load_fingerprint_db

Pre-load the fingerprint database tied hash into a global.

=cut
sub load_fingerprint_db {
    my ($dhcp_fingerprint_file) = @_;
    tie %dhcp_fingerprints, 'Config::IniFiles', ( -file => $dhcp_fingerprint_file  );
}

=item fingerprint_exists

Iterate over all fingerprints trying to match it.
Returns true value if it matched.

=cut
sub fingerprint_exists {
    my ($candidate_fingerprint) = @_;

    my $found = 0;
    foreach my $os ( tied(%dhcp_fingerprints)->GroupMembers("os") ) {
        if ( exists( $dhcp_fingerprints{$os}{"fingerprints"} ) ) {
            if ( ref( $dhcp_fingerprints{$os}{"fingerprints"} ) eq "ARRAY" ) {
                foreach my $dhcp_fingerprint ( @{ $dhcp_fingerprints{$os}{"fingerprints"} } ) {

                    if (fingerprint_matches($dhcp_fingerprint, $candidate_fingerprint)) {
                        $found = $dhcp_fingerprints{$os}{'description'};
                        last;
                    }

                }
            } else {
                foreach my $dhcp_fingerprint (split(/\n/, $dhcp_fingerprints{$os}{"fingerprints"})) {

                    if (fingerprint_matches($dhcp_fingerprint, $candidate_fingerprint)) {
                        $found = $dhcp_fingerprints{$os}{'description'};
                        last;
                    }

                }
            }
        }
    }
    return $found;
}

=item fingerprint_matches

Strictly matches fingerpints. 
Returns true or false value.

=cut
sub fingerprint_matches {
    my ($dhcp_fingerprint, $candidate_fingerprint) = @_;

    return 1 if ($dhcp_fingerprint =~ /^\Q$candidate_fingerprint\E$/);   
    return 0;
}

=item extract_fingerprint

Extracts the fingerprint only portion out of a line.
Line MUST begin with fingerprint.

=cut
sub extract_fingerprint {
    my ($input) = @_;

    my ($fingerprint) = $input =~ /^([\d,]+)/;
    return $fingerprint;
}

sub main {
    my ($fingerprint_db_file, $fingerprints_file) = @_;
    load_fingerprint_db($fingerprint_db_file);

    my $io = new IO::File( $fingerprints_file,'<', 'r' );
    die "Can't open file $fingerprints_file" if (!defined($io));

    print "The following fingerprints are not currently in fingerbank's database:\n";
    print "----------------------------------------------------------------------\n";
    while (defined(my $line = $io->getline)) {
         chomp($line);
         my $candidate_fp = extract_fingerprint($line);

         next if (!$candidate_fp);

         my $found = fingerprint_exists($candidate_fp);
         print $line . "\n" if (!$found);

         print "$line -> $found\n" if ($found && $show_found);
    }
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
