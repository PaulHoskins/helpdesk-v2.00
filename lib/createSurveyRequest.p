/***********************************************************************

    Program:        lib/createSurveyRequest.p
    
    Purpose:        Creates a Survey and sends the email       
    
    Notes:
    
    
    When        Who         What
    22/04/2006  phoski      Initial
    
***********************************************************************/
DEFINE INPUT PARAMETER pc-companyCode   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-acs_code      AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pi-IssueNumber   AS INTEGER   NO-UNDO.
DEFINE INPUT PARAMETER pc-LoginID       AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-Email         AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pl-Test          AS LOGICAL   NO-UNDO.
DEFINE OUTPUT PARAMETER pc-Error        AS CHARACTER NO-UNDO.
 
{lib/common.i}
{lib/maillib.i}
{iss/issue.i}

DEFINE BUFFER acs_head  FOR acs_head.
DEFINE BUFFER acs_line  FOR acs_line.
DEFINE BUFFER company   FOR Company.
DEFINE BUFFER acs_rq    FOR acs_rq.
DEFINE BUFFER Issue     FOR Issue.
DEFINE BUFFER IssAction FOR IssAction.

DEFINE VARIABLE lc-id       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Link     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-subj     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-body     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-temp     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error    AS CHARACTER NO-UNDO.


FIND Company WHERE Company.CompanyCode = pc-companyCode NO-LOCK.

FIND acs_head 
    WHERE acs_head.CompanyCode = pc-CompanyCode
    AND acs_head.acs_code = pc-acs_code NO-LOCK NO-ERROR.
        
        
IF NOT AVAILABLE acs_head THEN RETURN.
    
FIND Issue WHERE Issue.CompanyCode = pc-companyCode
    AND Issue.IssueNumber = pi-issueNumber
    NO-LOCK NO-ERROR.
             
RUN ipCreateRequest ( OUTPUT lc-id ).


FIND acs_rq WHERE acs_rq.rq_id = lc-id EXCLUSIVE-LOCK.

ASSIGN 
    lc-link = Company.HelpDeskLink + "/sys/surveycomplete.p?request="  + lc-id.

ASSIGN
    lc-subj = acs_head.em_subject
    lc-body = "".
    
              
RUN lib/translatetemplate.p 
    (
    Issue.company,
    "None",
    Issue.issueNumber,
    pl-test,
    acs_head.em_begin,
    OUTPUT lc-temp,
    OUTPUT lc-error
    ).
            
       
ASSIGN 
    lc-body = lc-temp  + '~n~n' +
              substitute('<a href="&2">&1</a>',
                          "Click here to complete the survey",
                          lc-Link ) + '~n~n'.
.
 
                                   
RUN lib/translatetemplate.p 
    (
    Issue.company,
    "None",
    Issue.issueNumber,
    pl-test,
    acs_head.em_end,
    OUTPUT lc-temp,
    OUTPUT lc-error
    ).
            
    
ASSIGN 
    lc-body = lc-body + lc-temp.
           
              
DYNAMIC-FUNCTION("mlib-SendEmail",
    pc-companyCode,
    DYNAMIC-FUNCTION("com-GetHelpDeskEmail","From",Issue.company,Issue.AccountNumber),
    lc-subj,
    lc-body,
    pc-email). 


RUN islib-CreateNote( Issue.CompanyCode,
                    Issue.IssueNumber,
                    "SYSTEM",
                    "SYS.MISC",
                    "Created Survey " + acs_rq.rq_id + " " + acs_head.descr + " For " + pc-email).
                    
    
    

/* **********************  Internal Procedures  *********************** */

PROCEDURE ipCreateRequest:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc_rq_id    AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE MyUUID      AS RAW       NO-UNDO.
    DEFINE VARIABLE cGUID       AS CHARACTER NO-UNDO.
    
            
    ASSIGN  
        MyUUID = GENERATE-UUID  
        cGUID  = GUID(MyUUID). 
    
    CREATE acs_rq.

    ASSIGN
        acs_rq.acs_code = pc-acs_code
        acs_rq.CompanyCode = pc-CompanyCode
        acs_rq.Email = pc-email
        acs_rq.IssueNumber = pi-issueNumber
        acs_rq.LoginID = pc-loginId
        acs_rq.eng-loginid = Issue.AssignTo
        acs_rq.rq_status = 0
        acs_rq.rq_id = cGuid
        acs_rq.rq_created = NOW.
       
    /*
    *** Last Engineer
    */
    FOR EACH IssAction NO-LOCK OF Issue,
        FIRST WebAction NO-LOCK
            WHERE WebAction.CompanyCode = Issue.CompanyCode
              AND WebAction.ActionID = IssAction.ActionID
              AND WebAction.ActionClass = "ENG"
              BY IssAction.CreateDate
              BY IssAction.CreateTime
              :
        ASSIGN
            acs_rq.eng-loginid = IssAction.AssignTo.
                   
    END.
                    
    
    pc_rq_id = acs_rq.rq_id.
    
    


END PROCEDURE.
