package Require::Hook::DzilBuild;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    $args{zilla} or die "Plase supply zilla object";
    bless \%args, $class;
}

sub Require::Hook::DzilBuild::INC {
    my ($self, $filename) = @_;

    my @files = grep { $_->name eq "lib/$filename" } @{ $self->{zilla}->files };
    @files    = grep { $_->name eq $filename }       @{ $self->{zilla}->files }
        unless @files;
    @files or do {
        die "Can't locate $filename in lib/ or ./ in build files" if $self->{die};
        return undef;
    };

    \($files[0]->encoded_content);
}

1;
# ABSTRACT: Load module source code from Dist::Zilla build files

=for Pod::Coverage .+

=head1 SYNOPSIS

In your L<Dist::Zilla> plugin, e.g. in C<munge_files()>:

 sub munge_files {
     my $self = shift;

     local @INC = (Require::Hook::DzilBuild->new(zilla => $self->zilla), @INC);
     require Foo::Bar; # will be searched from build files, if exist

     ...
 }


=head1 DESCRIPTION

This is the L<Require::Hook> version of the same functionality found in
L<Dist::Zilla::Role::RequireFromBuild>.

It looks for files from C<lib/> and C<.> of Dist::Zilla build files.


=head1 METHODS

=head2 new(%args) => obj

Constructor. Known arguments:

=over

=item * die => bool (default: 0)

If set to 1, will die if filename to be C<require()>-d does not exist in build
files. Otherwise if set to false (the default) will simply decline if file is
not found in build files.

=back


=head1 SEE ALSO

L<Dist::Zilla::Role::RequireFromBuild>
