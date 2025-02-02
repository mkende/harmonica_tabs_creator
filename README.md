# Harmonica Tabs Creator

A program to create harmonica tabs from a textual representation of a tune. It
supports multiple types of harmonica and tuning and will automatically try all
possible transpositions for the tune.

**Try it out at https://harmonica-tabs-creator.com!**

## Installation

To install `harmonica-tabs-creator` you need Perl (which is already installed on
most Linux distributions) and you need the `cpanm` Perl package manager. If
needed, you can install them with the following commands:

```shell
# On Debian, Ubuntu, Mint, etc.
sudo apt-get install perl cpanminus

# On Red Hat, Fedora, CentOS, etc.
sudo yum install perl perl-App-cpanminus
```

Then run the following to install `pmarkdown`:

```shell
sudo cpanm Music::Harmonica::TabsCreator -n -L /usr/local --man-pages --install-args 'DESTINSTALLBIN=/usr/local/bin'
```

## Tune syntax

### Notes

Notes are represented either with the standard notation (C, D, E, F, G, A, B)
or with the solfege notation (Do, Re, Mi, Fa, Sol, La, Si). The accidentals
are represented with the symbols `#` (sharp) and `b` (flat). The octave is
represented with a number for an absolute octave (the default one is 5) or
with the symbols `'` (one octave higher) and `,` (one octave lower).

The current default octave can be modified using the `>` and `<`
commands. For example `>` will increase the default octave by one, and
`<<` will decrease it by two.

### Comments and new-lines

The tune can contain comments, starting with a `#`, and new lines. They
will be retained in the output. For example: `C D E F # comment to end of line`.

In general spaces can be omitted in the input tune. But they can be necessary to
distinguish between a comment and a note. For example:
`C D E F # comment to end of line` is valid, but
`C D E F# comment to end of line` is not (as the `F#` would be interpreted as
a note and note as a starting comment).

### Keys (clef)

The tune can contains _keys_ to avoid specifying the accidentals for
each note. For example you can start your tune with `Kb` for a F-major tune,
`Kbb` for a Bb-major tune, etc. or with `K#` for a G-major tune, etc. The key
can in fact appear anywhere in the tune and applies from that point on, until
another key is encountered. A single `K` can be used to go back to the default
C-major key.

Note that whatever keys is used, an octave always starts with the `C` note.
