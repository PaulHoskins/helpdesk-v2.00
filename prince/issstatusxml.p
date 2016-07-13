/***********************************************************************

    Program:        prince/issstatusxml.p
    
    Purpose:        Generate Issue PDF         
    
    Notes:
    
    
    When        Who         What
    11/06/2011  DJS         Initial - from issstaus.p for new html emails
       
    
***********************************************************************/

&IF DEFINED(UIB_is_Running) EQ 0 &THEN

DEFINE INPUT PARAMETER pc-CompanyCode  AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER pi-IssueNumber  AS INTEGER       NO-UNDO.
DEFINE INPUT PARAMETER pc-destination  AS CHARACTER     NO-UNDO.
DEFINE OUTPUT PARAMETER pc-text        AS CHARACTER     NO-UNDO.
DEFINE OUTPUT PARAMETER pc-html        AS CHARACTER     NO-UNDO.

&ELSE

DEFINE VARIABLE pc-CompanyCode AS CHARACTER NO-UNDO.
DEFINE VARIABLE pi-IssueNumber AS INTEGER   NO-UNDO.
DEFINE VARIABLE pc-destination AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-text        AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-html        AS CHARACTER NO-UNDO.

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


DEFINE VARIABLE lc-pdf          AS CHARACTER     NO-UNDO.
DEFINE VARIABLE lc-Raised       AS CHARACTER     NO-UNDO.
DEFINE VARIABLE lc-Assigned     AS CHARACTER     NO-UNDO.
DEFINE VARIABLE ll-ok           AS LOG           NO-UNDO.




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

DEFINE VARIABLE lc-html     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-text     AS CHARACTER NO-UNDO.
DEFINE VARIABLE odd-even    AS LOG INITIAL FALSE NO-UNDO.

 
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

/* assign                                                                                      */
/*     lc-html = session:temp-dir + caps(pc-CompanyCode) + "-Issue-" + string(pi-IssueNumber). */


/* lc-html =           dynamic-function("pxml-Email-Header", pc-CompanyCode).  */

lc-html = lc-html +     '<p class="sub" style="font-weight: bold;font-size: 15px;text-align: center;">Issue Number ' + string(Issue.IssueNumber) + '</p>' .
lc-html = lc-html +     '<table class="info" style="width: 70%;  100%;margin-left:auto;margin-right:auto;  ">' .
lc-html = lc-html +     '<tr><th style = "text-align: right;vertical-align: text-top;">Customer:</th><td style="padding-left: 10px;">' + pxml-Safe(Customer.AccountNumber) + '&nbsp;' .
lc-html = lc-html +     pxml-Safe(Customer.name) + '</td></tr>' .
lc-html = lc-html +     '<tr><th style = "text-align: right;vertical-align: text-top;">Date:</th><td style="padding-left: 10px;">' + string(Issue.IssueDate,"99/99/9999") + '</td></tr>' .
lc-html = lc-html +     '<tr><th style = "text-align: right;vertical-align: text-top;">Raised By:</th><td style="padding-left: 10px;">' + pxml-Safe(lc-Raised) + '</td></tr>' .
lc-html = lc-html +     '<tr><th style = "text-align: right;vertical-align: text-top;">Description:</th><td style="padding-left: 10px;">' + pxml-Safe(Issue.BriefDescription) + '</td></tr>' .
lc-html = lc-html +     '<tr><th style = "text-align: right;vertical-align: text-top;">Details:</th><td style="padding-left: 10px;">' + replace(pxml-safe(Issue.LongDescription),'~n','<BR>') + '</td></tr>' .
lc-html = lc-html +     '<tr><th style = "text-align: right;vertical-align: text-top;">Area:</th><td style="padding-left: 10px;">' + pxml-safe(IF AVAILABLE WebIssArea THEN STRING(WebIssArea.description) ELSE "") + '</td></tr>' .
lc-html = lc-html +     '<tr><th style = "text-align: right;vertical-align: text-top;">Current Status:</th><td style="padding-left: 10px;">' + pxml-safe(IF AVAILABLE WebStatus THEN STRING(WebStatus.description) ELSE "").

IF AVAILABLE WebStatus AND WebStatus.CompletedStatus THEN lc-html = lc-html + '&nbsp;<b>(Completed)</b>' .
ELSE lc-html = lc-html + "" . 

lc-html = lc-html +    '</td></tr>' .
 
lc-text =               'Issue Number ' + string(Issue.IssueNumber) + '~n~n' .

lc-text = lc-text +     'Customer:~t~t' + pxml-Safe(Customer.AccountNumber) + '~t' .
lc-text = lc-text +     pxml-Safe(Customer.name) + '~n' .
lc-text = lc-text +     'Date:~t~t~t' + string(Issue.IssueDate,"99/99/9999") + '~n' .
lc-text = lc-text +     'Raised By:~t~t' + pxml-Safe(lc-Raised) + '~n' .
lc-text = lc-text +     'Description:~t~t' + pxml-Safe(Issue.BriefDescription) + '~n' .
lc-text = lc-text +     'Details:~t~t' + replace(pxml-safe(Issue.LongDescription),'~n','<BR>') + '~n' .
lc-text = lc-text +     'Area:~t~t~t' + pxml-safe(IF AVAILABLE WebIssArea THEN STRING(WebIssArea.description) ELSE "") + '~n' .
lc-text = lc-text +     'Current Status:~t~t' + pxml-safe(IF AVAILABLE WebStatus THEN STRING(WebStatus.description) ELSE "").

IF AVAILABLE WebStatus AND WebStatus.CompletedStatus THEN lc-text = lc-text + ' (Completed) ~n~n' .
ELSE lc-text = lc-text + '~n~n' .






IF pc-destination = "INTERNAL" THEN
DO:
    FIND b-WebUser
        WHERE b-WebUser.LoginID = Issue.AssignTo NO-LOCK NO-ERROR.
    ASSIGN 
        lc-Assigned = IF AVAILABLE b-WebUser THEN pxml-Safe(TRIM(b-webUser.Forename + " " + b-WebUser.Surname)) + " " + string(Issue.AssignDate,"99/99/9999") ELSE "&nbsp;"
        lc-html = lc-html + '<tr><th style = "text-align: right;vertical-align: text-top;">Assigned To:</th><td style="padding-left: 10px;">' + lc-Assigned + '</td></tr>'
        lc-text = lc-text + 'Assigned To:~t' + lc-Assigned + '~n' .
END.

lc-html = lc-html + '</table>' .
lc-html = lc-html + '<p class="sub" style="font-weight: bold;font-size: 15px;text-align: center;">Issue History</p>'.
lc-html = lc-html + '<table class="browse" style="width: 100%;border: 1px solid black;">' .
lc-html = lc-html + '<thead style="background-color: #DFDFDF;"><tr><th>Date</th><th>Time</th><th>Status</th><th>By</th></tr></thead>' .

lc-text = lc-text + 'Issue History ~n'.
lc-text = lc-text + 'Date~t~tTime~t~tStatus~t~tBy ~n~n' .


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

 
    lc-html = lc-html + '<tr ' + IF odd-even THEN 'style="background-color: #F2F2F2;        border-top: 1px solid black;"' ELSE ''  +  ' >' .
    lc-html = lc-html +     '<td>' + string(IssStatus.ChangeDate,"99/99/9999") + '</td>' .
    lc-html = lc-html +     '<td>' + string(IssStatus.ChangeTime,"hh:mm am") + '</td>'. 
    lc-html = lc-html +     '<td>' + pxml-Safe(WebStatus.description) + '</td>'. 
    lc-html = lc-html +     '<td>' + lc-Assigned + '</td>' .
    lc-html = lc-html + '</tr>' .
    odd-even = odd-even = FALSE.


    lc-text = lc-text + string(IssStatus.ChangeDate,"99/99/9999") + '~t' .
    lc-text = lc-text + string(IssStatus.ChangeTime,"hh:mm am")  + '~t' .
    lc-text = lc-text + pxml-Safe(WebStatus.description)  + '~t' .
    lc-text = lc-text + lc-Assigned  + '~n' .


END.


lc-html = lc-html + '</table><br /><br />'.


ASSIGN 
    pc-html = lc-html
    pc-text = lc-text.



