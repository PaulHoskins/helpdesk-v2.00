/***********************************************************************

    Program:        batch/issuecheck.p
   
    Purpose:        Upgrade
    
    Notes:
    
    
    When        Who         What
    22/07/2017  phoski      Initial
   
***********************************************************************/


{iss/issue.i}

OUTPUT TO c:\temp\issuecheck.log.

   
FOR EACH Customer EXCLUSIVE-LOCK WITH DOWN STREAM-IO WIDTH 255:

    PAUSE 0.
    DISPLAY Customer.CompanyCode Customer.AccountNumber Customer.Name.
    DOWN.
    RUN cust/lib/mainsite.p ( ROWID(customer)).
       
END.
    

FOR EACH Issue EXCLUSIVE-LOCK WITH DOWN STREAM-IO WIDTH 255:
    
    Issue.i-open = DYNAMIC-FUNCTION("islib-IssueIsOpen",ROWID(Issue)).
    
    PAUSE 0.
    DISPLAY NOW Issue.CompanyCode Issue.IssueNumber Issue.i-open issue.statuscode  Issue.i-st-num Issue.i-AccountManager.


    
END.
    


