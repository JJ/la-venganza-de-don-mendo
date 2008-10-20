#!/usr/bin/perl

use strict;
use warnings;

use lib qw( lib ../lib );

use Don::Mendo;

use POE;

my $jornadas = Don::Mendo->new()->jornadas();
my $j_index;
for my $j (@$jornadas) {
    POE::Session->create( inline_states => 
			  { _start => sub { my ($kernel,$heap) = @_[ KERNEL,HEAP];
					    $heap->{'jornada'} = $j;
					    $kernel->alias_set("jornada".$j_index++);
			    },
			    actua => sub { my ($kernel,$heap, $session ) = @_[ KERNEL,HEAP,SESSION];
					   print $heap->{'jornada'}->tell(); 
					   my $alias = $kernel->alias_list( $session );
					   $alias =~ s/(\d)/$1+1/e;
					   $kernel->post( $alias, "actua" );
					 }
			  } );

  }

$poe_kernel->post("jornada1","actua");
$poe_kernel->run();

