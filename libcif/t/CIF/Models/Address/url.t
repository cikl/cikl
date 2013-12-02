package TestsFor::CIF::Models::Address::url;
use lib 'testlib';
use base qw(CIF::Models::Address::TestClass);
use strict;
use warnings;
use Test::More;

use CIF::Models::Address::url;

sub testing_class { "CIF::Models::Address::url"; }

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

sub test_known_good_urls: Test(3) { 
  my $self = shift;

  ok($self->generate("http://foo.com/"),  "accept http url");
  ok($self->generate("https://foo.com/"),  "accept https url");
  ok($self->generate("ftp://foo.com/"),  "accept ftp url");
}

sub test_known_invalid_urls: Test(6) { 
  my $self = shift;
  ok(! $self->safe_generate("file://foo/bar"), "reject file:// scheme");
  ok(! $self->safe_generate("foo/bar.txt"), "reject relative path");
  ok(! $self->safe_generate("data:1234"), "reject data scheme");
  ok(! $self->safe_generate("rtsp://foobar.com/"), "reject rtsp scheme");
  ok(! $self->safe_generate(undef), "reject undefined object");
  ok(! $self->safe_generate({}), "reject hashref object");
}

sub test_new_normalized : Test(6) {
  my $self = shift;
  is($self->generate_normalized("foo.com/bar.txt")->value(), 
      'http://foo.com/bar.txt', "add http scheme, if missing");

  is($self->generate_normalized("HTTP://bar.com/")->value(), 
      'http://bar.com/', "downcase the scheme");

  is($self->generate_normalized("https://bar.com:443/")->value(), 
      'https://bar.com/', "remove redundant default port number");

  is($self->generate_normalized("   http://bar.com/")->value(), 
      'http://bar.com/', "remove leading spaces");

  is($self->generate_normalized("http://bar.com/   ")->value(), 
      'http://bar.com/', "remove trailing spaces");

  is($self->generate_normalized("http://bar.com")->value(), 
      'http://bar.com/', "add path slash if there isn't one");
}

Test::Class->runtests;
