/***********************************************************************

    Program:        iss/issue.i
    
    Purpose:        Issue Library        
    
    Notes:
    
    
    When        Who         What
    10/04/2006  phoski      CompanyCode   
    11/04/2006  phoski      Customer Tracking   
    
    20/06/2011  DJS         Changed to send HTML email 
                            rather than attached PDF
    15/08/2015  phoski      Default alert to def-stat-loginid
    20/10/2015  phoski      com-GetHelpDeskEmail for email sender
***********************************************************************/

{lib/maillib.i}
{lib/princexml.i}




/* ********************  Preprocessor Definitions  ******************** */





/* ************************  Function Prototypes ********************** */

FUNCTION islib-AssignChanged RETURNS LOGICAL
    ( pr-rowid    AS ROWID,
    pc-loginID    AS CHARACTER,
    pc-old-assign AS CHARACTER,
    pc-new-assign AS CHARACTER )  FORWARD.


FUNCTION islib-CloseDate RETURNS DATE
    ( pr-rowid    AS ROWID)  FORWARD.


FUNCTION islib-CloseOfIssue RETURNS LOGICAL
    ( pc-LoginId AS CHARACTER ,
    pr-rowid AS ROWID )  FORWARD.


FUNCTION islib-CreateAutoAction RETURNS LOGICAL
    ( pf-IssActionID AS DECIMAL )  FORWARD.


FUNCTION islib-DefaultActions RETURNS LOGICAL
    ( pc-companyCode  AS CHARACTER,
    pi-Issue        AS INTEGER )  FORWARD.


FUNCTION islib-IssueIsOpen RETURNS LOGICAL
    ( pr-rowid    AS ROWID)  FORWARD.


FUNCTION islib-OutsideSLA RETURNS LOGICAL
    ( pr-rowid    AS ROWID
    )  FORWARD.


FUNCTION islib-RemoveAlerts RETURNS LOGICAL
    ( pr-rowid AS ROWID )  FORWARD.


FUNCTION islib-SLAChanged RETURNS LOGICAL
    ( pr-rowid    AS ROWID,
    pc-loginID    AS CHARACTER,
    pf-old-SLAID AS DECIMAL,
    pf-new-SLAID AS DECIMAL )  FORWARD.


FUNCTION islib-StatusIsClosed RETURNS LOGICAL
    ( pc-CompanyCode AS CHARACTER,
    pc-StatusCode AS CHARACTER )  FORWARD.


FUNCTION islib-WhoToAlert RETURNS CHARACTER
    ( pc-CompanyCode      AS CHARACTER,
    pi-IssueNumber      AS INTEGER )  FORWARD.



/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Include ASSIGN
         HEIGHT             = 15
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */

 




/* ***************************  Main Block  *************************** */



/* **********************  Internal Procedures  *********************** */

PROCEDURE islib-CreateNote :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-CompanyCode  AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pi-IssueNumber  AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER pc-user AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pc-code AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pc-note AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-status FOR IssNote.
    
    CREATE b-status.
    ASSIGN 
        b-status.CompanyCode = pc-CompanyCode
        b-status.IssueNumber = pi-IssueNumber
        b-status.LoginId     = pc-user
        b-status.CreateDate  = TODAY
        b-status.CreateTime  = TIME
        b-status.NoteCode    = pc-Code
        b-status.Contents    = pc-note
        .
       
    RETURN.
END PROCEDURE.


PROCEDURE islib-StatusHistory :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-CompanyCode      AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pi-IssueNumber      AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER pc-user             AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pc-old-statuscode   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pc-new-statuscode   AS CHARACTER NO-UNDO.

    DEFINE BUFFER IssStatus FOR IssStatus.
    DEFINE BUFFER Issue     FOR Issue.
    DEFINE BUFFER WebStatus FOR WebStatus.
    DEFINE BUFFER WebNote   FOR WebNote.
    DEFINE BUFFER WebUser   FOR WebUser.
    DEFINE BUFFER Company   FOR Company.
    DEFINE BUFFER customer  FOR Customer.
    

    DEFINE VARIABLE lc-loginid AS CHARACTER NO-UNDO.
        
    DEFINE VARIABLE lc-text    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-Time    AS INTEGER NO-UNDO.
        
    DEFINE VARIABLE lc-html    AS CHARACTER NO-UNDO.  /* Added for HTML emails */
    DEFINE VARIABLE lc-header  AS CHARACTER NO-UNDO.  /* Added for HTML emails */

    DO WHILE TRUE:
        li-Time = TIME.
            
        FIND IssStatus WHERE IssStatus.CompanyCode   = pc-CompanyCode
                         AND IssStatus.IssueNumber   = pi-IssueNumber
                         AND IssStatus.ChangeDate    = TODAY
                         AND IssStatus.ChangeTime    = li-Time NO-LOCK NO-ERROR.
        IF AVAILABLE IssStatus THEN
        DO:
            MESSAGE "DEBUG Duplicate IssStatus " pc-CompanyCode pi-IssueNumber TODAY li-time.
            PAUSE 1 NO-MESSAGE.
            NEXT.
        END.
        
        CREATE IssStatus.
        ASSIGN 
            IssStatus.CompanyCode   = pc-CompanyCode
            IssStatus.IssueNumber   = pi-IssueNumber
            IssStatus.LoginId       = pc-user
            IssStatus.ChangeDate    = TODAY
            IssStatus.ChangeTime    = li-Time
            IssStatus.OldStatusCode = pc-old-StatusCode
            IssStatus.NewStatusCode = pc-new-StatusCode
            .
         LEAVE.
    END.
    
    FIND Issue
        WHERE Issue.companycode = pc-CompanyCode
        AND Issue.IssueNumber = pi-IssueNumber
        NO-LOCK NO-ERROR.

    IF AVAILABLE issue THEN
    DO:
        lc-loginid = DYNAMIC-FUNCTION('islib-WhoToAlert':U,Issue.CompanyCode,Issue.IssueNumber).
        
        FIND Customer WHERE Customer.CompanyCode = Issue.CompanyCode
                        AND Customer.AccountNumber = Issue.AccountNumber NO-LOCK NO-ERROR.
        IF Customer.def-stat-loginid <> "" THEN
        DO:
            FIND WebUser 
                WHERE webUser.LoginID = Customer.def-stat-loginid NO-LOCK NO-ERROR.
                
            FIND company WHERE company.CompanyCode = pc-companycode NO-LOCK NO-ERROR.



            RUN prince/issstatusxml.p   /* Changed for HTML emails  - was  issstatus.p */
                (
                pc-companyCode,
                pi-IssueNumber,
                "CUSTOMER",
                OUTPUT lc-text, /* Changed for HTML emails - was lc-pdf */
                OUTPUT lc-html  /* Added for HTML emails */
                ).


            lc-header =  DYNAMIC-FUNCTION("pxml-Email-Header", pc-companycode).  /* Added for HTML emails */


            DYNAMIC-FUNCTION("mlib-SendMultipartEmail",
                pc-companycode,
                DYNAMIC-FUNCTION("com-GetHelpDeskEmail","From",issue.company,Issue.AccountNumber),
                IF pc-old-StatusCode = ""
                THEN "New Issue Raised " + string(pi-IssueNumber)
                ELSE "Status Change For Issue " + string(pi-IssueNumber)
                ,
                'Dear ' 
                + trim(WebUser.ForeName)   
                + ',~n~n' 
                + 'Please find attached details of the issue that has been logged with '
                + company.name
                + '.~n' 
                + lc-text
                ,
                lc-header
                + '<div id="content" style="border-top: 1px solid black;" ><br /><br /><br /><p>' 
                + 'Dear ' 
                + trim(WebUser.ForeName)   
                + '</p><p>' 
                + 'Please find attached details of the issue that has been logged with '
                + company.name 
                + '<p/><br />' 
                + lc-html
                ,
                WebUser.Email
                ).
            
          
            RUN islib-CreateNote
                ( pc-companyCode,
                pi-IssueNumber,
                pc-user,
                "SYS.EMAILCUST",
                "Notification of status change email sent to " + 
                trim(webUser.ForeName + " " + webUser.Surname) + 
                " at " + webuser.Email
                ).
            
            /*
            ** Dont repeat email 
            */    
            IF Customer.def-stat-loginid = lc-loginid 
            THEN lc-loginid = "".
                
        END.
                          
    END.


    IF AVAILABLE Issue
        AND lc-loginid <> "" 
        AND dynamic-function("com-StatusTrackIssue",pc-companycode,pc-new-StatusCode)
        AND dynamic-function("com-UserTrackIssue",lc-loginID)
        AND dynamic-function("com-IssueStatusAlert",pc-companyCode,issue.CreateSource,pc-new-StatusCode) THEN
    DO:
        IF CAN-FIND(WebNote
            WHERE WebNote.CompanyCode = pc-companyCode
            AND WebNote.NoteCode = "SYS.EMAILCUST" NO-LOCK) THEN
        DO:
            FIND WebUser 
                WHERE webUser.LoginID = lc-loginID NO-LOCK NO-ERROR.
            FIND company WHERE company.CompanyCode = pc-companycode NO-LOCK NO-ERROR.



            RUN prince/issstatusxml.p   /* Changed for HTML emails  - was  issstatus.p */
                (
                pc-companyCode,
                pi-IssueNumber,
                "CUSTOMER",
                OUTPUT lc-text, /* Changed for HTML emails - was lc-pdf */
                OUTPUT lc-html  /* Added for HTML emails */
                ).


            lc-header =  DYNAMIC-FUNCTION("pxml-Email-Header", pc-companycode).  /* Added for HTML emails */


            DYNAMIC-FUNCTION("mlib-SendMultipartEmail",
                pc-companycode,
                DYNAMIC-FUNCTION("com-GetHelpDeskEmail","From",issue.company,Issue.AccountNumber),
                IF pc-old-StatusCode = ""
                THEN "New Issue Raised " + string(pi-IssueNumber)
                ELSE "Status Change For Issue " + string(pi-IssueNumber)
                ,
                'Dear ' 
                + trim(WebUser.ForeName)   
                + ',~n~n' 
                + 'Please find attached details of the issue you have logged with '
                + company.name
                + '.~n' 
                + lc-text
                ,
                lc-header
                + '<div id="content" style="border-top: 1px solid black;" ><br /><br /><br /><p>' 
                + 'Dear ' 
                + trim(WebUser.ForeName)   
                + '</p><p>' 
                + 'Please find attached details of the issue you have logged with '
                + company.name 
                + '<p/><br />' 
                + lc-html
                ,
                WebUser.Email
                ).
            
            
            RUN islib-CreateNote
                ( pc-companyCode,
                pi-IssueNumber,
                pc-user,
                "SYS.EMAILCUST",
                "Status changed email sent to " + 
                trim(webUser.ForeName + " " + webUser.Surname) + 
                " at " + webuser.Email
                ).
        
        END.
    END.

    IF islib-StatusIsClosed(pc-companyCode,pc-new-StatusCode) = TRUE 
        AND islib-StatusIsClosed(pc-companyCode,pc-old-statusCode) = FALSE THEN
    DO:
        DYNAMIC-FUNCTION('islib-CloseOfIssue':U,pc-user,ROWID(Issue)).
    END.
    
    RETURN.
END PROCEDURE.


/* ************************  Function Implementations ***************** */

FUNCTION islib-AssignChanged RETURNS LOGICAL
    ( pr-rowid    AS ROWID,
    pc-loginID    AS CHARACTER,
    pc-old-assign AS CHARACTER,
    pc-new-assign AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER Issue FOR Issue.
    DEFINE VARIABLE lc-message AS CHARACTER NO-UNDO.

    IF pc-old-assign = pc-new-assign THEN RETURN TRUE.

    FIND issue
        WHERE ROWID(issue) = pr-rowid NO-LOCK NO-ERROR.

    IF NOT AVAILABLE issue THEN RETURN FALSE.


    IF CAN-FIND(WebNote
        WHERE WebNote.CompanyCode = Issue.CompanyCode
        AND WebNote.NoteCode = "SYS.ASSIGN" NO-LOCK) THEN
    DO:
        
        RUN islib-CreateNote
            ( Issue.CompanyCode,
            Issue.IssueNumber,
            pc-LoginID,
            "SYS.ASSIGN",
            'From: ' + dynamic-function("com-UserName",pc-old-assign) + '~n' +
            'To: ' + dynamic-function("com-UserName",pc-new-assign) + '~n'
            ).
        
    END.



    RETURN TRUE.


END FUNCTION.


FUNCTION islib-CloseDate RETURNS DATE
    ( pr-rowid    AS ROWID) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER issue     FOR issue.
    DEFINE BUFFER WebStatus FOR WebStatus.
    DEFINE BUFFER IssStatus FOR IssStatus.

    DEFINE VARIABLE lc-return AS DATE NO-UNDO.


    FIND issue
        WHERE ROWID(issue) = pr-rowid NO-LOCK NO-ERROR.

    IF NOT AVAILABLE issue THEN RETURN ?.

    FIND WebStatus OF Issue NO-LOCK NO-ERROR.

    IF NOT AVAILABLE WebStatus THEN RETURN ?.

    IF NOT WebStatus.CompletedStatus THEN RETURN ?.
        
    FIND FIRST IssStatus OF Issue NO-LOCK NO-ERROR.

    IF NOT AVAILABLE IssStatus THEN RETURN ?.


    RETURN IssStatus.ChangeDate.


END FUNCTION.


FUNCTION islib-CloseOfIssue RETURNS LOGICAL
    ( pc-LoginId AS CHARACTER ,
    pr-rowid AS ROWID ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER Issue     FOR Issue.
    DEFINE BUFFER IssAction FOR IssAction.
    DEFINE BUFFER WebNote   FOR WebNote.
    DEFINE BUFFER WebAction FOR WebAction.


    FIND Issue WHERE ROWID(issue) = pr-rowid NO-LOCK NO-ERROR.
    IF NOT AVAILABLE Issue THEN RETURN TRUE.

    /*** PH REMOVED
    for each IssAction
        where issAction.CompanyCode = Issue.CompanyCode
          and issAction.IssueNumber = Issue.IssueNumber
          and IssAction.ActionStatus = "OPEN":

        assign
            IssAction.ActionStatus = "CLOSED".

        if can-find(WebNote
                    where WebNote.CompanyCode = Issue.CompanyCode
                      and WebNote.NoteCode = "SYS.MISC" no-lock) then
        do:
            find WebAction
                where WebAction.ActionID = IssAction.ActionID
                no-lock no-error.
            if avail WebAction
            then RUN islib-CreateNote
                    ( Issue.CompanyCode,
                      Issue.IssueNumber,
                      pc-LoginID,
                      "SYS.MISC",
                      "Issue closed - Action automatically closed : " + WebAction.description 
                      ).
            
        end.
    end.
    ***/


    RETURN TRUE.
END FUNCTION.


FUNCTION islib-CreateAutoAction RETURNS LOGICAL
    ( pf-IssActionID AS DECIMAL ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER IssAction   FOR IssAction.
    DEFINE BUFFER b-table     FOR IssAction.
    DEFINE BUFFER WebAction   FOR WebAction.
    DEFINE BUFFER b-WebAction FOR WebAction.
    DEFINE VARIABLE lf-Audit LIKE IssAction.IssActionId NO-UNDO.


    FIND IssAction
        WHERE IssAction.IssActionID = pf-IssActionID NO-LOCK NO-ERROR.
    IF NOT AVAILABLE IssAction THEN RETURN FALSE.


    FIND b-WebAction
        WHERE b-WebAction.ActionID = IssAction.ActionID NO-LOCK NO-ERROR.
    IF NOT AVAILABLE b-WebAction THEN RETURN FALSE.
    IF b-WebAction.autoActionCode = "" THEN RETURN FALSE.
    
    FIND WebAction
        WHERE WebAction.CompanyCode = b-WebAction.CompanyCode
        AND WebAction.ActionCode  = b-WebAction.AutoActionCode
        NO-LOCK NO-ERROR.
    IF NOT AVAILABLE WebAction THEN RETURN FALSE.

    FIND FIRST b-table
        WHERE b-table.CompanyCode = WebAction.CompanyCode
        AND b-table.IssueNumber = issAction.IssueNumber
        AND b-table.ActionID    = WebAction.ActionID 
        NO-LOCK NO-ERROR.
    IF AVAILABLE b-table THEN RETURN FALSE.

    CREATE b-table.
    ASSIGN 
        b-table.IssActionID = ?.

    DO WHILE TRUE:
        RUN lib/makeaudit.p (
            "",
            OUTPUT lf-audit
            ).
        IF CAN-FIND(FIRST IssAction
            WHERE IssAction.IssActionID = lf-audit NO-LOCK)
            THEN NEXT.
        ASSIGN
            b-table.IssActionID = lf-audit.
        LEAVE.
    END.

    MESSAGE "Created Auto Action = " lf-Audit.

    ASSIGN 
        b-table.actionID     = WebAction.ActionID
        b-table.CompanyCode  = WebAction.CompanyCode
        b-table.IssueNumber  = IssAction.IssueNumber
        b-table.CreateDate   = IssAction.CreateDate
        b-table.CreateTime   = IssAction.CreateTime
        b-table.CreatedBy    = IssAction.CreatedBy
        b-table.notes        = "Auto Generated - Auto Action For " + b-WebAction.description
        b-table.ActionStatus = issAction.ActionStatus
        b-table.ActionDate   = issAction.ActionDate.

    RETURN TRUE.

END FUNCTION.


FUNCTION islib-DefaultActions RETURNS LOGICAL
    ( pc-companyCode  AS CHARACTER,
    pi-Issue        AS INTEGER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER Issue      FOR Issue.
    DEFINE BUFFER WebIssArea FOR WebIssArea.
    DEFINE BUFFER IssAction  FOR IssAction.
    DEFINE BUFFER b-table    FOR IssAction.
    DEFINE BUFFER WebAction  FOR WebAction.
    DEFINE VARIABLE li-loop  AS INTEGER NO-UNDO.
    DEFINE VARIABLE lf-Audit AS DECIMAL NO-UNDO.
    DEFINE VARIABLE lr-temp  AS ROWID   NO-UNDO.

    FIND Issue WHERE Issue.CompanyCode = pc-companyCode
        AND Issue.IssueNumber = pi-Issue NO-LOCK NO-ERROR.

    IF NOT AVAILABLE Issue THEN RETURN TRUE.

    FIND WebIssArea OF Issue NO-LOCK NO-ERROR.
    IF NOT AVAILABLE WebIssArea THEN RETURN TRUE.

    DO li-loop = 1 TO 10:

        IF WebIssArea.def-ActionCode[li-loop] = "" THEN NEXT.

        FIND WebAction
            WHERE WebAction.CompanyCode = pc-companyCode
            AND WebAction.ActionCode  = WebIssArea.def-ActionCode[li-loop]
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE WebAction THEN NEXT.

        FIND FIRST IssAction
            WHERE IssAction.CompanyCode = pc-companyCode
            AND IssAction.IssueNumber = Issue.IssueNumber
            AND IssAction.ActionID    = WebAction.ActionID
            NO-LOCK NO-ERROR.
        IF AVAILABLE IssAction THEN NEXT.

        CREATE b-table.
        ASSIGN 
            b-table.actionID    = WebAction.ActionID
            b-table.CompanyCode = pc-companyCode
            b-table.IssueNumber = Issue.IssueNumber
            b-table.CreateDate  = TODAY
            b-table.CreateTime  = TIME
            b-table.CreatedBy   = "SYSTEM"
            .

        DO WHILE TRUE:
            RUN lib/makeaudit.p (
                "",
                OUTPUT lf-audit
                ).
            IF CAN-FIND(FIRST IssAction
                WHERE IssAction.IssActionID = lf-audit NO-LOCK)
                THEN NEXT.
            ASSIGN
                b-table.IssActionID = lf-audit.

            LEAVE.
        END.

        ASSIGN 
            b-table.notes        = "Auto Generated - Default Action For " + WebIssArea.description
            b-table.ActionStatus = "OPEN"
            b-table.ActionDate   = TODAY
            b-table.AssignDate   = ?
            b-table.AssignTime   = 0.

        ASSIGN 
            lr-temp = ROWID(b-table).
        RELEASE b-table.

        FIND b-table WHERE ROWID(b-table) = lr-temp NO-LOCK NO-ERROR.

        DYNAMIC-FUNCTION('islib-CreateAutoAction':U,b-table.IssActionID).
    END.
  



    RETURN TRUE.

END FUNCTION.


FUNCTION islib-IssueIsOpen RETURNS LOGICAL
    ( pr-rowid    AS ROWID) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER issue     FOR issue.
    DEFINE BUFFER WebStatus FOR WebStatus.
    
    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.


    FIND issue
        WHERE ROWID(issue) = pr-rowid NO-LOCK NO-ERROR.

    IF NOT AVAILABLE issue THEN RETURN FALSE.

    FIND WebStatus OF Issue NO-LOCK NO-ERROR.

    IF NOT AVAILABLE WebStatus THEN RETURN FALSE.


    RETURN WebStatus.CompletedStatus = FALSE.



END FUNCTION.


FUNCTION islib-OutsideSLA RETURNS LOGICAL
    ( pr-rowid    AS ROWID
    ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER issue     FOR issue.
    DEFINE BUFFER WebStatus FOR WebStatus.
    
    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.


    FIND issue
        WHERE ROWID(issue) = pr-rowid NO-LOCK NO-ERROR.

    IF NOT AVAILABLE issue THEN RETURN FALSE.
    IF issue.SLAStatus = "OFF" THEN RETURN FALSE.

    IF DYNAMIC-FUNCTION('islib-IssueIsOpen':U,ROWID(Issue)) = FALSE
        OR Issue.link-SLAID = ?
        OR Issue.link-SLAID = 0 
        OR NOT CAN-FIND(sla WHERE sla.SLAID = Issue.link-SLAID ) 
        OR Issue.SLADate[1] = ? THEN RETURN FALSE.

    IF Issue.SLALevel = 0 THEN RETURN FALSE.

    IF Issue.SLALevel = 10
        OR Issue.SLADate[Issue.SLALevel + 1] = ? THEN RETURN TRUE.
    ELSE RETURN FALSE.




    RETURN TRUE.

END FUNCTION.


FUNCTION islib-RemoveAlerts RETURNS LOGICAL
    ( pr-rowid AS ROWID ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE BUFFER issue    FOR issue.
    DEFINE BUFFER IssAlert FOR IssAlert.
    
    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.


    FIND issue
        WHERE ROWID(issue) = pr-rowid NO-LOCK NO-ERROR.
    
    FOR EACH IssAlert OF Issue EXCLUSIVE-LOCK:
        DELETE IssAlert.
    END.

END FUNCTION.


FUNCTION islib-SLAChanged RETURNS LOGICAL
    ( pr-rowid    AS ROWID,
    pc-loginID    AS CHARACTER,
    pf-old-SLAID AS DECIMAL,
    pf-new-SLAID AS DECIMAL ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER Issue FOR Issue.
    DEFINE VARIABLE lc-message AS CHARACTER NO-UNDO.

    IF pf-old-SLAID = pf-new-SLAID THEN RETURN TRUE.

    FIND issue
        WHERE ROWID(issue) = pr-rowid EXCLUSIVE-LOCK NO-ERROR.

    IF NOT AVAILABLE issue THEN RETURN FALSE.


    IF CAN-FIND(WebNote
        WHERE WebNote.CompanyCode = Issue.CompanyCode
        AND WebNote.NoteCode = "SYS.SLA" NO-LOCK) THEN
    DO:
        
        RUN islib-CreateNote
            ( Issue.CompanyCode,
            Issue.IssueNumber,
            pc-LoginID,
            "SYS.SLA",
            'From: ' + dynamic-function("com-SLADescription",pf-old-SLAID) + '~n' +
            'To: ' + dynamic-function("com-SLADescription",pf-new-SLAID) + '~n'
            ).
        
    END.



    RETURN TRUE.
END FUNCTION.


FUNCTION islib-StatusIsClosed RETURNS LOGICAL
    ( pc-CompanyCode AS CHARACTER,
    pc-StatusCode AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE BUFFER WebStatus FOR WebStatus.
    
    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.

    FIND WebStatus 
        WHERE WebStatus.CompanyCode = pc-CompanyCode
        AND WebStatus.StatusCode = pc-StatusCode
        NO-LOCK NO-ERROR.

    IF NOT AVAILABLE WebStatus THEN RETURN FALSE.

    RETURN WebStatus.CompletedStatus.

END FUNCTION.


FUNCTION islib-WhoToAlert RETURNS CHARACTER
    ( pc-CompanyCode      AS CHARACTER,
    pi-IssueNumber      AS INTEGER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE BUFFER Issue   FOR Issue.
    DEFINE BUFFER WebUser FOR WebUser.

    FIND Issue
        WHERE Issue.CompanyCode = pc-CompanyCode
        AND Issue.IssueNumber = pi-IssueNumber NO-LOCK NO-ERROR.

    IF NOT AVAILABLE Issue THEN RETURN "".

    IF Issue.RaisedLoginID <> ""
        THEN RETURN Issue.RaisedLoginID.

    FIND FIRST WebUser
        WHERE WebUser.companyCode = pc-companyCode
        AND WebUser.AccountNumber = Issue.AccountNumber
        AND WebUser.DefaultUser  
        NO-LOCK NO-ERROR.

    RETURN IF AVAILABLE WebUser THEN webuser.loginid ELSE "".

  

END FUNCTION.


