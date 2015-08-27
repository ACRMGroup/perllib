package config;
#*************************************************************************
#
#   File:       config.pm
#   
#   Version:    V1.0
#   Date:       29.04.15
#   Function:   Functions to read a config file
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
#   Routines to read a BASH compatible configuration file
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
#   V1.0  29.04.15  Original   By: ACRM
#
#*************************************************************************
use utils;
use FindBin;

#*************************************************************************
#> %config = ReadConfig($filename)
#  -------------------------------
#  \param[in] $filename   Configuration file
#  \return                Hash of keys and values
#
#  Reads a configuration file returning a hash containing the keys and
#  values. 
#  The code looks first for the config file using the specified filename
#  (which may include a full path) and if that fails, looks in the 
#  directory in which the script lives.
#
#  The code ignores any optional 'export' keywords at the start
#  of a line for BASH compatibility. Configuration variables are set
#  using a line of the form
#     key = value
#  The spaces around the '=' are optional and the value may be contained
#  in double inverted commas
#  The value can contain a previously-set variable, but this must be
#  enclosed in {}. For example:
#     key = ${prevvalue}/value
#  Previously set values may be set within the confirguration file or
#  may be environment variables set elsewhere.
#
#  29.04.15 Original   By: ACRM
sub ReadConfig
{
    my($file) = @_;
    my %config = ();

    if(! -e $file)
    {
        $file = "$FindBin::Bin/$file";
        if(! -e $file)
        {
            utils::mydie("Config file does not exist: $file", 0);
        }
    }

    if(open(my $fp, '<', $file))
    {
        my $lineNum = 0;
        while(my $line = <$fp>)
        {
            $lineNum++;
            chomp $line;
            $line =~ s/\#.*//;        # Remove comments
            $line =~ s/^\s+//;        # Remove leading spaces
            $line =~ s/^export\s+//i; # Remove leading 'export'
            $line =~ s/\s+$//;        # Remove trailing spaces
            if(length($line))
            {
                if($line =~ /(.*)\s*=\s*(.*)/)
                {
                    my $key   = $1;
                    my $value = $2;
                    SetConfig(\%config, $key, $value, $lineNum);
                }
                else
                {
                    utils::mydie("Config file not in x=y format", $lineNum);
                }
            }
        }
        close $fp;
    }
    else
    {
        utils::mydie("Couldn't open file for reading: $file", 0);
    }

    return(%config);
}

#*************************************************************************
#> ExportConfig(%config)
#  ---------------------
#  \param[in]   %config   Configuration hash
#
#  Exports all values in the config file to the environment
#
#  29.04.15  Original   By: ACRM
#
sub ExportConfig
{
    my(%config) = @_;
    foreach my $key (keys %config)
    {
        $ENV{$key} = $config{$key};
    }
}

#*************************************************************************
#> SetConfig($hConfig, $key, $value, $lineNum)
#  -------------------------------------------
#  \param[out]   $hConfig    Reference to config hash
#  \param[in]    $key        Key in config hash
#  \param[in]    $value      Value in config hash
#  \param[in]    $lineNum    Line number of config file that is being
#                            read (or 0)
#
#  Sets a configuration value in the config hash. The code expands any
#  variables of the form ${variable} taking these first from previous
#  config settings and if this fails from environment variables
#
#  This routine is not normally used by calling code.
#
#  29.04.15 Original   By: ACRM
#
sub SetConfig
{
    my($hConfig, $key, $value, $lineNum) = @_;

    $value =~ s/^\"//;          # Remove inverted commas at the start
    $value =~ s/^\'//;
    $value =~ s/\"$//;          # Remove inverted commas at the end
    $value =~ s/\'$//;

    while($value =~ /(\${.*?})/) # Value contains a variable
    {
        my $subkey = $1;
        my $subval = '';
        $subkey =~ s/\${//;     # Remove ${
        $subkey =~ s/}//;       # Remove }
        if(!defined($$hConfig{$subkey}))
        {
            if(defined($ENV{$subkey}))
            {
                $subval = $ENV{$subkey};
            }
            else
            {
                utils::mydie("Value has not been defined in config file or environment: '$subkey'",
                             $lineNum);
            }
        }
        else
        {
            $subval = $$hConfig{$subkey};
        }
        $value =~ s/\${$subkey}/$subval/g;
    }

    $$hConfig{$key} = $value;
}

1;
