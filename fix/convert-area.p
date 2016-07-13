for each webissarea where companyCode = "ouritdept".

    
    if AreaCode <= "100" 
    then GroupID = "100".
    else
    if AreaCode <= "19"
    then GroupID = "200".
    else
    if AreaCode <= "64"
    then GroupID = "300".
    else
    if AreaCode <= "84"
    then GroupID = "400".
    else
    if AreaCode <= "95"
    then GroupID = "500".
    else
    if AreaCode <= "983"
    then GroupID = "600".

end.
