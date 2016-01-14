package sd;

sub CalcSD
{
    my(@values) = @_;
    my $nvals = @values;
    my $sum = 0;

    # Calculate the mean
    for(my $i=0; $i<$nvals; $i++)
    {
        $sum += $values[$i];
    }
    my $mean = $sum / $nvals;
    
    # Calculate the sum of squares
    $sum = 0;
    for(my $i=0; $i<$nvals; $i++)
    {
        $sum += (($values[$i] - $mean)*($values[$i] - $mean));
    }
    # and divide by n-1 then square root
    my $sd = sqrt($sum/($nvals-1));
    return($sd, $mean);
}

sub CalcExtSD
{
    my($val, $action, $pSx, $pSxSq, $pNValues, $pMean, $pSD) = @_;

    if($action == 0)
    {
       ($$pNValues)++;
       $$pSxSq += ($val * $val);
       $$pSx   += $val;
    }
    elsif($action == 1)
    {
       $$pMean = $$pSD = 0.0;
       if($$pNValues > 0)
       {
          $$pMean = ($$pSx) / ($$pNValues);
       }
       if($$pNValues > 1)
       {
          $$pSD   = sqrt(($$pSxSq - (($$pSx) * ($$pSx)) / ($$pNValues)) /
                       ($$pNValues - 1));
       }
    }
    elsif($action == 2)
    {
       $$pSxSq = 0.0;
       $$pSx   = 0.0;
       $$pNValues = 0;
    }
}

1;
