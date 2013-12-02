package TestsFor::CIF::MooseTypes::Url;
use lib 'testlib';
use base qw(CIF::MooseTypes::TestClass);
use strict;
use warnings;
use Test::More;
use URI;

use CIF::MooseTypes::Url;

sub testing_class { "CIF::MooseTypes::Url"; }

use constant GOOD_URLS => qw(
  http://www.foo.com/
  https://www.foo.com/
  ftp://foo.com/asdf
);

use constant BAD_SCHEMES => qw(
  file:/asdf/laksdjf/asdlkfj.txt
  asdf/laksdjf/asdlkfj.txt
  data:1234
  rtsp://foobar.com/
);

sub required_to_be_uri : Test(2) {
  my $self = shift;
  my $type = $self->get_constraint();
  my $url_text = "http://foobar.com/";
  my $url = URI->new($url_text);
  ok($type->check($url), "Must be a URI object");
  ok(! $type->check($url_text), "Cannot be a string");
}

sub required_to_have_scheme : Test(2) {
  my $self = shift;
  my $type = $self->get_constraint();
  my $url = URI->new("foo.com/bar");
  ok(! $type->check($url), "fail to validate without scheme");
  $url->scheme('http');
  ok($type->check($url), "validates with a scheme");
}

sub required_to_have_a_host : Test(1) {
  my $self = shift;
  my $type = $self->get_constraint();
  my $url = URI->new("file://foo/bar.txt");
  ok(! $type->check($url), "fail to validate without a host");
}

sub test_good_urls : Tests {
  my $self = shift;
  my $type = $self->get_constraint();

  foreach my $url (GOOD_URLS) {
    ok($type->check(URI->new($url)), "'$url' is a valid URL");
  }
}

sub test_bad_schemes : Tests {
  my $self = shift;
  my $type = $self->get_constraint();

  foreach my $url (BAD_SCHEMES) {
    ok(! $type->check(URI->new($url)), "reject invalid/missing scheme '$url'");
  }
}
1;

Test::Class->runtests;
