
/*------------------------------------------------------------------------
    File        : correctStatus.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : paul.hoskins
    Created     : Wed Oct 28 05:30:08 GMT 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FOR EACH Issue EXCLUSIVE-LOCK:
    IF NUM-ENTRIES(Issue.StatusCode) > 1
    THEN Issue.StatusCode = ENTRY(1,Issue.StatusCode).
       
END.
