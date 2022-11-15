package Require::Hook::Source::DzilBuild;

use strict;
use warnings;

# AUTHORITY
# DATE
# DIST
# VERSION

sub new {
    my ($class, %args) = @_;
    $args{zilla} or die "Plase supply zilla object";
    bless \%args, $class;
}

sub Require::Hook::Source::DzilBuild::INC {
    my ($self, $filename) = @_;

    print STDERR __PACKAGE__ . ": entering handler for require($filename)\n" if $self->{debug};

    my @files = grep { $_->name eq "lib/$filename" } @{ $self->{zilla}->files };
    @files    = grep { $_->name eq $filename }       @{ $self->{zilla}->files }
        unless @files;
    @files or do {
        die "Can't locate $filename in lib/ or ./ in build files" if $self->{die};
        print STDERR __PACKAGE__ . ": declined handling require($filename): Can't locate $filename in lib/ or ./ in Dist::Zilla build files\n" if $self->{debug};
        return;
    };

    print STDERR __PACKAGE__ . ": require($filename) from Dist::Zilla build file\n" if $self->{debug};
    \($files[0]->encoded_content);
}

1;
# ABSTRACT: Load module source code from Dist::Zilla build files

=for Pod::Coverage .+

=head1 SYNOPSIS

In your L<Dist::Zilla> plugin, e.g. in C<munge_files()>:

 sub munge_files {
     my $self = shift;

     local @INC = (Require::Hook::Source::DzilBuild->new(zilla => $self->zilla), @INC);
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

=item * debug => bool

If set to 1, will print more debug stuffs to STDERR.

=back


=head1 SEE ALSO

L<Dist::Zilla::Role::RequireFromBuild>

L<Require::HookChain::source::dzilbuild> is a L<Require::HookChain> version and
it uses us.
