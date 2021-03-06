package List::Utils::Nest;

use 5.006;
use strict;
use warnings;
use Carp;

=head1 NAME

List::Utils::Nest - transform Hash Array to Nested Array

=head1 VERSION

Version 0.01.1

=cut

our $VERSION = '0.01.1';


=head1 Usage


    use List::Utils::Nest;
    my $sample = [
       {userid => 1, itemid => 1, quantity => 3},
       {userid => 1, itemid => 4, quantity => 3},
       ...
       {userid => 3, itemid => 2, quantity => 3},
       {userid => 3, itemid => 4, quantity => 3},
       {userid => 3, itemid => 4, quantity => 1},
    ];

    my $entries = List::Utils::Nest->new($sample)->key('userid')->entries();

    # [{
         values => [
           {userid => 1, itemid => 1, quantity => 3},
           {userid => 1, itemid => 4, quantity => 3}
         ],
         key => 1
       },
       ...
       {
         values => [
           {userid => 3, itemid => 2, quantity => 3},
           {userid => 3, itemid => 4, quantity => 3},
           {userid => 3, itemid => 4, quantity => 1}
         ],
         key => 3
       }
      ]

`nest` is alias new List::Utils::Nest

    my $entries = nest($sample)->key('userid')->entries();

You can specify multiple keys

    my $entries = nest($sample)->key('userid', 'itemid')->entries();

And you can set delimiter below:

    my $entries = nest($sample, delimiter => ",")->key('userid', 'itemid')->entries();

You can specify depth more than one.
    
    my $entries = nest($sample, delimiter => ",")->key('userid')->key('itemid')->entries();


=head1 EXPORT


=head1 SUBROUTINES/METHODS

=cut

require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/nest/;

sub new {
    my $class = shift;
    my $data = shift;
    my %opt = @_;

    return bless {
        array => $data,
        keys => [],
        tree => {},
        delimiter => $opt{delimiter} || "_____",
    }, $class;
}

sub nest {
    my $data = shift;
    my %opt = @_;
    
    my $self = new List::Utils::Nest($data, %opt);
    $self;
}

sub key {
    my $self = shift;
    my @keys = @_;
    
    push @{$self->{keys}}, [@keys];
    $self;
}

sub _entries {
    my $self = shift;
    my $array = shift;
    my $depth = shift;
    return $array if $depth >= scalar @{$self->{keys}};
    my $key = $self->{keys}[$depth];

    my $branch = [];
    my %map;
    
    foreach my $obj (@$array){
        my $k = join($self->{delimiter}, map { (ref $_ ne "CODE") ? (exists $obj->{$_} ? $obj->{$_} : $self->{delimiter}) : $_->($obj); } @$key);
        $map{$k} = [] unless exists $map{$k};
        push @{$map{$k}}, $obj;
    }

    foreach my $k (sort keys %map){
        push @$branch, {key => $k, values => $self->_entries($map{$k}, $depth+1)};
    }
    $branch;
}

sub entries {
    my $self = shift;

    $self->_entries($self->{array}, 0);
}

=head1 AUTHOR

Muddy Dixon, C<< <muddydixon at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-list-utils-nest at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=List-Utils-Nest>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc List::Utils::Nest


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=List-Utils-Nest>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/List-Utils-Nest>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/List-Utils-Nest>

=item * Search CPAN

L<http://search.cpan.org/dist/List-Utils-Nest/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Muddy Dixon.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of List::Utils::Nest
