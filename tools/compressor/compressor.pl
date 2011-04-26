#!/usr/bin/perl -w
# coding: UTF-8

# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

use common::sense;

use FindBin;
use IO::Dir;
use File::Copy;
use Data::Dumper;

use lib::abs qw(../../lib);

use Ali::File::Temp qw(temp_filename);
use Ali::File::Slurp qw(slurp_utf8 spew_utf8 slurp);

&main();
# ------------------------------------------------------------------------------
sub main
{
    my $params = {
        dir_dev     => "$FindBin::Bin/i/dev",
        dir_build   => "$FindBin::Bin/i",
        bin_java    => 'java',
        bin_yui     => "$FindBin::Bin/bin/yuicompressor-2.4.2.jar",
        bin_closure => "$FindBin::Bin/bin/compiler.jar",
    };

    # Search dev directories
    my @devdirs;
    my $d = IO::Dir->new($params->{dir_dev});
    if (defined $d) {
        while (defined(my $item = $d->read)) {
            if ($item !~ /^\./ && -d "$params->{dir_dev}/$item") {
                push(@devdirs, $item);
            }
        }
        undef $d;
    }

    for (sort(@devdirs)) {
        compile($params, $_);
    }
}
# ------------------------------------------------------------------------------
sub compile
{
    my ($params, $name) = @_;

    print "Compile $name\n";

    # Search sources
    my @css;
    my @js;

    my $d = IO::Dir->new("$params->{dir_dev}/$name");
    if (defined $d) {
        while (defined(my $item = $d->read)) {
            my $fn = "$params->{dir_dev}/$name/$item";
            if (-s $fn) {
                if ($item =~ /^\d{2}-.+\.css$/) {
                    push(@css, $fn);
                }
                elsif ($item =~ /^\d{2}-.+\.js$/) {
                    push(@js, $fn);
                }
            }
        }
        undef $d;
    }

    # Slurp files and save concatenation
    my $c_css = mslurp(@css);
    my $f_css = temp_filename('css');
    spew_utf8($f_css, $c_css);

    my $c_js  = mslurp(@js);
    my $f_js  = temp_filename('js');
    spew_utf8($f_js, $c_js);

    # Compile CSS
    my $o_css = temp_filename('css');
    `$params->{bin_java} -jar $params->{bin_yui} --type css --charset utf-8 $f_css -o $o_css -v`;

    # Compile JS
    my $o_js = temp_filename('js');
    `$params->{bin_java} -jar $params->{bin_closure} --js $f_js --js_output_file $o_js --charset UTF-8 --compilation_level SIMPLE_OPTIMIZATIONS`;

    # Replace compiled
    creplace($params->{dir_build}, $name, 'css', $o_css);
    creplace($params->{dir_build}, $name, 'js', $o_js);

    # Clear
    unlink($f_css);
    unlink($o_css);
    unlink($f_js);
    unlink($o_js);

    print "\n";
}
# ------------------------------------------------------------------------------
sub mslurp
{
    my (@files) = sort(@_);

    my $cont = '';
    for my $f (@files) {
        $cont .= slurp_utf8($f) . "\n\n";
    }

    return $cont;
}
# ------------------------------------------------------------------------------
sub creplace
{
    my ($dir, $name, $suffix, $source) = @_;

    if (-s $source) {

        my $maxnum = 0;
        my $to_overwrite = '';

        my $d = IO::Dir->new($dir);
        if (defined $d) {
            while (defined(my $item = $d->read)) {
                my $fn = "$dir/$item";
                if (-e $fn && $item =~ /^\Q$name\E-(\d+)\.\Q$suffix\E$/) {
                    if ($1 > $maxnum) {
                        $maxnum = $1;
                        $to_overwrite = $fn;
                    }
                }
            }
            undef $d;
        }

        if ($maxnum > 0) {

            if (files_equal($source, "$dir/$name-$maxnum.$suffix")) {
                print "$name-$maxnum.$suffix not changed, keep it\n";
            }
            else {
                my $newnum = $maxnum + 1;
                copy($source, "$dir/$name-$newnum.$suffix") or die "Copy failed: $!";
                print "New rev $name-$newnum.$suffix created\n";
            }

        }
        else {
            copy($source, "$dir/$name-1.$suffix") or die "Copy failed: $!";
            print "First rev $name-1.$suffix created\n";
        }
    }
    else {
        print "ERROR: $source is empty\n";
    }
}
# ------------------------------------------------------------------------------
sub files_equal
{
    my ($f1, $f2) = @_;

    my $c1 = slurp($f1);
    my $c2 = slurp($f2);

    return ($c1 eq $c2) ? 1 : 0;
}
# ------------------------------------------------------------------------------
1;
