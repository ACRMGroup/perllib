package translate;
#*************************************************************************
#
#   Program:    
#   File:       translate.pm
#   
#   Version:    V1.0
#   Date:       17.03.17
#   Function:   
#   
#   Copyright:  (c) Dr. Andrew C. R. Martin, UCL, 2017
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
#   V1.0   17.03.17 Original   By: ACRM
#
#*************************************************************************
%translateHash = (
    'ttt' => 'F',
    'ttc' => 'F',
    'tta' => 'L',
    'ttg' => 'L',
    'tct' => 'S',
    'tcc' => 'S',
    'tca' => 'S',
    'tcg' => 'S',
    'tat' => 'Y',
    'tac' => 'Y',
    'taa' => '*',
    'tag' => '*',
    'tgt' => 'C',
    'tgc' => 'C',
    'tga' => '*',
    'tgg' => 'W',

    'ctt' => 'L',
    'ctc' => 'L',
    'cta' => 'L',
    'ctg' => 'L',
    'cct' => 'P',
    'ccc' => 'P',
    'cca' => 'P',
    'ccg' => 'P',
    'cat' => 'H',
    'cac' => 'H',
    'caa' => 'Q',
    'cag' => 'Q',
    'cgt' => 'R',
    'cgc' => 'R',
    'cga' => 'R',
    'cgg' => 'R',

    'att' => 'I',
    'atc' => 'I',
    'ata' => 'I',
    'atg' => 'M',
    'act' => 'T',
    'acc' => 'T',
    'aca' => 'T',
    'acg' => 'T',
    'aat' => 'D',
    'aac' => 'D',
    'aaa' => 'K',
    'aag' => 'K',
    'agt' => 'S',
    'agc' => 'S',
    'aga' => 'R',
    'agg' => 'R',

    'gtt' => 'V',
    'gtc' => 'V',
    'gta' => 'V',
    'gtg' => 'V',
    'gct' => 'A',
    'gcc' => 'A',
    'gca' => 'A',
    'gcg' => 'A',
    'gat' => 'D',
    'gac' => 'D',
    'gaa' => 'E',
    'gag' => 'E',
    'ggt' => 'G',
    'ggc' => 'G',
    'gga' => 'G',
    'ggg' => 'G'
    );

#*************************************************************************
sub translateOne
{
    my ($dna) = @_;

    $dna = "\L$dna";                        # Downcase
    $dna =~ s/\s//g;                        # Remove spaces
    $dna =~ s/u/t/g;                        # u -> t

    my $aaSeq = '';
    for(my $i=0; $i<length($dna); $i+=3)
    {
        my $codon = substr($dna, $i, 3);
        if(defined($translateHash{$codon}))
        {
            $aaSeq .= $translateHash{$codon};
        }
        else
        {
            $aaSeq .= '?';
        }
    }
    
    return($aaSeq);
}


#*************************************************************************
sub translateThree
{
    my ($dna) = @_;

    $dna = "\L$dna";                        # Downcase
    $dna =~ s/\s//g;                        # Remove spaces
    $dna =~ s/u/t/g;                        # u -> t

    my @aaSeq   = ();
    my $bestSeq = 0;
    my $bestLen = 0;
    for(my $frame=0; $frame<3; $frame++)
    {
        $aaSeq[$frame] = '';

        for(my $i=0; $i<length($dna); $i+=3)
        {
            my $codon = substr($dna, $i, 3);
            if(defined($translateHash{$codon}))
            {
                $aaSeq[$frame] .= $translateHash{$codon};
            }
            else
            {
                $aaSeq[$frame] .= '?';
            }
        }

        my $testSeq = $aaSeq[$frame];
        $testSeq =~ s/\*.*//;
        if(length($testSeq) > $bestLen)
        {
            $bestLen = length($testSeq);
            $bestSeq = $frame;
        }
    }
    
    return($aaSeq[$bestSeq]));
}


1;
