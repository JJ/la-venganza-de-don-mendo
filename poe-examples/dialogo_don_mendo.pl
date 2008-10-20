#!/usr/bin/perl

use strict;
use warnings;

use lib qw( ../lib lib );

use Don::Mendo;
use POE;

POE::Session->create(
    inline_states => {
	_start => \&a_escena,
	_stop => \&a_actuar,
    },
    );

sub a_escena {
    my ($kernel, $heap) = @_[KERNEL, HEAP];
    my $jornadas = Don::Mendo->new()->jornadas();
    $heap->{'jornadas'} = $jornadas;
}

sub a_actuar {
    my ($kernel, $heap) = @_[KERNEL, HEAP];
    my $jornadas = $heap->{'jornadas'};
    for my $j (@$jornadas) {
	print $j->tell();
    }
}

POE::Kernel->run();

