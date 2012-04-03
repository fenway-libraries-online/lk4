#!/usr/bin/perl

use strict;
use warnings;

use lib '/usr/local/lib/site_perl';

use WWW::Lk4;
use CGI::Fast qw(:cgi escapeHTML);
use CGI::Cookie;

my %status2msg = (
    200 => 'OK',
    302 => 'Found',
    404 => 'Not found',
);

my %config = (
    'config_file' => $ENV{'LK4_CONFIG_FILE'} || '/usr/local/lk4/conf/lk4.conf',
    'data_dir'    => $ENV{'LK4_DATA_DIR'}    || '/usr/local/lk4/data',
);
$config{'config_dir'} = $ENV{'LK4_CONFIG_DIR'} if exists $ENV{'LK4_CONFIG_DIR'};

my $lk4 = WWW::Lk4->new(%config);

if (@ARGV == 1) {
    # Debugging mode: lk4.fcgi /uri/path/required/here?optional&query&string
    # Make CGI::Fast happy by ensuring the command-line arg ends in ?
    $ARGV[0] .= '?' if $ARGV[0] !~ /\?/;
}

while (my $q = CGI::Fast->new) {
    my %env = request_environment($q);
    my $req = $env{'$path_info'} . $env{'$query_string'};
    my %result = $lk4->resolve($req, %env);
    my ($ok, $status, $uri, $menu) = @result{qw(ok status uri menu)};
    if (defined $uri) {
        print_redirect($uri, $status);
    }
    elsif (defined $menu) {
        print_menu($menu);
    }
    elsif (!$ok) {
        print_error($status);
    }
    else {
        die;
    }
}

sub print_redirect {
    my ($uri, $status) = @_;
    $status ||= 302;
    my $msg = $status2msg{$status} || 'Found';
    print <<"EOS";
HTTP/1.1 $status $msg
Location: $uri
Content-Type: text/plain
Content-Length: 0

EOS
}

sub print_menu {
    my ($menu) = @_;
    my $title = escapeHTML($menu->{title});
    my $content = <<"EOS";
<html>
<head>
    <title>$title</title>
</head>
<body>
    <h1>$title</h1>
    <ul>
EOS
    foreach (@{ $menu->{items}}) {
        $content .= '        ' . menu_item_html($_);
    }
    $content .= <<"EOS";
    </ul>
</body>
</html>
EOS
    my $length = length $content;
    print <<"EOS";
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Content-Length: $length

$content
EOS
}

sub menu_item_html {
    my ($item) = @_;
    my $uri   = escapeHTML($item->{uri}  );
    my $label = escapeHTML($item->{label});
    return qq{<li><a href="$uri">$label</a></li>\n};
}

sub print_error {
    my ($status) = @_;
    $status ||= 404;
    my $msg = $status2msg{$status} || 'An error occurred';
    print <<"EOS";
HTTP/1.1 $status $msg

EOS
}

sub request_environment {
    my ($q) = @_;
    my $uri = $q->url('-absolute' => 1, '-path_info' => 1, '-query' => 1);
    my @params = map { '$param(' . $_ . ')', $q->param($_) } $q->param;
    my %cookies = CGI::Cookie->fetch;
    my @cookies = map { '$cookie(' . $_ . ')', $cookies{$_}->value } keys %cookies;
    return (
        '$query_string' => '?'.$q->query_string,
        '$query_string_unescaped'
                        => '?'.unescape($q->query_string),
        '$remote_addr'  => $q->remote_addr,
        '$path_info'    => $q->path_info,
        '$url'          => $uri,
        @params,
    );
}

sub unescape {
    my ($str) = @_;
    $str =~ s/%([0-9A-Fa-f]{2})/pack('H*', $1)/eg;
    $str =~ s/;/&/g;
    return $str;
}
