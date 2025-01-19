package Music::Harmonica::TabsCreator::NoteToToneConverter;

use 5.036;
use strict;
use warnings;
use utf8;

use Readonly;

# This class converts written note (accepting various syntax for the notes) into
# tones (degrees) relative to the key of C4.

sub new ($class, %options) {
  my $self = bless {
    default_octave => $options{default_octave} // 5,
    key => $options{key} // 'C',
  }, $class;
  return $self;
}

# For now we assume that the key is C when entering the sheet music (when
# specifying octaves). It’s unclear what are the convention here for other keys.

Readonly my %NOTE_TO_TONE => (
  C => 0,
  Do => 0,
  D => 2,
  Ré => 2,
  E => 4,
  Mi => 4,
  F => 5,
  Fa => 5,
  G => 7,
  Sol => 7,
  A => 9,
  La => 9,
  B => 11,
  Si => 11,
  H => 11,
);

Readonly my %ACCIDENTAL_TO_ALTERATION => (
  '#' => 1,
  '+' => 1,
  'b' => -1,
  '-' => -1,
  '' => 0,
);

Readonly my %SIGNATURE_TO_KEY => (
  '' => 'C',
  b => 'F',
  bb => 'Bb',
  bbb => 'Eb',
  bbbb => 'Ab',
  bbbbb => 'Db',
  bbbbbb => 'Gb',
  bbbbbbb => 'Cb',
  '#' => 'G',
  '##' => 'D',
  '###' => 'A',
  '####' => 'E',
  '#####' => 'B',
  '######' => 'F#',
  '#######' => 'C#',
);

# Note that calls to convert can return nothing. The general pattern is to call
# that in a sub passed to a map call.

sub convert ($self, $symbol) {
  if ($symbol =~ m/^(<|>)$/) {
    $self->{default_octave} += $symbol eq '>' ? 1 : -1;
    return;
  }

  if ($symbol =~ m/^K(b+|#+)?$/) {
    if ($1 eq 'b') {
      $self->{key} = 'F';
    }
    return;
  }

  $symbol =~ m/^(do|ré|mi|fa|sol|la|si|[A-H])([#+b-]?)(-?\d+)?$/ or die "Invalid note: $_";
  my ($note, $accidental, $octave) = (ucfirst($1), $2, $3 // $self->{default_octave});
  my $base = 12 * ($octave - 4) + $NOTE_TO_TONE{$note};
  my $alteration = $ACCIDENTAL_TO_ALTERATION{$accidental // ''};
  return $base + $alteration;
}

1;
