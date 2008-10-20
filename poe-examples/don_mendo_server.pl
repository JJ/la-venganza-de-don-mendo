#!/usr/bin/perl

# Create CGI requests from HTTP::Requests, specifically the sort of
# requests that come from POE::Component::Server::HTTP.

use warnings;
use strict;
use POE;
use POE::Component::Server::HTTP;
use CGI qw (:standard *ul);
use Data::Dumper;

# Start an HTTP server.  Run it until it's done, typically forever,
# and then exit the program.
use lib qw( lib ../lib );
use Don::Mendo;

use POE qw( Wheel::ReadLine Filter::Grep );

my @jornadas = @{Don::Mendo->new()->jornadas()};
my %actores;
for my $j (@jornadas ) {
    %actores = ( %actores, %{$j->actors()});
}
my @actores_nombres = sort keys %actores;

POE::Component::Server::HTTP->new(
    Port           => 7500,
    ContentHandler => {
        '/'      => \&root_handler,
        '/get/' => \&post_handler,
      }
);

POE::Kernel->run();
exit 0;

# Handle root-level requests.  Populate the HTTP response with a CGI
# form.

sub root_handler {
    my ( $request, $response ) = @_;

    $response->code(RC_OK);
    $response->content(
        start_html(-head=>meta({-http_equiv => 'Content-Type',
				-content    => 'text/html; charset=utf-8'}), 
		   "Don Mendo: Diálogos") . 
		   h1( "Diálogos Don Mendo" ).
          start_form(
            -method => "GET",
            -action => "/get/"
          ) .
          "Jornada: " . popup_menu( -name => 'jornada',
				    -values => [0..$#jornadas] ).
          "Personaje: " . 
          popup_menu(
            -name   => "personaje",
            -values => \@actores_nombres,
	) . br() .
	submit( "Enviar" ) .
	end_form() .
	end_html()
	);

    return RC_OK;
}

# Handle simple CGI parameters.
#
# This code was contributed by Andrew Chen.  It handles GET and POST,
# but it does not handle %ENV-based CGI things.  It does not handle
# cookies, for instance.  Neither does it handle file uploads.

sub post_handler {
    my ( $request, $response ) = @_;

    # This code creates a CGI query.
    my $q;
    $request->uri() =~ /\?(.+$)/;
    if ( defined($1) ) {
	$q = new CGI($1);
    }
    else {
	$q = new CGI;
    }

    # The rest of this handler displays the values encapsulated by the
    # object.
    $response->code(RC_OK);
    print Dumper( $q );
    my $personaje = $q->param('personaje');
    my $jornada = $q->param('jornada');
    print "$personaje, $jornada\n";
    my $content = start_html(-head=>meta({-http_equiv => 'Content-Type',
				-content    => 'text/html; charset=utf-8'}),
			     "Diálogos de $personaje en la jornada $jornada ").
	h1("Diálogos de $personaje en la jornada $jornada");
    my $esta_jornada = $jornadas[$jornada];
    my $lines = $esta_jornada->lines_for_character( $personaje );
    $content .= start_ul();
    for my $l ( @$lines ) {
	$content .= li($l->say());
    }
    $content.= end_ul().end_html();
    $response->content($content);
#    print $content;
    return RC_OK;
}
