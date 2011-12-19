use warnings;
use strict;

package POSIX::1003::Pathconf;
use base 'POSIX::1003';

use Carp 'croak';

my @constants;
my @functions = qw/pathconf fpathconf pathconf_names/;

our %EXPORT_TAGS =
  ( constants => \@constants
  , functions => \@functions
  , table     => [ '%pathconf' ]
  );

my  $pathconf;
our %pathconf;

BEGIN {
    # initialize the :constants export tag
    $pathconf = pathconf_table;
    push @constants, keys %$pathconf;
    tie %pathconf, 'POSIX::1003::ReadOnlyTable', $pathconf;
}

=chapter NAME

POSIX::1003::Pathconf - POSIX access to pathconf()

=chapter SYNOPSIS

  use POSIX::1003::Pathconf;   # import all

  use POSIX::1003::Pathconf 'pathconf';
  my $max    = pathconf($filename, '_PC_PATH_MAX');

  use POSIX::1003::Pathconf '_PC_PATH_MAX';
  my $max    = _PC_PATH_MAX($filename);

  use POSIX::1003::Pathconf qw(pathconf %pathconf);
  my $key    = $pathconf{_PC_PATH_MAX};
  $pathconf{_PC_NEW_KEY} = $value
  foreach my $name (keys %pathconf) ...

  use POSIX::1003::Pathconf qw(fpathconf);
  use POSIX::1003::FdIO     qw(openfd);
  use Fcntl                 qw(O_RDONLY);
  my $fd     = openfd $fn, O_RDONLY;
  my $max    = fpathconf $fd, '_PC_PATH_MAX';
  my $max    = _PC_PATH_MAX($fd);

  foreach my $pc (pathconf_names) ...

=chapter DESCRIPTION

=chapter FUNCTIONS

=section Standard POSIX
=function fpathconf FD, NAME
Returns the numeric value related to the NAME or C<undef>.

=function pathconf FILENAME, NAME
Returns the numeric value related to the NAME or C<undef>.
=cut

sub fpathconf($$)
{   my ($fd, $key) = @_;
    $key =~ /^_PC_/
        or croak "pass the constant name as string";
    my $id = $pathconf{$key} // return;
    my $v  = POSIX::fpathconf($fd, $id);
    defined $v && $v eq '0 but true' ? 0 : $v;
}

sub pathconf($$)
{   my ($fn, $key) = @_;
    $key =~ /^_PC_/
        or croak "pass the constant name as string";
    my $id = $pathconf{$key} // return;
    my $v = POSIX::pathconf($fn, $id);
    defined $v ? $v+0 : undef;  # remove 'but true' from '0'
}

sub _create_constant($)
{   my ($class, $name) = @_;
    my $id = $pathconf->{$name} // return sub($) {undef};
    sub($) { my $f = shift;
               $f =~ m/\D/
             ? POSIX::pathconf($f, $id)
             : POSIX::fpathconf($f, $id)
           };
}

=section Additional

=function pathconf_names
Returns a list with all known names, unsorted.
=cut

sub pathconf_names() { keys %$pathconf }

=chapter CONSTANTS
The exported variable C<%pathconf> is a HASH which maps C<_PC_*> names
on unique numbers, to be used with the system's C<pathconf()>
and C<fpathconf()> functions.
=cut


1;
