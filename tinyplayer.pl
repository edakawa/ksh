#!/usr/bin/perl

# $Id$

# tinyplayer.pl - play a text file.
#
# Auther: Hajime Edakawa <hajime.edakawa@gmail.com>
# License: Public Domain
# Last Update: Nov, 2018

# Example: get a text file from mp3
#    ffmpeg -i YOUR_FILE.mp3 -ar 8000 -f u8 -acodec pcm_u8 OUTPUT.raw
#    xxd -c1 OUTPUT.raw | awk '{ print $2 }' >OUTPUT.txt
#    tinyplayer.pl OUTPUT.txt

use strict;

my ($file, $rate, $enc, $fmt) = @ARGV;
die "usage: $0 FILE [RATE ENC FMT]\n" unless $file;
$rate //= 8000;
$enc //= "u8";
$fmt //= "raw";

open my $fh, $file or die "fail to open file: $!";
open my $aucat, "| aucat -r $rate -e $enc -h $fmt -i -" or die "fail to open pipe: $!";

my $byte;
while (<$fh>) {
	chomp($_);
	$byte = pack("C", hex("0x$_"));
	print $aucat $byte;
}

close $fh;
close $aucat;
