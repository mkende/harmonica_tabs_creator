package Music::Harmonica::TabsCreator::NoteToToneConverter;

use 5.036;
use strict;
use warnings;
use utf8;

use List::Util qw(any);
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

Readonly my @FLAT_ORDER => qw(B E A D G C F);
Readonly my @SHARP_ORDER => qw(F C G D A E B);
Readonly my %KEY_TO_ALTERATION => (
  C => 0,
  F => -1,
  Bb => -2,
  Eb => -3,
  Ab => -4,
  Db => -5,
  Gb => -6,
  Cb => -7,
  G => 1,
  D => 2,
  A => 3,
  E => 4,
  B => 5,
  'F#' => 6,
  'C#' => 7,
);

sub note_to_tone ($note) {
  return $NOTE_TO_TONE{$note};
}

sub alteration_for_note ($self, $note) {
  my $alt = $KEY_TO_ALTERATION{$self->{key}};
  if ($alt > 0) {
    return (any { note_to_tone($_) eq note_to_tone($note) } @SHARP_ORDER[0..$alt-1]) ? 1 : 0;
  } elsif ($alt < 0) {
    return (any { note_to_tone($_) eq note_to_tone($note) } @FLAT_ORDER[0..abs($alt)-1]) ? -1 : 0;
  } else {
    return 0;
  }
}

# Note that calls to convert can return nothing. The general pattern is to call
# that in a sub passed to a map call.

sub convert ($self, $symbol) {
  if ($symbol =~ m/^(<|>)$/) {
    $self->{default_octave} += $symbol eq '>' ? 1 : -1;
    return;
  }

  if ($symbol =~ m/^K(b{0,7}|#{0,7})?$/) {
    $self->{key} = $SIGNATURE_TO_KEY{$1};
    return;
  }

  $symbol =~ m/^(do|Do|ré|Ré|mi|Mi|fa|Fa|sol|Sol|la|La|si|Si|[A-H])([#+b-]?)(-?\d+)?$/ or die "Invalid note: $_";
  my ($note, $accidental, $octave) = (ucfirst($1), $2, $3 // $self->{default_octave});
  my $base = 12 * ($octave - 4) + note_to_tone($note);
  my $alteration = $accidental ? $ACCIDENTAL_TO_ALTERATION{$accidental} : $self->alteration_for_note($note);
  return $base + $alteration;
}

1;
