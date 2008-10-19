use Test::More tests => 5; # -*-CPerl-*-

use lib qw( ../lib lib );

BEGIN {
use_ok( 'Don::Mendo' );
}

diag( "Testing Don::Mendo $Don::Mendo::VERSION" );
my $don_mendo = new Don::Mendo;
is( ref $don_mendo, "Don::Mendo", "New instances");
isnt( $don_mendo->text(), '', "Text");
is( scalar @{$don_mendo->jornadas()}, 4, "Parts" );
my $primera_jornada = $don_mendo->jornadas()->[0];
is ($primera_jornada->lines()->[0]->{'_personaje'}, 'NUÑO', "First line");


