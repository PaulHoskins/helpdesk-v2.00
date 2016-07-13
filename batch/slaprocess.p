/***********************************************************************

    Program:        batch/slaprocess.p
    
    Purpose:        SLA Processing
    
    Notes:
    
    
    When        Who         What
    12/05/2006  phoski      Initial
    20/10/2015  phoski      com-GetHelpDeskEmail for email sender
    27/02/2016  phoski      Link to issue in email
    02/07/2016  phoski      Don't send emails if holiday

***********************************************************************/

{lib/common.i}
{iss/issue.i}

DEFINE BUFFER Issue    FOR Issue.
DEFINE BUFFER ro-Issue FOR Issue.
DEFINE BUFFER IssAlert FOR IssAlert.
DEFINE BUFFER Company  FOR Company.
DEFINE BUFFER SLAhead  FOR slahead.
DEFINE BUFFER WebUser  FOR WebUser.

DEFINE STREAM s-log.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-fnLog) = 0 &THEN

FUNCTION fnLog RETURNS LOGICAL
    ( pc-data AS CHARACTER )  FORWARD.


&ENDIF


/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 15
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */

 




/* ***************************  Main Block  *************************** */

DEFINE VARIABLE ld-date        AS DATE      NO-UNDO.
DEFINE VARIABLE li-time        AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-level       AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-loop        AS INTEGER   NO-UNDO.

DEFINE VARIABLE lc-Description AS CHARACTER NO-UNDO.
DEFINE VARIABLE ld-Alert       AS DATE      NO-UNDO.
DEFINE VARIABLE lc-Time        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-details     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-NoteCode    AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-SLAMissed   AS LOG       NO-UNDO.
DEFINE VARIABLE lc-System      AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-email       AS LOG       NO-UNDO.
DEFINE VARIABLE lc-mail        AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-sms         AS LOG       NO-UNDO.
DEFINE VARIABLE lc-subject     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Dest        AS CHARACTER NO-UNDO.

DEFINE VARIABLE ldt-Level2     AS DATETIME  NO-UNDO.
DEFINE VARIABLE ldt-Amber2     AS DATETIME  NO-UNDO.
DEFINE VARIABLE li-Mill        AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-dt          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link        AS CHARACTER NO-UNDO.


OUTPUT stream s-log to value("c:/temp/sla-batch.log") UNBUFFERED.


fnLog("SLA Batch Begins").

ASSIGN
    lc-System = "SLA.ALERT".

FOR EACH ro-Issue NO-LOCK
    WHERE ro-Issue.SLAStatus = "ON" TRANSACTION:
    
    FIND Issue
        WHERE ROWID(Issue) = rowid(ro-Issue) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
    IF LOCKED Issue THEN NEXT.

    /*
    fnlog ( "check " + Issue.companycode + " " + STRING(Issue.issuenumber)).
    */

    IF DYNAMIC-FUNCTION('islib-IssueIsOpen':U,ROWID(Issue)) = FALSE
        OR Issue.link-SLAID = ?
        OR Issue.link-SLAID = 0 
        OR NOT CAN-FIND(slahead WHERE slahead.SLAID = Issue.link-SLAID ) 
        OR Issue.SLADate[1] = ? THEN
    DO:
        DYNAMIC-FUNCTION("islib-RemoveAlerts",ROWID(Issue)).
        ASSIGN
            Issue.SLAStatus = "OFF"
            issue.tlight    = li-global-sla-na.
        .
        RELEASE Issue.
        NEXT.
    END.

    FIND slahead WHERE slahead.SLAID = Issue.link-SLAID NO-LOCK NO-ERROR.

    /*fnLog ( "Issue " + string(Issue.IssueNumber) + " SLA = " + slahead.Description).*/
    ASSIGN
        ld-date      = TODAY
        li-time      = TIME
        issue.tlight = li-global-sla-ok.


    IF issue.slaDate[2] <> ? THEN
    DO:
        lc-dt = STRING(Issue.SLADate[2],"99/99/9999") + " " 
            + STRING(Issue.SLATime[2],"HH:MM").
        ldt-level2 = DATETIME(lc-dt).
        ASSIGN 
            issue.SLATrip  = ldt-Level2
            issue.SLAAmber = ?.

        IF slahead.amberWarning > 0 THEN
        DO:
            RUN lib/calcamber.p ( Issue.CompanyCode,
                ldt-Level2, slahead.amberWarning, OUTPUT issue.slaamber).
                    
            /*        
            li-mill = (  slahead.amberWarning * 60 ) * 1000.
            ldt-Amber2 = ldt-Level2 - li-Mill.
            issue.slaamber = ldt-Amber2.
            */
            
            /*fnLog ( "Amber ( Level2 " + STRING(ldt-level2) + " - " +
                string(slahead.amberWarning) + "mins ) = " +
                string(issue.slaamber)
                ).
            */ 

        END.


    END.

    /*
    ***
    *** Has the SLA Started? 
    ***
    */
    IF Issue.SLADate[1] > ld-date THEN NEXT.

    IF Issue.SLADate[1] = ld-date
        AND Issue.SLATime[1] > li-time THEN 
    DO:
        NEXT.
    END.

    /*
    *** SLA LEvel 2 is the tripwire 
    */
   


    IF issue.slaDate[2] <> ? THEN
    DO:
        lc-dt = STRING(Issue.SLADate[2],"99/99/9999") + " " 
            + STRING(Issue.SLATime[2],"HH:MM").
        ldt-Level2 = DATETIME(lc-dt).

        IF ldt-level2 <= NOW 
            THEN ASSIGN issue.tlight = li-global-sla-fail.
        ELSE
            IF slahead.amberWarning > 0 THEN
            DO:
         
                IF NOW >= issue.slaamber
                    THEN ASSIGN issue.tlight = li-global-sla-amber.
            END.


    END.
    ELSE ASSIGN issue.tlight = li-global-sla-fail.


   
    /*
    ***
    *** Alerts done to final level?
    ***
    */
    IF Issue.SLALevel = 10
        OR Issue.SLADate[Issue.SLALevel + 1] = ? THEN
    DO:
        NEXT.
    END.
        
    /*
    ***
    *** Now find out the level I'm at 
    ***
    */
    ASSIGN
        li-Level = 0.

    DO li-loop = 1 TO 10:
        IF Issue.SLADate[li-loop] = ? 
            OR Issue.SLADate[li-loop] > ld-date THEN LEAVE.
        IF Issue.SLADate[li-loop] = ld-date
            AND Issue.SLATime[li-loop] > li-time THEN LEAVE.
        ASSIGN
            li-level = li-loop.

    END.
    /*
    ***
    *** If calculated level is <= current level then nothing to do
    ***
    */
    IF li-level <= Issue.SLALevel THEN NEXT.

    /*
    ***
    *** Need to create an alert
    ***
    */
    FIND sla WHERE sla.SLAID = Issue.link-SLAID NO-LOCK NO-ERROR.
    /*
    *** 
    *** SLA has been changed so do something
    ***
    */
    IF sla.RespDesc[li-level] = "" THEN
    DO:
        NEXT.
    END.

    IF li-level = 10
        OR Issue.SLADate[li-level + 1] = ? 
        THEN ASSIGN ll-SLAMissed = TRUE.
    ELSE ASSIGN ll-SLAMissed = FALSE.

    ASSIGN
        lc-details = "SLA Details " + 
                     sla.RespDesc[li-level] + " Due " + 
                     string(Issue.SLADate[li-level],'99/99/9999') +
                     ' ' + 
                     string(Issue.SLATime[li-level],'hh:mm am').
    IF NOT ll-SLAMissed THEN
    DO:
        IF sla.RespDesc[li-level + 1] <> "" THEN
        DO:
            ASSIGN
                lc-details = lc-details + "~n" +
                         "Next alert will be " +
                         sla.RespDesc[li-level + 1] + " at " +
                         string(Issue.SLADate[li-level + 1],'99/99/9999') +
                         ' ' + 
                         string(Issue.SLATime[li-level + 1],'hh:mm am').
        END.
    END.
    RUN islib-CreateNote( Issue.CompanyCode,
        Issue.IssueNumber,
        lc-system,
        IF ll-SLAMissed
        THEN 'SYS.SLAMISSED' ELSE 'SYS.SLAWARN',
        lc-details).    
    ASSIGN
        ll-Email = sla.RespAction[li-level] BEGINS "email"
        ll-sms   = CAN-DO("EmailPage,Page",sla.RespAction[li-level]).
                   
    FIND customer OF Issue NO-LOCK NO-ERROR.

    /*
    ***
    *** Kill any existing alerts for the issue
    ***
    */
    DYNAMIC-FUNCTION("islib-RemoveAlerts",ROWID(Issue)).
    /*
    ***
    *** Need to send alerts to the users on SLA plus the
    *** person its assigned too
    ***
    ***
    */
    ASSIGN
        lc-dest = sla.RespDest[li-level].
    IF Issue.AssignTo <> ""
        AND CAN-DO(lc-dest,Issue.AssignTo) = FALSE THEN 
    DO:
        IF lc-dest = ""
            THEN ASSIGN lc-dest = Issue.AssignTo.
        ELSE ASSIGN lc-dest = lc-dest + "," + Issue.AssignTo.
    END.
    IF lc-dest <> "" THEN
    DO li-loop = 1 TO NUM-ENTRIES(lc-dest) WITH FRAME f-dest:

        FIND webuser
            WHERE webuser.LoginID = entry(li-loop,lc-dest)
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE WebUser THEN NEXT.

        /*
        ***
        *** Always create a webpage alert 
        ***
        */
        CREATE IssAlert.
        ASSIGN 
            IssAlert.CompanyCode = Issue.CompanyCode
            IssAlert.IssueNumber = Issue.IssueNumber
            IssAlert.LoginID     = webuser.LoginID
            IssAlert.SLALevel    = li-level
            IssAlert.CreateDate  = ld-date
            IssAlert.CreateTime  = li-time.
        
        
        IF LOOKUP(webuser.LoginID,issue.alertusers) = 0 THEN 
        DO:
            IF Issue.alertusers = ""
            THEN Issue.alertusers = webuser.LoginID.
            ELSE Issue.alertusers = issue.alertusers + "," + webuser.LoginID.
            
        END.
        
        /*
        ***
        *** SMS Alerts
        ***
        */
        IF ll-sms AND webuser.Mobile <> "" 
            AND webUser.allowSMS THEN
        DO:
            ASSIGN 
                lc-mail = "Issue: " + string(Issue.IssueNumber) 
                                + ' ' + Issue.BriefDescription + " " + 
                                "Customer: " + customer.name.
            ASSIGN 
                lc-mail = lc-mail + "~n" + lc-details.

            CREATE SMSQueue.
            ASSIGN
                SMSQueue.CompanyCode = Issue.CompanyCode
                SMSQueue.IssueNumber = Issue.IssueNumber
                SMSQueue.QStatus     = 0
                SMSQueue.CreateDate  = ld-date
                SMSQueue.CreateTime  = li-time
                SMSQueue.CreatedBy   = lc-System
                SMSQueue.SendTo      = webuser.LoginID
                SMSQueue.Msg         = lc-mail
                SMSQueue.Mobile      = webuser.Mobile
                .
           
            
        END.

        /*
        ***
        *** Email Alerts
        ***
        */
        IF ll-email AND webUser.Email <> "" THEN
        DO:

            FIND Company OF Issue NO-LOCK NO-ERROR.
            ASSIGN 
                lc-mail = "Issue: " + string(Issue.IssueNumber) 
                                + ' ' + Issue.BriefDescription + "~n" + 
                                "Customer: " + customer.name.
            IF Issue.LongDescription <> "" 
                THEN lc-mail = lc-mail + "~n" + Issue.LongDescription.
    
            ASSIGN 
                lc-mail = lc-mail + "~n~n~n" + lc-details.
    
            IF Issue.AssignTo <> ""
                THEN ASSIGN lc-mail = lc-mail + "~n~n~nAssigned to " + com-UserName(Issue.AssignTo) 
                + ' at ' 
                + string(Issue.AssignDate,'99/99/9999') + 
                ' ' + string(Issue.AssignTime,'hh:mm am')
                    .
                    
            IF Company.helpdesklink <> ""  THEN 
            DO:
                ASSIGN lc-link = Company.helpdesklink + "/mn/login.p?company=" + Company.CompanyCode
                                                + "&mode=passthru&passtype=issue&passref=" + string(Issue.IssueNumber).
                                                
                ASSIGN lc-mail = lc-mail + "~n~n~n" +
                  substitute('<a href="&2">&1</a>',
                          "Issue - " + string(Issue.IssueNumber),
                          lc-Link ).
                          
            END.        
            ASSIGN 
                lc-subject = "SLA Alert for " + "Issue " + string(Issue.IssueNumber) +
                   ' - Customer ' + Customer.name.
                   
             IF CAN-FIND(FIRST Holiday WHERE Holiday.CompanyCode = Issue.CompanyCode
                        AND Holiday.hDate = TODAY 
                        AND Holiday.observed = TRUE NO-LOCK) = FALSE THEN
             DO:
                 fnLog ( "Issue Email " + Issue.CompanyCode + "/" 
                        + string(Issue.IssueNumber) 
                        + " to = " + WebUser.Loginid + "/" + WebUser.email).
                 DYNAMIC-FUNCTION("mlib-SendEmail",
                    Issue.Company,
                    DYNAMIC-FUNCTION("com-GetHelpDeskEmail","From",issue.company,Issue.AccountNumber),
                    lc-Subject,
                    lc-mail,
                    WebUser.email).
             END. 
        END.
        
    END.

    /*
    ***
    *** Everything done for this Issue/Alert so set the alert level
    ***
    */
    
    ASSIGN
        Issue.SLALevel = li-Level.
        
END.

fnLog("SLA Batch Ends").

OUTPUT stream s-log close.

QUIT.



/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-fnLog) = 0 &THEN

FUNCTION fnLog RETURNS LOGICAL
    ( pc-data AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    PUT STREAM s-log UNFORMATTED
        STRING(TODAY,"99/99/9999") " " 
        STRING(TIME,"hh:mm:ss") "  -  " pc-data SKIP.
  
    RETURN TRUE.

END FUNCTION.


&ENDIF

