#!/usr/bin/perl

use lib '..';
use config;
use strict;

my %config = config::ReadConfig('test.cfg');

foreach my $key (sort keys %config)
{
    print "$key => $config{$key}\n";
}
