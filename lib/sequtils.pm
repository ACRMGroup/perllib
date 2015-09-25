package sequtils;
#*************************************************************************
#
#   Program:    
#   File:       sequtils.pm
#   
#   Version:    V1.0
#   Date:       25.09.15
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
%throneHash = (
    'ALA' => 'A',
    'CYS' => 'C',
    'ASP' => 'D',
    'GLU' => 'E',
    'PHE' => 'F',
    'GLY' => 'G',
    'HIS' => 'H',
    'ILE' => 'I',
    'LYS' => 'K',
    'LEU' => 'L',
    'MET' => 'M',
    'ASN' => 'N',
    'PRO' => 'P',
    'GLN' => 'Q',
    'ARG' => 'R',
    'SER' => 'S',
    'THR' => 'T',
    'VAL' => 'V',
    'TRP' => 'W',
    'TYR' => 'Y',
    );

#*************************************************************************
sub throne
{
    my ($three) = @_;
    return($three) if(length($three) == 1); # 1-letter code already

    if(defined($throneHash{$three}))
    {
        return($throneHash{$three});
    }

    return('X');
}

#*************************************************************************
sub sortResids
{
    my @resids = @_;

    return(sort residSortFunc @resids);
}

#*************************************************************************
sub parseResid
{
    my($resid) = @_;
    $resid =~ /([LH])(\d+)([A-Za-z]?)/;
    return($1, $2, $3);
}

#*************************************************************************
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
