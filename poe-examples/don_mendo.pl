#!/usr/bin/perl

use strict;
use warnings;

use lib qw( lib ../lib );

use Don::Mendo;

my $jornadas = Don::Mendo->new()->jornadas();
for my $j (@$jornadas) {
    print $j->tell();
}

