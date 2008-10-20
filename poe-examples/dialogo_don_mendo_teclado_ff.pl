#!/usr/bin/perl

use strict;
use warnings;

use Don::Mendo;

use POE qw( Wheel::Readline Filter::Grep );

use Term::ANSIColor;

my $primera_jornada = Don::Mendo->new()->jornadas()->[0];

my %actores =  %{$primera_jornada->actors()};
my @colores = ('yellow on_black', 'black on_white', 'white on_black', 'magenta on_white', 'green on_black', 'black on_yellow', 
	       'red on_blue', 'blue on_red', 'white on_blue', 'blue on_white', 'red on_yellow', 'yellow on_red' );
my $this_color;

my $regexp_actores = "(". join( "|", keys %actores ). ")";
my $actor_filter = POE::Filter::Grep->new(
					  Put => sub { 1 },
					  Get => sub {
					    my $input = shift;
					    return $input =~ /$regexp_actores/i;
					  },
        );
for my $a (keys %actores) {
    POE::Session->create( inline_states => 
			  { _start => sub { my ($kernel,$heap) = @_[ KERNEL,HEAP];
					    $heap->{'first_line'} = $actores{$a};
					    $heap->{'all_lines'} = $primera_jornada->lines_for_character($a);
					    $heap->{'color'} = $colores[$this_color++];
					    $kernel->alias_set($a);
					    $heap->{readline_wheel} =
					      POE::Wheel::ReadLine->new( InputEvent => 'selecciona',
									 Filter => $actor_filter );
					  },
			    espera => sub { 
			      my ($heap) = @_[HEAP];
			      $heap->{readline_wheel}->get("Siguiente actor: ");			      
			    }

			    selecciona => sub {
			      my ($kernel, $heap, $actor_line ) = @_[KERNEL, HEAP, $ARG0];
			      my ($quien) =  ($actor_line =~ /$regexp_actores/i);
			      $kernel->post($quien, 'actua' );
			    }

			    actua => sub { my ($kernel,$heap, $session ) = @_[ KERNEL,HEAP,SESSION];
					   my $this_line = shift @{$heap->{'all_lines'}};
					   my $this_color = $colores[$heap->{'color'}];
					   print "* ", colored( $this_line->character(), "bold $color"), 
					     " : ", colored( $this_line->say(), $color), "\n--\n";
					   $kernel->post( $this_line->followed_by(), "espera" );
					 }
			  } );

  }

my $first_line = $primera_jornada->start();
$poe_kernel->post($first_line->character(),"actua");
$poe_kernel->run();

