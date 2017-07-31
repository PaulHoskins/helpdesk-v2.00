
/*------------------------------------------------------------------------
    File        : fix-activity-st-date.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Mon Jul 31 17:20:42 BST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


OUTPUT TO c:\temp\fx-act.txt UNBUFFERED.


FOR EACH Issue NO-LOCK
    WHERE Issue.CompanyCode = "OURITDEPT"
    /*
    AND  Issue.IssueNumber = 28062
    */
    AND issue.issuedate < 01/01/2017
    WITH FRAME FLOG DOWN STREAM-IO WIDTH 255 :


    FOR EACH IssAction NO-LOCK 
        WHERE issaction.companycode = Issue.CompanyCode 
        AND issaction.issuenumber = Issue.IssueNumber
        /*AND issaction.ActionStatus = "CLOSED" */
        WITH FRAME FLOG DOWN STREAM-IO WIDTH 255 :



    
        FOR EACH IssActivity
            WHERE issActivity.CompanyCode = ISSUE.CompanyCode
            AND issActivity.IssueNumber = ISSUE.IssueNumber
            AND IssActivity.IssActionId = ISSACTION.IssActionID
            AND STARTdate = ?


            WITH FRAME FLOG DOWN STREAM-IO WIDTH 255 :


          

            DISPLAY  issue.issueNumber ISSUE.ISSUeDATE issaction.ActionDate issaction.ActionStatus
                IssActivity.IssActionId STARTdate enddate ActDescription.

            .
            STARTdate = issaction.ActionDate.
            startTime = TIME.

            enddate = issaction.ActionDate.
            EndTIME = TIME.

            IF ActDescription = ""
                THEN ActDescription = "Data Fix".



            DOWN.

          
        END. 
       

    END.
    

         
         
            
END.         
