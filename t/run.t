#
# testscript for Config::General Classes by Thomas Linden
#
# needs to be invoked using the command "make test" from
# the Config::General source directory.
#
# Under normal circumstances every test should succeed.

BEGIN { $| = 1; print "1..15\n";}
use lib "blib/lib";
use Config::General;
use Config::General::Extended;
use Data::Dumper;
print "ok\n";
print STDERR "\n1 .. ok # loading Config::General and Config::General::Extended\n";

foreach (2..7) {
  &p("t/cfg." . $_, $_);
}

my $conf = new Config::General("t/cfg.8");
my %hash = $conf->getall;
$conf->save("t/cfg.out", %hash);

my $copy = new Config::General("t/cfg.out");
my %copyhash = $copy->getall;

my $a = \%hash;
my $b = \%copyhash;

# now see if the saved hash is still the same as the
# one we got from cfg.8
if (&comp($a,$b)) {
  print "ok\n";
  print STDERR "8 .. ok # Writing Config Hash to disk and compare with original\n";
}
else {
  print "8 not ok\n";
  print STDERR "8 .. not ok\n";
}


############## Extended Tests #################

$conf = new Config::General::Extended("t/test.rc");
print "ok\n";
print STDERR "9 .. ok # Creating a new object from config file\n";




# now test the new notation of new()
my $conf2 = new Config::General::Extended(
                                          -file              => "t/test.rc",
                                          -AllowMultiOptions => "yes"
                                        );
print "ok\n";
print STDERR "10 .. ok # Creating a new object using the hash parameter way\n";




my $domain = $conf->obj("domain");
print "ok\n";
print STDERR "11 .. ok # Creating a new object from a block\n";




my $addr = $domain->obj("bar.de");
print "ok\n";
print STDERR "12 .. ok # Creating a new object from a sub block\n";




my @keys = $conf->keys("domain");
print "ok\n";
print STDERR "13 .. ok # Getting values from the object\n";





# test various OO methods
if ($conf->is_hash("domain")) {
  my $domains = $conf->obj("domain");
  foreach my $domain ($conf->keys("domain")) {
    my $domain_obj = $domains->obj($domain);
    foreach my $address ($domains->keys($domain)) {
      my $blah = $domain_obj->value($address);
    }
  }
}
print "ok\n";
print STDERR "14 .. ok # Using keys() and values() \n";

# test AUTOLOAD methods
my $conf3 = new Config::General::Extended( { name => "Moser", prename => "Hannes"} 
);
my $n = $conf3->name;
my $p = $conf3->prename;
$conf3->name("Meier");
$conf3->prename("Max");
$conf3->save("t/test.cfg");

print "ok\n";
print STDERR "15 .. ok # Using AUTOLOAD methods\n";




sub p {
  my($cfg, $t) = @_;
  open T, "<$cfg";
  my @file = <T>;
  close T;
  @file = map { chomp($_); $_} @file;
  my $fst = $file[0];
  my $conf = new Config::General($cfg);
  my %hash = $conf->getall;
  print "ok\n";
  print STDERR "$t .. ok $fst\n";
}

sub comp {
  my($a, $b) = @_;
  foreach my $key (keys %{$a}) {
    if(ref($a->{$key}) eq "HASH") {
       &comp($a->{$key},$b->{$key});
       next;
    }
    elsif(ref($a->{$key}) eq "ARRAY") {
       # ignore arrays for simplicity
       next;
    }
    return 0 if($a->{$key} ne $b->{$key});
  }
  return 1;
}