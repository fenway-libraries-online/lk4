#!/usr/bin/perl

use strict;
use warnings;

use lib '/usr/local/lk4/lib';

use WWW::Lk4;
use CGI qw(:cgi escapeHTML);
use CGI::Cookie;

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
    $lk4->handle_cgi($q);
}

