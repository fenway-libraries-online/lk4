#!/usr/bin/perl

use strict;
use warnings;

use lib '/usr/local/lk4/lib/perl5lib';

use WWW::Lk4;
use URI;

my %config = (
    'config_file' => $ENV{'LK4_CONFIG_FILE'} || '/usr/local/lk4/conf/lk4.conf',
    'data_dir'    => $ENV{'LK4_DATA_DIR'}    || '/usr/local/lk4/data',
);
$config{'config_dir'} = $ENV{'LK4_CONFIG_DIR'} if exists $ENV{'LK4_CONFIG_DIR'};

my $lk4 = WWW::Lk4->new(%config);

if (@ARGV == 1) {
    # Debugging mode: lk4.pl /uri/path/required/here?optional&query&string
    # Make CGI::Fast happy by ensuring the command-line arg ends in ?
    $ARGV[0] .= '?' if $ARGV[0] !~ /\?/;
}

my $running = 1;
my $reload  = 0;

$SIG{'HUP'}  = sub { $reload  = 1 };
$SIG{'TERM'} = sub { $running = 0 };

while ($running && defined(my $req = <STDIN>)) {
    chomp $req;
    if ($reload) {
        $lk4 = WWW::Lk4->new(%config);
        $reload = 0;
    }
    my ($remote_addr, $method, $uri, %env) = request_environment($req);
    my %result = $lk4->resolve($uri, %env);
    my ($ok, $status, $new_uri, $menu) = @result{qw(ok status uri menu)};
    if (defined $menu) {
        print "NULL\n";
    }
    elsif (defined $new_uri) {
        $status ||= 302;
        print $status, ' ', $new_uri, "\n";
    }
    elsif (!$ok) {
        print "NULL\n";
    }
    else {
        warn "lk4: unhandled request: $req";
    }
}

sub request_environment {
    my ($remote_addr, $method, $uri) = split / /, $_[0], 3;
    my $u = URI->new($uri);
    my $path_info    = $u->path;
    my $query_string = $u->query;
    $query_string = '' if !defined $query_string;
    $query_string =~ s/^\?//;
    my %param;
    foreach (split /[;&]/, $query_string) {
        $param{'$param('.$1.')'} = decode($2) if /^([^=]+)=(.*)/;
    }
    return (
        $remote_addr,
        $method,
        $uri,
        '$remote_addr'  => $remote_addr,
        '$method'       => $method,
        '$url'          => $uri,
        '$path_info'    => $path_info,
        '$query_string' => '?'.$query_string,
        '$query_string_unescaped'
                        => '?'.unescape($query_string),
        %param,
    );
}

sub unescape {
    my ($str) = @_;
    $str =~ s/%([0-9A-Fa-f]{2})/pack('H*', $1)/eg;
    $str =~ s/;/&/g;
    return $str;
}

