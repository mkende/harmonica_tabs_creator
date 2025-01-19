package Music::Harmonica::TabsCreator;

use 5.036;
use strict;
use warnings;
use utf8;

use Exporter qw(import);
use List::Util qw(min max);
use Music::Harmonica::TabsCreator::NoteToToneConverter;
use Readonly;
use Scalar::Util qw(looks_like_number);

our $VERSION = '0.01';

our @EXPORT_OK = qw(sheet_to_tab get_tuning sheet_to_tab_rendered);

# Options to add:
# - print B as H (international convention), but probably not Bb which stays Bb.

Readonly my $TONES_PER_SCALE => 12;

Readonly my %tunings => (
  # Written in the key of C to match the default key used in the note_to_tone
  # function.
  richter_no_bend => {
    tags => [qw(diatonic 10-holes)],
    name => 'Richter-tuned no bend',
    # We arbitrarily keep only +3 and never use -2.
    # We might need to change that if we wanted to support chords.
    tab => [qw(  1  -1 2   3 -3  4 -4 5  -5 6  -6 7  -7 8  -8 9  -9 10 -10)],
    notes => [qw(C4 D4 E4 G4 B4 C5 D5 E5 F5 G5 A5 C6 B5 E6 D6 G6 F6 C7 A6)],
  },
  richter => {
    tags => [qw(diatonic 10-holes)],
    name => 'Richter-tuned with bending',
    # We arbitrarily keep only +3 and never use -2.
    tab => [
      qw(  1  -1 -1' 2  -2' -2" 3  -3 -3' -3" -3"' 4  -4 -4' 5  -5 6  -6 -6' 7  -7 8  8'  -8 9  9'  -9 10 10' 10" -10)
    ],
    notes => [
      qw(C4 D4 Db4 E4 Gb4 F4  G4 B4 Bb4 A4  Ab4  C5 D5 Db5 E5 F5 G5 A5 Ab5 C6 B5 E6 Eb6 D6 G6 Gb6 F6 C7 B6  Bb6 A6)
    ],
  },
);

# We can’t use qw() because of the # that triggers a warning.
Readonly my @keys_offset => split / /, q(C Db D Eb E F F# G Ab A Bb B);

sub sheet_to_tab ($sheet) {
  my $note_converter = Music::Harmonica::TabsCreator::NoteToToneConverter->new();
  my @tones = $note_converter->convert($sheet);

  my %all_matches;
  while (my ($k, $v) = each %tunings) {
    my @matches = match_notes_to_tuning(\@tones, $v);
    for my $m (@matches) {
      push @{$all_matches{$k}{$m->[1]}}, $m->[0];
    }
  }
  return %all_matches;
}

sub sheet_to_tab_rendered ($sheet) {
  my %tabs = sheet_to_tab($sheet);

  if (!%tabs) {
    return 'No tabs found';
  }

  my $out;

  for my $type (sort keys %tabs) {
    my %details = get_tuning($type);
    $out .= sprintf "For %s %s harmonicas:\n", join(' ', @{$details{tags}}), $details{name};
    for my $key (sort keys %{$tabs{$type}}) {
      $out .= "  In the key of ${key}:\n";
      for my $tab (@{$tabs{$type}{$key}}) {
        $out .= '    '.join(' ', map { m/^\v+$/ ? $_.'   ' : $_ } @{$tab})."\n";
      }
    }
  }

  return $out;
}

sub get_tuning ($key) {
  return %{$tunings{$key}}{qw(name tags)};
}

# Given all the tones (with C0 = 0) of a melody and the data of a given
# harmonica tuning, returns whether the melody can be played on this
# harmonica and, if yes, the octave shift to apply to the melody.
sub match_notes_to_tuning ($tones, $tuning) {
  my $note_converter = Music::Harmonica::TabsCreator::NoteToToneConverter->new();
  my @scale_tones = map { $note_converter->convert($_) } @{$tuning->{notes}};
  my ($scale_min, $scale_max) = (min(@scale_tones), max(@scale_tones));
  my @real_tones = grep { looks_like_number($_) } @{$tones};
  my ($tones_min, $tones_max) = (min(@real_tones), max(@real_tones));
  my %scale_tones = map { $scale_tones[$_] => $tuning->{tab}[$_] } 0 .. $#scale_tones;
  my ($o_min, $o_max) = ($scale_min - $tones_min, $scale_max - $tones_max);
  my @matches;
  for my $o ($o_min .. $o_max) {
    my @tab = tab_from_tones($tones, $o, %scale_tones);
    push @matches, [\@tab, $keys_offset[($TONES_PER_SCALE - $o) % $TONES_PER_SCALE]] if @tab;
  }
  return @matches;
}

sub tab_from_tones($tones, $offset, %scale_tones) {
  my @tab;
  for my $t (@{$tones}) {
    if (looks_like_number($t)) {
      return unless exists $scale_tones{$t + $offset};
      push @tab, $scale_tones{$t + $offset};
    } else {
      push @tab, $t;
    }
  }
  return @tab;
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Music::Harmonica::TabsCreator - Convert tabs to another format

=head1 SYNOPSIS

  use Music::Harmonica::TabsCreator qw(convert);

=cut
