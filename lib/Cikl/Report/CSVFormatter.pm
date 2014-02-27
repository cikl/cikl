package Cikl::Report::CSVFormatter;
use parent 'Cikl::Report::Formatter';

use strict;
use warnings;

use Text::CSV;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new();
  return $self;
}

# This method accepts a context (report) and a filehandle. The generated 
# report will be output to the filehandle.
sub generate_report {
  my $self = shift;
  my $context = shift;
  my $fh = shift;
  my $csv = Text::CSV->new( {binary => 1} ) or die($!);
  $csv->eol("\r\n");
  my $fields = $context->event_fields();
  $csv->print($fh, $fields);

  my $body_iter = $context->body_iterator();
  my $row;
  while ($row = $body_iter->()) {
    my @values = map { $row->{$_}; } @$fields;
    $csv->print($fh, \@values);

  }
}

1;
