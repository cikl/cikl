package Cikl::Report::TableFormatter;
use parent 'Cikl::Report::Formatter';

use strict;
use warnings;

use Text::Table;

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
  my $fields = $context->event_fields();
  my @header = map { $_, { is_sep => 1, title => '|' } } @$fields;
  my $table = Text::Table->new(@header);

  my $body_iter = $context->body_iterator();
  my $row;
  while ($row = $body_iter->()) {
    my @values = map { $row->{$_}} @$fields;
    $table->add(@values);
  }

  print $fh $table;
}

1;
