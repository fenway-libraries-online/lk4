#!/usr/bin/perl

use strict;
use warnings;

use lib '/usr/local/lk4/lib';

use WWW::Lk4;
use CGI qw(:cgi escapeHTML);
use CGI::Cookie;

my %status2msg = (
    200 => 'OK',
    302 => 'Found',
    404 => 'Not found',
);

my %config = (
    'config_file' => $ENV{'LK4_CONFIG_FILE'} || '/usr/local/lk4/conf/lk4.conf',
    'config_dir'  => $ENV{'LK4_CONFIG_DIR'}  || '/usr/local/lk4/conf/lk4.d',
    'data_dir'    => $ENV{'LK4_DATA_DIR'}    || '/usr/local/lk4/data',
);

my $lk4 = WWW::Lk4->new(%config);

if (@ARGV == 1) {
    # Debugging mode: lk4.fcgi /uri/path/required/here?optional&query&string
    $ARGV[0] .= '?' if $ARGV[0] !~ /\?/;
}

if (my $q = CGI->new) {
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
        die "Unhandled request: $req";
    }
}

sub print_redirect {
    my ($uri, $status) = @_;
    $status ||= 302;
    my $msg = $status2msg{$status} || 'Found';
    print <<"EOS";
Status: $status $msg
Location: $uri
Content-Type: text/plain
Content-Length: 0

EOS
}

sub print_error {
    my ($status) = @_;
    $status ||= 404;
    my $msg = $status2msg{$status} || 'An error occurred';
    print <<"EOS";
Status: $status $msg

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

sub print_menu {
    my ($menu) = @_;
    my $template = $menu->{'template'};
    my $fh;
    if (defined $template) {
        my $f = find_menu($template)
            or die "no such template: $template";
        open $fh, '<', $f or die "open $template: $!";
    }
    else {
        $fh = \*DATA;
    }
    my $content = process_template($fh, {
        'menu' => $menu,
    });
    my $length = length $content;
    print <<"EOS";
Status: 200 OK
Content-Type: text/html; charset=UTF-8
Content-Length: $length

$content
EOS
}


sub process_template {
    my ($fh, $vars) = @_;
    my $menu = $vars->{'menu'};
    my (@header, @item, @footer);
    my %section = (
        'header' => \@header,
        'item' => \@item,
        'footer' => \@footer,
    );
    my $sec = $section{'header'};
    while (<$fh>) {
        next if /^#/;
        if (/^[@]\s*(\w+)/) {
            $sec = $section{$1} or die "Unrecognized section at line $.: $1";
        }
        elsif (/^[|]/) {
            push @$sec, substr($_, 1);
        }
        elsif (/^[-]/) {
            chomp;
            push @$sec, substr($_, 1);
        }
        elsif (/\S/) {
            chomp;
            die "Unrecognized line at line $.: $_";
        }
    }
    my $output = '';
    foreach (@header) {
        s/\${\s*(\S+)\s*}/escapeHTML($menu->{$1})/eg;
        $output .= $_;
    }
    foreach my $i (@{ $menu->{'items'} }) {
        foreach (@item) {
            my $line = $_;
            $line =~ s/\${\s*(\S+)\s*}/escapeHTML($i->{$1})/eg;
            $output .= $line;
        }
    }
    foreach (@footer) {
        s/\${\s*(\S+)\s*}/escapeHTML($menu->{$1})/eg;
        $output .= $_;
    }
    return $output;
}

sub find_menu {
    my ($name) = @_;
    foreach (grep { defined $_ } $config{'config_dir'}, basename($config{'config_file'})) {
        return "$_/$name.menu" if -f "$_/$name.menu";
    }
}

sub basename {
    local $_ = shift;
    s{.+/}{};
    return $_;
}

__END__
### This is an experimental menu; it's not being used yet
@header
|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
|<html>
|<head>
|    <title>${title}</title>
|</head>
|<body>
|<h1>${title}</h1>
|<p>
|Please select the appropriate link from the list below.
|</p>
|<ul>
@item
|<li><a href="${uri}" />${label}</li>
@footer
|</ul>
|</body>
|</html>

