#!/usr/local/gnu/bin/perl -w
####  _______              __
#### / ___/ /  ___  __ _  / /  ___
####/ /__/ _ \/ _ \/  ' \/ _ \/ _ \
####\___/_//_/\___/_/_/_/_.__/\___/ 
####
####
#### This software is copyright (C) by the Lawrence Berkeley
#### National Laboratory.  Permission is granted to reproduce
#### this software for non-commercial purposes provided that
#### this notice is left intact.
#### 
#### It is acknowledged that the U.S. Government has rights to
#### this software under Contract DE-AC03-765F00098 between
#### the U.S.  Department of Energy and the University of
#### California.
####
#### This software is provided as a professional and academic
#### contribution for joint exchange. Thus it is experimental,
#### is provided ``as is'', with no warranties of any kind
#### whatsoever, no support, no promise of updates, or printed
#### documentation. By using this software, you acknowledge
#### that the Lawrence Berkeley National Laboratory and
#### Regents of the University of California shall have no
#### liability with respect to the infringement of other
#### copyrights by any part of this software.
####
#################################################
###  This is the ChfOffsetix processer.
### Interface is
### sub ChfixProc::procChfOffsetixMacros(inputfile, outputfile,
###                                SpaceDim, debug)
###
###  reads in input file 
#################################################

package ChfOffsetixProc;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);
use Exporter;
$VERSION = 1.23;
@ISA = qw(Exporter);
@EXPORT = qw(&procChfOffsetixMacros);
@EXPORT_OK = qw(&procChfOffsetixMacros);
@EXPORT_TAGS= ();

sub ChfOffsetixProc::procChfOffsetixMacros
{

    use strict;
    my ($FINFile, $FOUTFile, $SpaceDim, $debug) = @_;
    if($debug)
    {
        print "ChfOffsetixProc: \n";
        print "input file  = $FINFile \n";
        print "output file = $FOUTFile \n";
        print "SpaceDim    = $SpaceDim \n";
    }
    
    open(FOUT,">" . $FOUTFile) 
        or die "Error: cannot open output file " . $FOUTFile . "\n";
    open(FIN,"<" . $FINFile) 
        or die "Error: cannot open input file " . $FINFile . "\n";

    my $ibuf = "";
    my $obuf = "";
    ###put the entire input file into a string buffer
    while (defined( $ibuf = <FIN> )) 
    {
        $obuf .= $ibuf;
    }
    my $beginstring = "CHF_OFFSETIX";
    my $beginlen = 12;
    my $endstring = "]";
    my $endlen = 1;
    my $beginoffset = 0;
    my $endoffset = 0;
    my $length = 0;
    my $firstlen = 0;
    my $firststring = " ";
    my $newstring = " ";
    while ($obuf  =~ m/$beginstring/ig )
    {
        $beginoffset = pos $obuf;

        $firstlen = $beginoffset-$endoffset-$beginlen;
        $firststring = substr($obuf, $endoffset, $firstlen);
        print FOUT $firststring;

        my $tempbuf = $obuf;
        pos $tempbuf = $beginoffset;
        $tempbuf =~ m/$endstring/ig;
        $endoffset = pos $tempbuf;
        $length = $endoffset-$beginoffset-$endlen;

        $newstring = substr($obuf, $beginoffset, $length);
        ###newstring now is of form [arg0;arg1;arg2]
        $newstring =~ s/\[//g;
        $newstring =~ s/\]//g;
        ###newstring now is of form arg0;arg1;arg2
        my @dimarg = split(";", $newstring);
        my $printstring ="";
        for( my $idir=0 ; $idir < $SpaceDim ; $idir++ ) 
        {
            if($idir < $SpaceDim)
            {
                $printstring .= "$dimarg[0]$idir";
                $printstring .= "$dimarg[1]$idir";
            }
            if($idir < $SpaceDim-1)
            {
                $printstring .= ",";
            }
 ##          print "$idir  $dimarg[$idir] \n";
        }
        print FOUT $printstring;
    }
    $newstring = substr($obuf, $endoffset);
    print FOUT $newstring;

    ###need to close files to make this modular.
    close(FIN);
    close(FOUT);
    return 1;   
}
###i have no idea why this is here.
###the perl cookbook book told me to put it there.
###really.
1;
