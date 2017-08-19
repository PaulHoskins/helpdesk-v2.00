/***********************************************************************

    Program:        batch/slaprocess-orig.p
    
    Purpose:        SLA Processing - The Original SLA!
    
    Notes:
    
    
    When        Who         What
    19/08/2017  phoski      Initial

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


FUNCTION fnLog RETURNS LOGICAL
    ( pc-data AS CHARACTER )  FORWARD.





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

DEFINE VARIABLE ldt-Level2     AS DATETIME  NO-UNDO.
DEFINE VARIABLE ldt-Amber2     AS DATETIME  NO-UNDO.
DEFINE VARIABLE li-Mill        AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-dt          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link        AS CHARACTER NO-UNDO.


OUTPUT stream s-log to value("c:/temp/sla-batch-orig.log") UNBUFFERED.


fnLog("SLA Batch Begins").

ASSIGN
    lc-System = "SLA.ALERT".

FOR EACH ro-Issue NO-LOCK
    WHERE ro-Issue.orig-SLAStatus = "ON" 
    /*
    AND ro-issue.IssueNumber = 139411 
    */ 
    TRANSACTION:
    
    FIND Issue
        WHERE ROWID(Issue) = rowid(ro-Issue) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
    IF LOCKED Issue THEN NEXT.

    
    fnlog ( "check " + Issue.companycode + " " + STRING(Issue.issuenumber)  + ' Level ' + string(Issue.orig-SLALevel)).
    

    IF DYNAMIC-FUNCTION('islib-IssueIsOpen':U,ROWID(Issue)) = FALSE
        OR Issue.orig-SLAID = ?
        OR Issue.orig-SLAID = 0 
        OR NOT CAN-FIND(slahead WHERE slahead.SLAID = Issue.orig-SLAID ) 
        OR Issue.orig-SLADate[1] = ? THEN
    DO:
        /** DYNAMIC-FUNCTION("islib-RemoveAlerts",ROWID(Issue)). **/
        ASSIGN
            Issue.orig-SLAStatus = "OFF"
            issue.orig-tlight    = li-global-sla-na.
        .
        RELEASE Issue.
        NEXT.
    END.

    FIND slahead WHERE slahead.SLAID = Issue.orig-SLAID NO-LOCK NO-ERROR.

    fnLog ( "Issue " + string(Issue.IssueNumber) + " SLA = " + slahead.Description).
    ASSIGN
        ld-date           = TODAY
        li-time           = TIME
        issue.orig-tlight = li-global-sla-ok.


    IF issue.orig-SLADate[2] <> ? THEN
    DO:
        lc-dt = STRING(Issue.orig-SLADate[2],"99/99/9999") + " " 
            + STRING(Issue.orig-SLATime[2],"HH:MM").
        ldt-level2 = DATETIME(lc-dt).
        ASSIGN 
            issue.orig-SLATrip  = ldt-Level2
            issue.orig-SLAAmber = ?.

        IF slahead.amberWarning > 0 THEN
        DO:
            RUN lib/calcamber.p ( Issue.CompanyCode, Issue.AccountNumber,
                ldt-Level2, slahead.amberWarning, OUTPUT issue.orig-SLAAmber).
                    
        END.

    END.

    /*
    ***
    *** Has the SLA Started? 
    ***
    */
    IF Issue.orig-SLADate[1] > ld-date THEN NEXT.

    IF Issue.orig-SLADate[1] = ld-date
        AND Issue.orig-SLATime[1] > li-time THEN 
    DO:
        NEXT.
    END.

    /*
    *** SLA LEvel 2 is the tripwire 
    */
   


    IF issue.orig-SLADate[2] <> ? THEN
    DO:
        lc-dt = STRING(Issue.orig-SLADate[2],"99/99/9999") + " " 
            + STRING(Issue.orig-SLATime[2],"HH:MM").
        ldt-Level2 = DATETIME(lc-dt).

        IF ldt-level2 <= NOW 
            THEN ASSIGN issue.orig-tlight = li-global-sla-fail.
        ELSE
            IF slahead.amberWarning > 0 THEN
            DO:
         
                IF NOW >= issue.orig-SLAAmber
                    THEN ASSIGN issue.orig-tlight = li-global-sla-amber.
            END.


    END.
    ELSE ASSIGN issue.orig-tlight = li-global-sla-fail.


   
    /*
    ***
    *** Alerts done to final level?
    ***
    */
    IF Issue.orig-SLALevel = 10
        OR Issue.orig-SLADate[Issue.orig-SLALevel + 1] = ? THEN
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
        IF Issue.orig-SLADate[li-loop] = ? 
            OR Issue.orig-SLADate[li-loop] > ld-date THEN LEAVE.
        IF Issue.orig-SLADate[li-loop] = ld-date
            AND Issue.orig-SLATime[li-loop] > li-time THEN LEAVE.
        ASSIGN
            li-level = li-loop.

    END.
    /*
    ***
    *** If calculated level is <= current level then nothing to do
    ***
    */
    IF li-level <= Issue.orig-SLALevel THEN NEXT.

    /*
    ***
    *** Need to create an alert
    ***
    */
    FIND sla WHERE sla.SLAID = Issue.orig-SLAID NO-LOCK NO-ERROR.
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
        OR Issue.orig-SLADate[li-level + 1] = ? 
        THEN ASSIGN ll-SLAMissed = TRUE.
    ELSE ASSIGN ll-SLAMissed = FALSE.

    ASSIGN
        lc-details = "SLA Details ( Original ) " + 
                     sla.RespDesc[li-level] + " Due " + 
                     string(Issue.orig-SLADate[li-level],'99/99/9999') +
                     ' ' + 
                     string(Issue.orig-SLATime[li-level],'hh:mm am').
    IF NOT ll-SLAMissed THEN
    DO:
        IF sla.RespDesc[li-level + 1] <> "" THEN
        DO:
            ASSIGN
                lc-details = lc-details + "~n" +
                         "Next alert will be " +
                         sla.RespDesc[li-level + 1] + " at " +
                         string(Issue.orig-SLADate[li-level + 1],'99/99/9999') +
                         ' ' + 
                         string(Issue.orig-SLATime[li-level + 1],'hh:mm am').
        END.
    END.
    
    /*
    ***
    *** Only do the note if current and original are different 
    ***
    */
    IF Issue.link-SLAID <> Issue.orig-SLAID THEN
    DO:
    
        fnLog ( "Issue " + string(Issue.IssueNumber) + " Note = " + lc-details).
        
        RUN islib-CreateNote( Issue.CompanyCode,
            Issue.IssueNumber,
            lc-system,
            IF ll-SLAMissed
            THEN 'SYS.SLAMISSEDO' ELSE 'SYS.SLAWARNO',
            lc-details).    
                     
     
    END.
    
    /*
    ***
    *** Everything done for this Issue/Alert so set the alert level
    ***
    */
    fnLog ( "Issue " + string(Issue.IssueNumber) + " Level From " + string(Issue.orig-SLAlevel) + " To " + string(li-level)).
    
    ASSIGN
        Issue.orig-SLALevel = li-Level.
        
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

