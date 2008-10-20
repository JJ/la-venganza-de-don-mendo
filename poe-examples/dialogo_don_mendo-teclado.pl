#!/usr/bin/perl

use strict;
use warnings;

use Don::Mendo;

use POE;
use POE::Wheel::Readline;
use Term::ANSIColor;

my $primera_jornada = Don::Mendo->new()->jornadas()->[0];

my %actores =  %{$primera_jornada->actors()};
my @colores = ('yellow on_black', 'black on_white', 'white on_black', 'magenta on_white', 'green on_black', 'black on_yellow', 
	       'red on_blue', 'blue on_red', 'white on_blue', 'blue on_white', 'red on_yellow', 'yellow on_red' );
my $this_color;
for my $a (keys %actores) {
    POE::Session->create( inline_states => 
			  { _start => sub { my ($kernel,$heap) = @_[ KERNEL,HEAP];
					    $heap->{'first_line'} = $actores{$a};
					    $heap->{'all_lines'} = $primera_jornada->lines_for_character($a);
					    $heap->{'color'} = $colores[$this_color++];
					    $kernel->alias_set($a);
					    $heap->{readline_wheel} =
					      POE::Wheel::ReadLine->new( InputEvent => 'actua' );
					  },
			    espera => sub { 
			      my ($heap, $next) = @_[HEAP, ARG0];
			      $heap->{readline_wheel}->get("Dale a enter: ");			      
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

