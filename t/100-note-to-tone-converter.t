use strict;
use warnings;
use Test2::V0;

use Music::Harmonica::TabsCreator::NoteToToneConverter;

my $converter = Music::Harmonica::TabsCreator::NoteToToneConverter->new;

is($converter->convert('C4'), 0);
is($converter->convert('C5'), 12);
is($converter->convert('C6'), 24);
is($converter->convert('C3'), -12);
is($converter->convert('A4'), 9);

is($converter->convert('Cb4'), -1);
is($converter->convert('C#4'), 1);

sub convert {
  my $converter = Music::Harmonica::TabsCreator::NoteToToneConverter->new;
  return map { $converter->convert($_) } split /\s+/, @_[0];
}

is ([convert('C > C < < A')], [12, 24, 9]);

done_testing;
