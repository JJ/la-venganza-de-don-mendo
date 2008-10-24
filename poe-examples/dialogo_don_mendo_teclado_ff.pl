#!/usr/bin/perl

use strict;
use warnings;

use lib qw( lib ../lib );

use Don::Mendo;

use POE qw( Wheel::ReadLine Filter::Grep );
use Term::ANSIColor;

my $ultima_jornada = Don::Mendo->new()->jornadas()->[3];

my %actores =  %{$ultima_jornada->actors()};
my @colores = ('yellow on_black', 'black on_white', 'white on_black', 'magenta on_white', 'green on_black', 'black on_yellow', 
	       'red on_blue', 'blue on_red', 'white on_blue', 'blue on_white', 'red on_yellow', 'yellow on_red' );
my $this_color;

my $regexp_actores = "(". join( "|", keys %actores ). ")";

for my $a (keys %actores) {
    POE::Session->create( inline_states => 
			  { _start => sub { my ($kernel,$heap) = @_[ KERNEL,HEAP];
					    $heap->{'first_line'} = $actores{$a};
					    $heap->{'all_lines'} = $ultima_jornada->lines_for_character($a);
					    $heap->{'color'} = $colores[$this_color++ % @colores ];
					    $kernel->alias_set($a);
					    $heap->{readline_wheel} =
					      POE::Wheel::ReadLine->new( InputEvent => 'selecciona' );
					  },
			    espera => sub { 
			      my ($heap) = $_[HEAP];
			      $heap->{readline_wheel}->get("Siguiente actor: ");
			    },

			    selecciona => sub {
			      my ($kernel, $heap, $actor_line ) = @_[KERNEL, HEAP, ARG0];
			      return if uc($actor_line) eq 'MUTIS';
			      if ( $actor_line ) {
				my ($quien) =  ($actor_line =~ /$regexp_actores/i);
				$kernel->post($quien, 'actua' );
			      } else {
				$kernel->yield('actua');
			      }
			    },

			    actua => sub { my ($kernel,$heap ) = @_[ KERNEL,HEAP];
					   my $this_line = shift @{$heap->{'all_lines'}};
					   my $this_color = $heap->{'color'};
					   print "* ", colored( $this_line->character(), "bold $this_color"), 
					     " : ", colored( $this_line->say(), $this_color), "\n--\n";
					   $kernel->post( $this_line->followed_by(), "espera" );
					 }
			  } );

  }

my $first_line = $ultima_jornada->start();
$poe_kernel->post($first_line->character(),"actua");
$poe_kernel->run();

