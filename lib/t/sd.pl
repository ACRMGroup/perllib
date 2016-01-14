#!/usr/bin/perl
use sd;
my $Sx      = 0;
my $SxSq    = 0;
my $NValues = 0;
my $mean    = 0;
my $sd      = 0;
my @values  = (1, 2, 3, 4, 5, 6);
foreach my $value (@values)
{
   sd::CalcExtSD($value, 0, \$Sx, \$SxSq, \$NValues, \$mean, \$sd);
}
sd::CalcExtSD(0, 1, \$Sx, \$SxSq, \$NValues, \$mean, \$SD);
printf "ExtSD: mean=%.3f SD=%.3f\n", $mean,  $SD;

($SD, $mean) = sd::CalcSD(@values);
printf "IntSD: mean=%.3f SD=%.3f\n", $mean,  $SD;
