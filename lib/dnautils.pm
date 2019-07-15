package dnautils;

#*************************************************************************
#
#   File:       dnautils.pm
#   
#   Version:    V1.1
#   Date:       15.07.19
#   Function:   DNA translation and reverse complement
#   
#   Copyright:  (c) UCL, Prof. Andrew C. R. Martin, 2016-2019
#   Author:     Prof. Andrew C. R. Martin
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
#   V1.0   01.02.16   Original   By: ACRM
#   V1.1   15.07.19   Extracted from dna2aa.pl
#
#*************************************************************************
# Add the path of the executable to the library path
#use FindBin;
#use lib $FindBin::Bin;
# Or if we have a bin directory and a lib directory
#use Cwd qw(abs_path);
#use FindBin;
#use lib abs_path("$FindBin::Bin/lib");
use strict;

# Initialize coding table
%dnautils::codons = (
    'TTT' => 'F',    'TTC' => 'F',    'TTA' => 'L',    'TTG' => 'L',
    'TCT' => 'S',    'TCC' => 'S',    'TCA' => 'S',    'TCG' => 'S',
    'TAT' => 'Y',    'TAC' => 'Y',    'TAA' => '*',    'TAG' => '*',
    'TGT' => 'C',    'TGC' => 'C',    'TGA' => '*',    'TGG' => 'W',
    'CTT' => 'L',    'CTC' => 'L',    'CTA' => 'L',    'CTG' => 'L',
    'CCT' => 'P',    'CCC' => 'P',    'CCA' => 'P',    'CCG' => 'P',
    'CAT' => 'H',    'CAC' => 'H',    'CAA' => 'Q',    'CAG' => 'Q',
    'CGT' => 'R',    'CGC' => 'R',    'CGA' => 'R',    'CGG' => 'R',
    'ATT' => 'I',    'ATC' => 'I',    'ATA' => 'I',    'ATG' => 'M',
    'ACT' => 'T',    'ACC' => 'T',    'ACA' => 'T',    'ACG' => 'T',
    'AAT' => 'N',    'AAC' => 'N',    'AAA' => 'K',    'AAG' => 'K',
    'AGT' => 'S',    'AGC' => 'S',    'AGA' => 'R',    'AGG' => 'R',
    'GTT' => 'V',    'GTC' => 'V',    'GTA' => 'V',    'GTG' => 'V',
    'GCT' => 'A',    'GCC' => 'A',    'GCA' => 'A',    'GCG' => 'A',
    'GAT' => 'D',    'GAC' => 'D',    'GAA' => 'E',    'GAG' => 'E',
    'GGT' => 'G',    'GGC' => 'G',    'GGA' => 'G',    'GGG' => 'G');
    

#*************************************************************************
#>$bestTrans = translateSixFrames($seq)
# -------------------------------------
# Input:  $seq   DNA sequence
# Return:        Best sequence from 6FT
#
# Translate DNA to AA sequence in all 6 frames and choose the longest 
# reading frame
#
# 01.02.16 Original   By: ACRM
sub translateSixFrames
{
    my($seqIn) = @_;
    my $bestTrans = '';

    $bestTrans = translateThreeFrames($seqIn);
    $seqIn     = reverseComplement($seqIn);
    my $rTrans = translateThreeFrames($seqIn);
    if(length($rTrans) > length($bestTrans))
    {
        $bestTrans = $rTrans;
    }

    return($bestTrans);
}


#*************************************************************************
#>$rc = reverseComplement($seq)
# -----------------------------
# Input:   $seq    DNA sequence
# Return:          Reverse complement of sequence
#
# Find the reverse complement of a sequence
#
# 01.02.16 Original   By: ACRM
sub reverseComplement
{
    my($seq) = @_;

    $seq = reverse($seq);

    $seq =~ s/a/x/g;
    $seq =~ s/t/a/g;
    $seq =~ s/x/t/g;

    $seq =~ s/c/x/g;
    $seq =~ s/g/c/g;
    $seq =~ s/x/g/g;

    $seq =~ s/A/X/g;
    $seq =~ s/T/A/g;
    $seq =~ s/X/T/g;

    $seq =~ s/C/X/g;
    $seq =~ s/G/C/g;
    $seq =~ s/X/G/g;

    return($seq);
}


#*************************************************************************
#>$aa = codon2aa($codon)
# ----------------------
# Input:   $codon    3-character codon (upper or lower case)
# Return:            1-letter amino acid or '!' if not a valid codon
#
# Convert a codon to an amino acid (1-letter code)
# Returns '!' if an unknown codon is given
#
# 01.02.16 Original   By: ACRM
sub codon2aa
{
    my($codon) = @_;
    $codon = "\U$codon";
    return($dnautils::codons{$codon}) if(defined($dnautils::codons{$codon}));
    return('!');
}


#*************************************************************************
#>$aaSeq = translateThreeFrames($dnaSeq)
# --------------------------------------
# Input:   $dnaSeq     DNA sequence
# Return:              Amino acid sequence (1-letter code)
#
# Perform a 3-frame translation, selecting the longest ORF
#
# 01.02.16 Original   By: ACRM
sub translateThreeFrames
{
    my($seqIn)    = @_;
    my $bestTrans = '';

    # Three forward reading frames
    for(my $frame=0; $frame<3; $frame++)
    {
        my $gotMet    = 0;
        my $thisTrans = '';

        # Step along three bases at a time
        for(my $offset=0; ($offset+$frame) < length($seqIn); $offset+=3)
        {
            # If at the start of the sequence, don't worry about needing a Met
            $gotMet = 1 if(($offset+$frame) < 4);

            # Find the amino acid 1 letter code
            my $aa = codon2aa(substr($seqIn, $offset+$frame, 3));
            if($aa eq '*')      # Stop codon
            {
                if($gotMet)
                {
                    print STDERR "TRANS($frame/$offset): $thisTrans\n" if(defined($::debug));
                    if(length($thisTrans) > length($bestTrans))
                    {
                        $bestTrans = $thisTrans;
                    }
                }
                $thisTrans = '';
            }
            else
            {
                $gotMet = 1 if($aa eq "M");
                if($gotMet)
                {
                    $thisTrans .= $aa;
                }
            }
        }

        # Sequence has run out
        if($gotMet)
        {
            print STDERR "TRANS($frame/?): $thisTrans\n" if(defined($::debug));
            if(length($thisTrans) > length($bestTrans))
            {
                $bestTrans = $thisTrans;
            }
        }
    }
    return($bestTrans);
}


#*************************************************************************
#>$aaSeq = translate($dnaSeq, $startFromMet)
# ------------------------------------------
# Input:   $dnaSeq        DNA sequence
#          $startFromMet  Start from first methionine rather than first 
#                         codon
# Return:                 Amino acid sequence (1-letter code)
#
# Perform a 1-frame translation
#
# 15.07.19 Original   By: ACRM
sub translate
{
    my($seqIn, $startFromMet) = @_;

    my $gotMet      = 0;
    my $translation = '';

    # Step along three bases at a time
    for(my $offset=0; ($offset) < length($seqIn); $offset+=3)
    {
        # Find the amino acid 1 letter code
        my $aa = codon2aa(substr($seqIn, $offset, 3));
        if($aa eq '*')      # Stop codon
        {
            last;
        }
        else
        {
            if($aa eq "M")
            {
                $gotMet = 1;
            }
            
            if($gotMet || !$startFromMet)
            {
                $translation .= $aa;
            }
        }
    }
    
    return($translation);
}


#*************************************************************************
#>$isdna = IsDNA($seq)
# --------------------
# Input:   $seq    sequence
# Return:          True:  the sequence was DNA or RNA
#                  False: not DNA/RNA
#
# Tests if a sequence is DNA. We replace DNA/RNA symbols by nothing and
# see if there is anything left in the sequence. If there is then it 
# cannot be DNA. Ambiguity symbols are also allowed
#
# 01.02.16 Original   By: ACRM
sub IsDNA
{                               
    my($seq) = @_;
    $seq =~ s/[atcguATCGU]//g;                 # DNA
    $seq =~ s/[bdhikmnrsvwxyBDHIKMNRSVWXY]//g; # Ambiguity codes
    $seq =~ s/[\s\-\.\*]//g;                   # Deletions etc
    if(length($seq))
    {
        return(0);
    }
    return(1);
}

1;
