use strict;
use warnings;
use Test2::V0;

use Music::Harmonica::TabsCreator 'tune_to_tab';

is({ tune_to_tab('CDEFGAB') }->{richter}, { C => [[4, -4, 5, -5, 6, -6, -7]] });
is({ tune_to_tab('B>DbEbEGbAbBb') }->{richter}, { B => [[4, -4, 5, -5, 6, -6, -7]] });

# We test that we’re using 3 in the output and not -2.
is({ tune_to_tab("CEGC'''") }->{richter}, { C => [[1, 2, 3, 10]] });

done_testing;
