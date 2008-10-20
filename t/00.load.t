use Test::More tests => 8; # -*-CPerl-*-

use lib qw( ../lib lib );

BEGIN {
use_ok( 'Don::Mendo' );
}

diag( "Testing Don::Mendo $Don::Mendo::VERSION" );

#Check instances
my $don_mendo = new Don::Mendo;
is( ref $don_mendo, "Don::Mendo", "New instances");
isnt( $don_mendo->text(), '', "Text");

#Check jornadas
is( scalar @{$don_mendo->jornadas()}, 4, "Parts" );
my $primera_jornada = $don_mendo->jornadas()->[0];
is ($primera_jornada->lines_for_character()->[0]->{'_personaje'}, 'NUÑO', "First line");
my $character = 'MAGDALENA';
is ($primera_jornada->lines_for_character($character)->[0]->{'_personaje'}, $character, "Character lines");

#Check lines
my $tercera_jornada = $don_mendo->jornadas()->[3];
my @lines_for_mendo = @{$tercera_jornada->lines_for_character('MENDO')};
like ($lines_for_mendo[$#lines_for_mendo]->say, qr/es don Mendo/, "Famous last words");
isnt( $tercera_jornada->tell(), '', "Full text");

#Check actors
my $actors = $tercera_jornada->actors();
is( $actors->{'MENDO'}->character(), 'MENDO', "Actors");




