===============================
FingerBank: DHCP fingerprinting
===============================

FingerBank - DHCP fingerprint / signature database

www.fingerbank.org

Introduction
============

Fingerbank is not an organ bank for nice fingers. Fingerbank is the official 
website for DHCP fingerprints.

A DHCP fingerprint is an almost unique identifier for a specific operating 
system or device type. Due to the broadcast and pervasive nature of DHCP, DHCP
fingerprinting is a very low-cost low-effort way to do passive system 
identification and inventory.

Thus, DHCP fingerprints are very useful for network sniffers, protocol 
analyzers or Network Access Control solutions.

How does it work?
=================

Whenever the DHCP client of the operating system issues a DHCP request, it 
asks for DHCP options (like DNS Server, WINS server, default gateway, etc.). 
The order in which the DHCP client asks for those options is relatively unique
and identifies the specific operating system version.

The fingerprint database 
========================

Latest version of the database file available at: 
http://github.com/inverse-inc/fingerbank

Check the following file:

    dhcp_fingerprints.conf

Tools
=====

Over time tools that help processing the anonymous fingerprint submissions we
received will be developped.

* fingerprint-find-candidate-matches.pl

Finds the closest match of a given fingerprint. Example usage:

    $ tools/fingerprint-find-candidate-matches.pl ./dhcp_fingerprints.conf '1,3,6,15,28,12,7,9,42,48,49,26,44,45,46,47' 

License
=======

Copyright (C) 2008-2011 Inverse inc.

The FingerBank database is made available under the Open Database License. 
See LICENSE.odbl-10.txt for the full text or 
http://opendatacommons.org/licenses/odbl/1.0/

Any rights in individual contents of the database are licensed under the 
Database Contents License. See LICENSE.dbcl-10.txt for the full text or 
http://opendatacommons.org/licenses/dbcl/1.0/

The tools (under tools/) are covered under their own licenses. Refer to the
embedded documentation to find out which one it is.
