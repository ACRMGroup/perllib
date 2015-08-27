#*************************************************************************
#
#   Program:    
#   File:       ParseConfigFile.pm
#   
#   Version:    V1.0
#   Date:       24.02.11
#   Function:   Parse a .ini style config file
#   
#   Copyright:  (c) UCL / Dr. Andrew C. R. Martin 2011
#   Author:     Dr. Andrew C. R. Martin
#   Address:    Biomolecular Structure & Modelling Unit,
#               Department of Biochemistry & Molecular Biology,
#               University College,
#               Gower Street,
#               London.
#               WC1E 6BT.
#   EMail:      andrew@bioinf.org.uk
#               martin@biochem.ucl.ac.uk
#   Web:        http://www.bioinf.org.uk/
#               
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
#
#*************************************************************************
#
#   Usage:
#   ======
#   use ParseConfigFile;
#   %config = ParseConfigFile($filename, $section);
#
#*************************************************************************
#
#   Revision History:
#   =================
#   V1.0   24.02.11  Original
#
#*************************************************************************
# ParseConfigFile($filename, $section)
# ------------------------------------
# Parses a .ini style config file which consists of
# [DEFAULT]
# var=value
# ...
# [section]
# var=value
# ...
# The code reads all var/value pairs from the DEFAULT block and then from
# the specified section. Variables specified in the file may be used within 
# a value - these are of the form:
# var=xxx%(othervar)sxxx
# These are replaced iteratively so replacement variables may contain other
# variables and there is no need to specify the replacements before where
# they are used.
#
# 24.02.11 Original   By: ACRM
#
sub ParseConfigFile
{
    my($fnm, $section) = @_;
    my %config = ();
    my $inSection = 0;
    my $replacedSomething = 0;

    open(FNM, $fnm) || die "Can't read config file: $fnm";
    while(<FNM>)
    {
        if(/\[DEFAULT\]/ || /\[$section\]/)
        {
            $inSection = 1;
        }
        elsif(/\[/)
        {
            $inSection = 0;
        }
        elsif($inSection)
        {
            s/^\s+//;           # Remove leading whitespace
            s/\s+$//;           # Remove trailing whitespace
            s/\s+=\s+/=/;       # Remove whitespace around = sign
            s/\;.*//;           # Remove comments
            s/\#.*//;           # Remove comments
            if(/(.*)=(.*)/)     # If any assignment remains, store it
            {
                $config{$1} = $2;
            }
        }
    }
    close(FNM);

    # Replace any variables used in the configuration. These are delimited
    # by %(varname)s
    # Replacement code is iterative to allow replacements themselves to
    # contain variables
    do
    {
        $replacedSomething = 0;
        foreach my $key (keys %config)
        {
            # Regex: xxxx%(varname)sxxxx
            if($config{$key} =~ /(.*)\%\((.*?)\)s(.*)/)
            {
                $config{$key} = $1 . $config{$2} . $3;
                $replacedSomething = 1;
            }
        }
        
    }   while($replacedSomething);

    return(%config);
}

1;
