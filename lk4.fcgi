#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';

use WWW::Lk4;
use CGI::Fast qw(:cgi escapeHTML);

my %status2msg = (
    200 => 'OK',
    302 => 'Found',
    404 => 'Not found',
);

my %config = (
    'config_file' => $ENV{'LK4_CONFIG_FILE'} || 'conf/lk4.conf',
    'data_dir'    => $ENV{'LK4_DATA_DIR'}    || 'data',
);
$config{'config_dir'} = $ENV{'LK4_CONFIG_DIR'} if exists $ENV{'LK4_CONFIG_DIR'};

my $lk4 = WWW::Lk4->new(%config);

if (@ARGV == 1) {
	# Debugging mode: lk4.fcgi /uri/path/required/here?optional&query&string
	# Make CGI::Fast happy by ensuring the command-line arg ends in ?
	$ARGV[0] =~ s/\??$/?/;
}

while (my $q = CGI::Fast->new) {
	my $req = $q->url('-absolute' => 1, '-path_info' => 1, '-query' => 1);
    my %result = $lk4->resolve($req);
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
    my $msg = $status2msg{$status} || 'XXX';
    print "HTTP/1.0 $status $msg\n";
    print "Location: $uri\n";
    print "\n";
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
HTTP/1.0 200 OK
Content-Type: text/html; charset=UTF-8
Content-Length: $length

EOS
    print $content;
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
    my $msg = $status2msg{$status} || 'XXX';
    print "HTTP/1.0 $status $msg\n";
    print "\n";
}

