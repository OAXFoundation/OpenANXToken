#!/usr/bin/perl
# ----------------------------------------------------------------------------------------------
# Combining the individual .sol files into a single .sol
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

my $CONTRACTSDIR="../contracts";
my $MAINSOL="OpenANXToken.sol";

open (MAIN, "<$CONTRACTSDIR/$MAINSOL")
  or die "Cannot open $CONTRACTSDIR/$MAINSOL. Stopped";

while (my $line = <MAIN>) {
  chomp $line;
  if ($line =~ /^import/) {
    my $importfile = $line;
    $importfile =~ s/^import \"\.\///;
    $importfile =~ s/\";//;
    # print $importfile;
    open (INCLUDE, "<$CONTRACTSDIR/$importfile")
      or die "Cannot open $CONTRACTSDIR/$importfile. Stopped";
    while (my $line1 = <INCLUDE>) {
      chomp $line1;
      if ($line1 =~ /^import/) {
      } elsif ($line1 =~ /^pragma/) {
      } else {
        print $line1 . "\n";
      }
    }
    close (INCLUDE)
      or die "Cannot close $CONTRACTSDIR/$importfile. Stopped";
    print $line1 . "\n";
  } else {
    print $line . "\n";
  }
}

close (MAIN)
  or die "Cannot close $CONTRACTSDIR/$MAINSOL. Stopped";
