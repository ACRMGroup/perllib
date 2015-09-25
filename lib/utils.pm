package utils;
#*************************************************************************
#
#   Program:    
#   File:       utils.pm
#   
#   Version:    V1.0
#   Date:       01.05.15
#   Function:   
#   
#   Copyright:  (c) Dr. Andrew C. R. Martin, UCL, 2015
#   Author:     Dr. Andrew C. R. Martin
#   Address:    Institute of Structural and Molecular Biology
#               Division of Biosciences
#               University College
#               Gower Street
#               London
#               WC1E 6BT
#   EMail:      andrew@bioinf.org.uk
#               
#*************************************************************************
#
#   This program is not in the public domain, but it may be copied
#   according to the conditions laid out in the accompanying file
#   COPYING.DOC
#
#   The code may be modified as required, but any modifications must be
#   documented so that the person responsible can be identified. If 
#   someone else breaks this code, I don't want to be blamed for code 
#   that does not work! 
#
#   The code may not be sold commercially or included as part of a 
#   commercial product except as described in the file COPYING.DOC.
#
#*************************************************************************
#
#   Description:
#   ============
#   General utility functions
#
#*************************************************************************
#
#   Usage:
#   ======
#
#*************************************************************************
#
#   Revision History:
#   =================
#   V1.0   01.05.15 Original   By: ACRM
#
#*************************************************************************
use File::Basename;

#*************************************************************************
# Prints a message ($string) with an optional line number ($line) and 
# exits the program
sub mydie
{
    my($string, $line) = @_;
    print STDERR "$string";
    if($line)
    {
        print STDERR " at line $line";
    }
    print "\n";
    exit 1;
}

#-------------------------------------------------------------------------
# Installs $file in $dir and uncompresses it if $uncompress is set
sub InstallFile
{
    my($file, $dir, $uncompress) = @_;

    return(0) if(!MakeDir($dir));
    `cp $file $dir`;

    my $newfile = $file;
    $newfile =~ s/.*\///;          # Remove path
    $newfile = "$dir/$newfile";
    return(0) if(! -e $newfile);

    if($uncompress)
    {
        `cd $dir; gunzip -f $newfile`;
        $newfile =~ s/\.gz//;
        return(0) if(! -e $newfile);
    }

    return(1);
}

#-------------------------------------------------------------------------
# Makes a directory and checks that it has been created OK
sub MakeDir
{
    my($dir) = @_;
    `mkdir -p $dir` if(! -d $dir);
    return(0) if(! -d $dir);
    return(1);
}

#-------------------------------------------------------------------------
# Checks that a list of files are executable. Returns a list of the files
# that were NOT OK, or a blank string if all were OK. The list may also
# be supplied as a scalar variable, separating names with |
sub CheckExecutables
{
    my(@files) = @_;

    # If there is only one filename specified and it contains a |
    # then split this into a list
    if((scalar(@files) == 1) && ($files[0] =~ '\|'))
    {
        @files = split(/\|/, $files[0])
    }

    my $badexe = '';
    foreach my $file (@files)
    {
        if(! -x $file)
        {
            if($badexe eq '')
            {
                $badexe = $file;
            }
            else
            {
                $badexe .= ", $file";
            }
        }
    }
    return($badexe);
}

#-------------------------------------------------------------------------
# Checks that a list of environment variables have been defined. Returns 
# a list of those that were NOT OK, or a blank string if all were OK. The 
# list may also be supplied as a scalar variable, separating names with |
sub CheckEnvironmentVariables
{
    my(@vars) = @_;

    # If there is only one filename specified and it contains a |
    # then split this into a list
    if((scalar(@vars) == 1) && ($vars[0] =~ '\|'))
    {
        @vars = split(/\|/, $vars[0])
    }

    my $badvar = '';
    foreach my $var (@vars)
    {
        if(!defined($ENV{$var}))
        {
            if($badvar eq '')
            {
                $badvar = $var;
            }
            else
            {
                $badvar .= ", $var";
            }
        }
    }
    return($badvar);
}

#-------------------------------------------------------------------------
# Checks that a list of files exist and are readable. Returns a list of 
# the files that were NOT OK, or a blank string if all were OK.
sub CheckFile
{
    my(@files) = @_;
    my $badfile = '';
    foreach my $file (@files)
    {
        if(! -r $file)
        {
            if($badfile eq '')
            {
                $badfile = $file;
            }
            else
            {
                $badfile .= ", $file";
            }
        }
    }
    return($badfile);
}


sub parseFilename
{
    my($infile, $longext) = @_;
    my ($path, $filename, $filestem, $extension) = ('','','','');

#OK
    $filename = $infile;
    $filename =~ s/^.*\///;     # Remove anything up to the first /

#OK
    if($longext)
    {
        if($filename =~ /\.(.+)$/)
        {
            $extension = $1;
        }
    }
    else
    {
        if($filename =~ /.*\.(.+?)$/)
        {
            $extension = $1;
        }
    }

# OK
    if($infile =~ /(.*)\//)
    {
        $path = $1;
    }

    if($longext)
    {
        if($filename =~ /^(.*?)\..*/)
        {
            $filestem = $1;
        }
    }
    else
    {
        if($filename =~ /^(.*)\./)
        {
            $filestem = $1;
        }
    }

    return($path, $filename, $filestem, $extension);
}

sub setExtension
{
    my($infile, $ext, $longext) = @_;
    my $outfile;

    if(!($ext =~ /^\./))        # If it doesn't start with a . add one
    {
        $ext = ".$ext";
    }

    my($path, $filename, $filestem, $extension) = parseFilename($infile, $longext);
    if($extension eq '')
    {
        $outfile = $infile . $ext;
    }
    else
    {
        if($path eq '')
        {
            $outfile = "$filestem$ext";
        }
        else
        {
            $outfile = "$path/$filestem$ext";
        }
    }
    return($outfile);
}

sub ReadFileHandleAsTwoColumnHashRef
{
    my ($fh)   = @_;
    my %result = ();

    while(my $line = <$fh>)
    {
        chomp $line;
        $line =~ s/\#.*//;  # Remove comments
        $line =~ s/^\s+//;  # Remove leading spaces
        $line =~ s/\s+$//;  # Remove trailing spaces
        if(length($line))
        {
            my @fields = split(/\s+/, $line);
            $result{$fields[0]} = $fields[1];
        }
    }

    return(\%result);
}

sub sortResids
{
    my @resids = @_;

    return(sort residSortFunc @resids);
}

sub parseResid
{
    my($resid) = @_;
    $resid =~ /([LH])(\d+)([A-Za-z]?)/;
    return($1, $2, $3);
}

sub residSortFunc
{
    return(0) if($a eq $b);

    $a =~ /([LH])(\d+)([A-Za-z]?)/;
    my ($aC, $aN, $aI) = ($1, $2, $3);
    
    $b =~ /([LH])(\d+)([A-Za-z]?)/;
    my ($bC, $bN, $bI) = ($1, $2, $3);

    return(-1) if($aC lt $bC);
    return(+1) if($aC gt $bC);
    return(-1) if($aN <  $bN);
    return(+1) if($aN >  $bN);
    return(-1) if($aI lt $bI);
    
    return(1);
}


1;
