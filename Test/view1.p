
/*------------------------------------------------------------------------
    File        : view1.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : paula
    Created     : Sat Feb 20 08:44:26 GMT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


FOR EACH Customer NO-LOCK
WHERE companycode = "OURITDEPT"
AND (viewaction) WITH DOWN STREAM-IO WIDTH 255:
    
    DISPLAY companycode accountnumber NAME viewaction viewactivity.
    
    
END.