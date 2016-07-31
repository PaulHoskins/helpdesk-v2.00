
/*------------------------------------------------------------------------
    File        : upgrade-crm.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Paul
    Created     : Sun Jul 24 08:14:24 BST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


FOR EACH Customer EXCLUSIVE-LOCK:
    
    IF Customer.IsActive
    THEN Customer.accStatus = "Active".
    ELSE Customer.accStatus = "Ex-Customer".
    
   
      
END.