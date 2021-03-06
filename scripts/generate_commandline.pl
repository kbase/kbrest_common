#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

sub usage {
  print "generate_commandline.pl >>> create API commandline scripts\n";
  print "generate_commandline.pl -template <template file name> -config <configuration file name> [ -outdir <output directory> ]\n"; 
}

my $template = '';
my $outdir   = '';
my $config   = '';
my $help     = 0;

GetOptions ( 'template=s' => \$template,
	     'config=s' => \$config,
             'outdir=s' => \$outdir,
             'help!' => \$help );

if ($help) {
    &usage();
    exit 0;
}

unless ($template && $config) {
    print "missing required paramater\n";
    &usage();
    exit 1;
}

my $t = [];
if (open(FH, "<$template")) {
  while (<FH>) {
    chomp;
    push(@$t, $_);
  }
  close FH;
  $t = join("###", @$t);
} else {
  print "could not open template file '$template': $@\n";
  exit;
}

my $data = {};
if (open(FH, "<$config")) {
  my $curr = undef;
  while (<FH>) {
    chomp;
    my ($key, $val) = split /\t/;
    next unless ($key && $val);
    next if ($key =~ /^#/);
    if ($key eq 'filename') {
      $curr = $val;
      $data->{$curr} = { filename => $val };
    } else {
      $data->{$curr}->{$key} = $val;
    }
  }
  close FH;

  foreach my $key (keys(%$data)) {
    next if ($key eq "default");
    my $currt = $t;
    unless (exists($data->{$key}->{options})) {
      $currt =~ s/##optionsdetailed##//g;
    }
    foreach my $k (keys(%{$data->{$key}})) {
      if ($k eq 'options') {
	my @opts = split(/\|/, $data->{$key}->{$k});
	my $optionvars = "";
	my $getopts = "";
	my $additionals = "";
	my $detailed = "";
	my $optionlist = "";
	foreach my $o (@opts) {
	  my ($name, $short, $long) = split(/\^/,$o);
	  if (($name ne 'id') && ($name ne 'text')) {
	    $additionals .= "\nif (\$$name) {\n    \$additionals .= \"&$name=\$$name\";\n}";
	    unless ($name eq 'offset' || $name eq 'limit') {
	      $optionvars .= 'my $'.$name." = undef;\n";
	      $getopts .= ",\n\t'$name=s' => \\\$$name";
	    }
	  }
	  $optionlist .= ", --$name".($short ? " <$short>" : "");
	  $detailed .= "\t$name - $long\n";
	}
	$currt =~ s/##optionvars##/$optionvars/g;
	$currt =~ s/##getopts##/$getopts/g;
	$currt =~ s/##additionals##/$additionals/g;
	$currt =~ s/##optionsdetailed##/$detailed/g;
	$currt =~ s/##optionlist##/$optionlist/g;
      } else {
	my $v = $data->{$key}->{$k};
	$currt =~ s/##$k##/$v/g;
      }
    }
    if (exists($data->{default})) {
      foreach my $k (keys(%{$data->{default}})) {
	my $v = $data->{default}->{$k};
	$currt =~ s/##$k##/$v/g;
      }
    }
    $currt =~ s/([^#])##[a-zA-Z]+##([^#])/$1$2/g;
    my @rows = split(/###/, $currt);
    if (open(FH, ">$outdir/$key")) {
      foreach my $row (@rows) {
	print FH $row."\n";
      }
      close FH;
    } else {
      print "could not open script file for output '$outdir/$key': $@\n";
      exit;
    }
  }
} else {
  print "could not open config file '$config': $@\n";
  exit;
}

print "all done.\nHave a nice day :)\n\n";
