/***********************************************************************

    Program:        prince/issstatus.p
    
    Purpose:        Generate Issue PDF         
    
    Notes:
    
    
    When        Who         What
    11/04/2006  phoski      Initial
        
    03/08/2010  DJS         3665 - Changed to putput only the html file
                            for the email
    12/08/2010  DJS         3665a - Error in test - ll-ok not set
    
***********************************************************************/

&IF DEFINED(UIB_is_Running) EQ 0 &THEN
DEFINE INPUT PARAMETER pc-CompanyCode  AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER pi-IssueNumber  AS INTEGER      NO-UNDO.
DEFINE INPUT PARAMETER pc-destination  AS CHARACTER     NO-UNDO.
DEFINE OUTPUT PARAMETER pc-pdf         AS CHARACTER     NO-UNDO.

&ELSE

DEFINE VARIABLE pc-CompanyCode AS CHARACTER NO-UNDO.
DEFINE VARIABLE pi-IssueNumber AS INTEGER   NO-UNDO.
DEFINE VARIABLE pc-destination AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-pdf         AS CHARACTER NO-UNDO.

ASSIGN
    pc-companyCode = "MICAR"
    pi-IssueNumber = 2309
    pc-destination = "internal".
&ENDIF

{lib/princexml.i}

DEFINE BUFFER WebUser      FOR WebUser.
DEFINE BUFFER b-WebUser    FOR WebUser.
DEFINE BUFFER WebIssArea   FOR WebIssArea.
DEFINE BUFFER WebStatus    FOR WebStatus.
DEFINE BUFFER IssStatus    FOR IssStatus.
DEFINE BUFFER Issue        FOR Issue.
DEFINE BUFFER Customer     FOR Customer.

DEFINE VARIABLE lc-html         AS CHARACTER     NO-UNDO.
DEFINE VARIABLE lc-pdf          AS CHARACTER     NO-UNDO.
DEFINE VARIABLE lc-Raised       AS CHARACTER     NO-UNDO.
DEFINE VARIABLE lc-Assigned     AS CHARACTER     NO-UNDO.
DEFINE VARIABLE ll-ok           AS LOG      NO-UNDO.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 15
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */

 




/* ***************************  Main Block  *************************** */

    
ASSIGN
    pc-pdf = ?.

FIND Issue WHERE Issue.CompanyCode = pc-companycode
    AND issue.IssueNumber = pi-IssueNumber
    NO-LOCK NO-ERROR.
IF NOT AVAILABLE Issue THEN RETURN.

FIND customer OF Issue NO-LOCK NO-ERROR.
IF NOT AVAILABLE Customer THEN RETURN.

IF Issue.RaisedLoginID <> "" THEN
DO:
    FIND WebUser WHERE WebUser.loginID = Issue.RaisedLoginID NO-LOCK NO-ERROR.
    IF AVAILABLE webUser 
        THEN ASSIGN lc-Raised = TRIM(WebUser.Forename + " " + WebUser.Surname).

END.

FIND WebIssArea OF Issue NO-LOCK NO-ERROR.
FIND WebStatus OF Issue NO-LOCK NO-ERROR.

ASSIGN 
    lc-html = SESSION:TEMP-DIR + caps(pc-CompanyCode) + "-Issue-" + string(pi-IssueNumber).

ASSIGN 
    lc-pdf = lc-html + ".pdf"
    lc-html = lc-html + ".html".

OS-DELETE value(lc-pdf) no-error.
OS-DELETE value(lc-html) no-error.

DYNAMIC-FUNCTION("pxml-Initialise").
DYNAMIC-FUNCTION("pxml-OpenStream",lc-html).

DYNAMIC-FUNCTION("pxml-Header", pc-CompanyCode).

{&prince}
'<p class="sub">Issue Number ' STRING(Issue.IssueNumber) '</p>' skip
    '<table class="info">' skip
    '<tr><th>Customer:</th><td>' pxml-Safe(Customer.AccountNumber) '&nbsp;' 
                pxml-Safe(Customer.name) '</td></tr>' skip
    '<tr><th>Date:</th><td>' string(Issue.IssueDate,"99/99/9999") '</td></tr>' skip
    '<tr><th>Raised By:</th><td>' pxml-Safe(lc-Raised) '</td></tr>' skip
    '<tr><th>Description:</th><td>' pxml-Safe(Issue.BriefDescription) '</td></tr>' skip
    '<tr><th>Details:</th><td>' replace(pxml-safe(Issue.LongDescription),'~n','<BR>') '</td></tr>' skip
    '<tr><th>Area:</th><td>' pxml-safe(WebIssArea.description) '</td></tr>' skip
    '<tr><th>Current Status:</th><td>' pxml-safe(WebStatus.description)
            ( if WebStatus.CompletedStatus then '&nbsp;<b>(Completed)</b>' else "" ) '</td></tr>' skip
.

IF pc-destination = "INTERNAL" THEN
DO:
    FIND b-WebUser
        WHERE b-WebUser.LoginID = Issue.AssignTo NO-LOCK NO-ERROR.
    ASSIGN 
        lc-Assigned =
        IF AVAILABLE b-WebUser
        THEN pxml-Safe(TRIM(b-webUser.Forename + " " + b-WebUser.Surname)) + 
             " " + string(Issue.AssignDate,"99/99/9999") ELSE "&nbsp;".
    {&prince}                                                                       
    '<tr><th>Assigned To:</th><td>' lc-Assigned '</td></tr>' skip.
END.

{&prince}
'</table>' skip.



{&prince}
'<p class="sub">Issue History</p>' skip
    '<table class="browse">' skip
    '<thead><tr><th>Date</th><th>Time</th><th>Status</th><th>By</th></tr></thead>' skip.


FOR EACH IssStatus NO-LOCK OF Issue
    BY IssStatus.ChangeDate DESCENDING
    BY IssStatus.ChangeTime DESCENDING:

    FIND WebStatus WHERE WebStatus.CompanyCode = Issue.Company
        AND WebStatus.StatusCode = IssStatus.NewStatusCode NO-LOCK NO-ERROR.

    IF NOT AVAILABLE WebStatus THEN NEXT.

    FIND b-WebUser
        WHERE b-WebUser.LoginID = IssStatus.LoginID NO-LOCK NO-ERROR.
    ASSIGN 
        lc-Assigned =
        IF AVAILABLE b-WebUser
        THEN pxml-Safe(TRIM(b-webUser.Forename + " " + b-WebUser.Surname)) ELSE "&nbsp;".

    {&prince} 
    '<tr>' skip
            '<td>' string(IssStatus.ChangeDate,"99/99/9999") '</td>' skip
            '<td>' string(IssStatus.ChangeTime,"hh:mm am") '</td>' skip
            '<td>' pxml-Safe(WebStatus.description) '</td>' skip
            '<td>' lc-Assigned '</td>' skip
        '</tr>' skip.

END.


{&prince} '</table>'.


DYNAMIC-FUNCTION("pxml-Footer",pc-CompanyCode).
DYNAMIC-FUNCTION("pxml-CloseStream").


/* ll-ok = dynamic-function("pxml-Convert",lc-html,lc-pdf). */

/* if ll-ok */
/* then     */
ASSIGN 
    pc-pdf = lc-html.



