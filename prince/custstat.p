/***********************************************************************

    Program:        prince/custstat.p
    
    Purpose:        Customer Statement PDF   
    
    Notes:
    
    
    When        Who         What
    26/07/2006  phoski      Initial
    02/07/2016  phoski      Fixed totals and admin time
***********************************************************************/
                                          
{lib/htmlib.i}
{lib/princexml.i}


DEFINE INPUT PARAMETER pc-user             AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-CompanyCode      AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-AccountNumber    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pl-includeAdmin     AS LOGICAL   NO-UNDO.
DEFINE INPUT PARAMETER pd-lodate           AS DATE NO-UNDO.
DEFINE INPUT PARAMETER pd-hidate           AS DATE NO-UNDO.
DEFINE OUTPUT PARAMETER pc-pdf             AS CHARACTER NO-UNDO.

{iss/issue.i}

DEFINE VARIABLE ld-lo-date      AS DATE     NO-UNDO.
DEFINE VARIABLE ld-hi-date      AS DATE     NO-UNDO.

DEFINE VARIABLE lc-html         AS CHARACTER     NO-UNDO.
DEFINE VARIABLE lc-pdf          AS CHARACTER     NO-UNDO.
DEFINE VARIABLE ll-ok           AS LOGICAL       NO-UNDO.
DEFINE VARIABLE li-ReportNumber AS INTEGER       NO-UNDO.
DEFINE VARIABLE li-BalanceNow   AS INTEGER       NO-UNDO.


DEFINE BUFFER Customer     FOR Customer.
DEFINE BUFFER Company      FOR Company.

DEFINE BUFFER Issue        FOR Issue.

DEFINE TEMP-TABLE tt       NO-UNDO LIKE Issue
    FIELD udf-Close         AS DATE FORMAT '99/99/9999'
    FIELD udf-By            AS CHARACTER
    FIELD udf-prev-period   AS INTEGER
    FIELD udf-this-period   AS INTEGER
    .




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-fnUserName) = 0 &THEN

FUNCTION fnUserName RETURNS CHARACTER
    ( pc-LoginID  AS CHARACTER )  FORWARD.


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

ASSIGN
    ld-hi-date = pd-hidate
    ld-lo-date = pd-lodate.

ASSIGN
    pc-pdf = ?
    li-ReportNumber = NEXT-VALUE(ReportNumber).
ASSIGN 
    lc-html = SESSION:TEMP-DIR + caps(pc-CompanyCode) + "-Statement-" + string(li-ReportNumber).

ASSIGN 
    lc-pdf = lc-html + ".pdf"
    lc-html = lc-html + ".html".

OS-DELETE value(lc-pdf) no-error.
OS-DELETE value(lc-html) no-error.

FIND Customer 
    WHERE customer.CompanyCode = pc-companyCode
    AND customer.AccountNumber = pc-AccountNumber NO-LOCK NO-ERROR.
FIND Company
    WHERE Company.CompanyCode = pc-companyCode NO-LOCK NO-ERROR.

IF pl-includeAdmin
THEN li-balanceNow = com-GetTicketBalanceWithAdmin(Customer.CompanyCode,Customer.AccountNumber).
ELSE li-balanceNow = com-GetTicketBalance(Customer.CompanyCode,Customer.AccountNumber).

RUN ip-BuildIssueData.

DYNAMIC-FUNCTION("pxml-Initialise").

CREATE tt-pxml.
ASSIGN 
    tt-pxml.PageOrientation = "PORTRAIT".

DYNAMIC-FUNCTION("pxml-OpenStream",lc-html).

DYNAMIC-FUNCTION("pxml-StandardHTMLBegin").

DYNAMIC-FUNCTION("pxml-DocumentStyleSheet","statement",pc-companyCode).
DYNAMIC-FUNCTION("pxml-PrePrintFooter",pc-companyCode).

DYNAMIC-FUNCTION("pxml-StandardBody").

RUN ip-Print.

DYNAMIC-FUNCTION("pxml-Footer",pc-CompanyCode).
DYNAMIC-FUNCTION("pxml-CloseStream").


ll-ok = DYNAMIC-FUNCTION("pxml-Convert",lc-html,lc-pdf).

IF ll-ok
    THEN ASSIGN pc-pdf = lc-pdf.
ELSE ASSIGN pc-pdf = lc-html.
    



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-BuildIssueData) = 0 &THEN

PROCEDURE ip-BuildIssueData :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER Issue    FOR Issue.
    DEFINE BUFFER Ticket   FOR Ticket.

    DEFINE VARIABLE ld-CloseDate        AS DATE     NO-UNDO.
    DEFINE VARIABLE lc-By               AS CHARACTER     NO-UNDO.

    FOR EACH issue NO-LOCK
        WHERE issue.CompanyCode = pc-companyCode
        AND issue.AccountNumber = pc-AccountNumber
        AND issue.IssueDate <= ld-hi-date
        :

        /*
        ***
        *** If the job is completed then ignore if outside period if
        *** there are no ticket transactions in the period
        ***
        ***
        */
        IF DYNAMIC-FUNCTION("islib-IssueIsOpen",ROWID(Issue)) = FALSE THEN
        DO:
            ASSIGN
                ld-CloseDate = DYNAMIC-FUNCTION("islib-CloseDate",ROWID(Issue)).
            IF ld-CloseDate < ld-lo-Date 
                OR ld-CloseDate = ? THEN 
            DO:
                IF NOT 
                    CAN-FIND(FIRST ticket
                    WHERE ticket.CompanyCode = pc-CompanyCode
                    AND ticket.IssueNumber = issue.IssueNumber
                    AND ticket.TxnDate >= ld-lo-date
                    AND ticket.TxnDate <= ld-hi-date
                    NO-LOCK) THEN NEXT.
                
            END.

            FIND FIRST IssStatus OF Issue NO-LOCK NO-ERROR.
            IF AVAILABLE issStatus
                THEN ASSIGN lc-By = issStatus.LoginId.
            
        END.
        ELSE ASSIGN ld-CloseDate = ?
                lc-by = "".

        CREATE tt.
        BUFFER-COPY Issue TO tt.

        ASSIGN
            tt.udf-Close = ld-CloseDate
            tt.udf-by    = lc-By.

        FOR EACH ticket NO-LOCK
            WHERE ticket.CompanyCode = pc-CompanyCode
            AND ticket.IssueNumber = issue.IssueNumber
            AND ticket.TxnDate <= ld-hi-date:

            IF Ticket.IssActivityID <> 0 AND pl-includeAdmin = FALSE THEN
            DO:
                IF com-IsActivityChargeable(Ticket.IssActivityID) = FALSE THEN NEXT.
            END.
            
            IF ticket.TxnDate < ld-lo-date
                THEN ASSIGN
                    tt.udf-prev-period = tt.udf-prev-period + ( ticket.Amount * -1 ).
            ELSE ASSIGN 
                    tt.udf-this-period = tt.udf-this-period + ( ticket.Amount * -1 ).

        END.

    END.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-CompanyInfo) = 0 &THEN

PROCEDURE ip-CompanyInfo :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    {&prince}
    '<table class="info">' skip.
        

    {&prince} '<tr><th style="text-align: right;">From:</th><td>' DYNAMIC-FUNCTION("pxml-Safe",Company.Name) '</td></tr>' skip.
    {&prince} '<tr><td>&nbsp;</td><td>' DYNAMIC-FUNCTION("pxml-Safe",Company.Address1) '</td></tr>' skip.
    {&prince} '<tr><td>&nbsp;</td><td>' DYNAMIC-FUNCTION("pxml-Safe",Company.Address2) '</td></tr>' skip.
    {&prince} '<tr><td>&nbsp;</td><td>' DYNAMIC-FUNCTION("pxml-Safe",Company.City) '</td></tr>' skip.
    {&prince} '<tr><td>&nbsp;</td><td>' DYNAMIC-FUNCTION("pxml-Safe",Company.County) '</td></tr>' skip.
    {&prince} '<tr><td>&nbsp;</td><td>' DYNAMIC-FUNCTION("pxml-Safe",Company.Country) '</td></tr>' skip.
    {&prince} '<tr><td>&nbsp;</td><td>' DYNAMIC-FUNCTION("pxml-Safe",Company.PostCode) '</td></tr>' skip.

    RUN ip-InfoBanner.

    {&prince} '</table>'.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-CustomerAddress) = 0 &THEN

PROCEDURE ip-CustomerAddress :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    {&prince}
    '<table class="info">' skip.
        

    {&prince} '<tr><th style="text-align: right;">To:</th><td>' DYNAMIC-FUNCTION("pxml-Safe",Customer.Name) '</td></tr>' skip.
    {&prince} '<tr><td>&nbsp;</td><td>' DYNAMIC-FUNCTION("pxml-Safe",Customer.Address1) '</td></tr>' skip.
    {&prince} '<tr><td>&nbsp;</td><td>' DYNAMIC-FUNCTION("pxml-Safe",Customer.Address2) '</td></tr>' skip.
    {&prince} '<tr><td>&nbsp;</td><td>' DYNAMIC-FUNCTION("pxml-Safe",Customer.City) '</td></tr>' skip.
    {&prince} '<tr><td>&nbsp;</td><td>' DYNAMIC-FUNCTION("pxml-Safe",Customer.County) '</td></tr>' skip.
    {&prince} '<tr><td>&nbsp;</td><td>' DYNAMIC-FUNCTION("pxml-Safe",Customer.Country) '</td></tr>' skip.
    {&prince} '<tr><td>&nbsp;</td><td>' DYNAMIC-FUNCTION("pxml-Safe",Customer.PostCode) '</td></tr>' skip.

    {&prince} '</table>'.
    

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Header) = 0 &THEN

PROCEDURE ip-Header :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-logo AS CHARACTER         NO-UNDO.

    ASSIGN
        lc-logo = DYNAMIC-FUNCTION("pxml-FileNameLogo",pc-CompanyCode).

    
    {&prince} '<div class="heading">' skip.


    {&prince}
    '<p style="font-size: 20px; font-weight: 900; text-align: center; margin-top: 10px; margin-bottom: 10px;">'
    'HelpDesk Statement' skip.

    {&prince}
    '</p>' skip.

    
    {&prince}
    '<table class="address" width=100%>'
    '<tr>'
    '<td style="width: 350px;">' skip.
    

    RUN ip-CustomerAddress.

    
    {&prince}
    '</td>'
    '<td>' skip.
    

    RUN ip-CompanyInfo.

    {&prince}
    '</td>'
    '</tr>'


    '</table>' skip.

      
    
    {&prince} 
    '</div>'.


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-InfoBanner) = 0 &THEN

PROCEDURE ip-InfoBanner :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/


    {&prince}
        
    '<tr>'
    '<th style="text-align: right;">Page Number:</th>'
    '<td>' '<span id="thepage">&nbsp;</span>'
    '</td>'
    '</tr>'
    '<tr>'
    '<th style="text-align: right;">Period Covered:</th>'
    '<td>' STRING(ld-lo-date,'99/99/9999') ' - ' STRING(ld-hi-date,'99/99/9999') '</td>'
    '</tr>'
        .
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Print) = 0 &THEN

PROCEDURE ip-Print :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    
    RUN ip-Header.

    {&prince} '<div id="content">'.


    RUN ip-StatementDetails.

    

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-StatementDetails) = 0 &THEN

PROCEDURE ip-StatementDetails :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER webIssArea   FOR webIssArea.
    DEFINE BUFFER Ticket       FOR Ticket.

    DEFINE VARIABLE lc-Area         AS CHARACTER NO-UNDO.

    DEFINE VARIABLE li-prev-period  AS INTEGER  NO-UNDO.
    DEFINE VARIABLE li-this-period  AS INTEGER  NO-UNDO.
    DEFINE VARIABLE ll-HasTicket    AS LOG  NO-UNDO.
    DEFINE VARIABLE li-TicketNew    AS INTEGER  NO-UNDO.
    DEFINE VARIABLE li-TicketPrev   AS INTEGER  NO-UNDO.
    DEFINE VARIABLE ll-TickCols     AS LOG  NO-UNDO.
    DEFINE VARIABLE li-Activity     AS INTEGER  NO-UNDO.
    DEFINE VARIABLE lc-td           AS CHARACTER NO-UNDO.
    DEFINE VARIABLE ll-fact         AS LOG  NO-UNDO.
    
    ASSIGN
        ll-TickCols = customer.SupportTicket <> "NONE".

    FOR EACH tt NO-LOCK:
        IF tt.ticket
            THEN ASSIGN ll-TickCols = TRUE.
    END.

    {&prince}
    '<table class="landrep">'
    '<thead>'
    '<tr>'
    '<th style="text-align: right;">Issue</th>'
    '<th>Description</th>'
    '<th>Area</th>'
    '<th>Opened</th>'
    '<th>By</th>'
    '<th>Closed</th>'
    '<th>By</th>'.

    IF ll-TickCols
        THEN {&prince}
    '<th style="text-align: right;">Ticket<br/>Previous Periods</th>'
    '<th style="text-align: right;">Ticket<br/>This Period</th>'
    '<th style="text-align: right;">Ticket<br/>Total</th>'.

    {&prince}
                    
    '</tr>' skip
            '</thead>' skip
            '<tbody>' skip.

    
    FOR EACH tt NO-LOCK
        BY tt.IssueNumber:

        IF tt.ticket
            THEN ASSIGN ll-HasTicket = TRUE.

        ASSIGN
            lc-Area = "&nbsp;".
        IF tt.AreaCode <> "" THEN
        DO:

            FIND WebIssArea
                WHERE WebIssArea.CompanyCode = tt.CompanyCode
                AND WebIssArea.AreaCode    = tt.AreaCode
                NO-LOCK NO-ERROR.

            IF AVAILABLE WebIssArea
                THEN ASSIGN lc-Area = DYNAMIC-FUNCTION("pxml-safe",WebIssArea.description).
        END.
        {&prince}
        '<tr>' 
        '<td style="text-align: right;">' tt.IssueNumber '</td>' skip
                '<td>' dynamic-function("pxml-safe",tt.BriefDescription) '</td>'
                '<td>' lc-Area '</td>'
                '<td>' string(tt.IssueDate,"99/99/9999") '</td>'
                '<td>' fnUserName(tt.RaisedLoginID) '</td>'
                '<td>' if tt.udf-Close = ? then "&nbsp;" 
                       else string(tt.udf-Close,'99/99/9999') '</td>'
                '<td>' fnUserName(tt.udf-By) '</td>'.

        
        IF ll-TickCols
            THEN {&prince}
        '<td style="text-align: right;">' 
        IF tt.Ticket
            THEN DYNAMIC-FUNCTION("com-TimeToString",
                tt.udf-prev-period)
        ELSE '&nbsp;' '</td>' 
        '<td style="text-align: right;">' 
        IF tt.Ticket
            THEN DYNAMIC-FUNCTION("com-TimeToString",
                tt.udf-this-period)
        ELSE '&nbsp;' '</td>' 
        '<td style="text-align: right;">' 
        IF tt.Ticket
            THEN DYNAMIC-FUNCTION("com-TimeToString",
                tt.udf-this-period + tt.udf-prev-period)
        ELSE '&nbsp;' '</td>'.

        {&prince}
        '</tr>' skip.

        ASSIGN 
            li-prev-period = li-prev-period + tt.udf-prev-period
            li-this-period = li-this-period + tt.udf-this-period.

        IF Customer.ViewAction AND 
            CAN-FIND(FIRST IssAction NO-LOCK
            WHERE IssAction.CompanyCode = Customer.CompanyCode
            AND IssAction.IssueNumber = tt.IssueNumber
            AND IssAction.CustomerView = TRUE) THEN
        DO:
            {&prince} '<tr><td>&nbsp;</td><td style="column-span: 6;">'.
            
            
            {&prince} SKIP(2)
            '<table class="action">'
            '<thead>'
            '<tr>'
            '<th>Action</th>'
            '<th>Details</th>'
            '<th>Assigned To</th>'.

            IF Customer.ViewActivity THEN
            DO:
                {&prince}
                '<th>Activity</th>'
                '<th>Details</th>'
                '<th>Site Visit?</th>'
                '<th>By</th>'.
            END.
            {&prince}
            '</thead>'
            '</tr>'
            '<tbody>' skip.

            FOR EACH IssAction NO-LOCK
                WHERE IssAction.CompanyCode = Customer.CompanyCode
                AND IssAction.IssueNumber = tt.IssueNumber
                AND IssAction.CustomerView = TRUE
                BY IssAction.ActionDate 
                BY IssAction.CreateDate 
                BY IssAction.CreateTime:


                ASSIGN 
                    li-activity = 0.
                IF Customer.ViewActivity THEN
                    FOR EACH IssActivity NO-LOCK
                        WHERE issActivity.CompanyCode = IssAction.CompanyCode
                        AND issActivity.IssueNumber = IssAction.IssueNumber
                        AND IssActivity.IssActionId = IssAction.IssActionID
                        AND IssActivity.CustomerView
                        :
                        li-activity = li-activity + 1.
    
                    END.
                IF li-activity <= 1
                    THEN lc-td = '<td>'.
                ELSE lc-td = '<td style="row-span: ' + string(li-activity) + ';">'.

                FIND WebAction 
                    WHERE WebAction.ActionID = issAction.ActionID
                    NO-LOCK NO-ERROR.

       

                {&prince}
                '<tr>'
                lc-td STRING(issAction.ActionDate,"99/99/9999") '</td>'
                lc-td DYNAMIC-FUNCTION("pxml-safe",WebAction.Description).

                IF IssAction.Notes <> ""
                    THEN {&prince} 
                '<br />'
                REPLACE(DYNAMIC-FUNCTION("pxml-safe",IssAction.Notes),"~n","<br />").
                            
                {&prince} 
                '</td>'
                lc-td
                DYNAMIC-FUNCTION("pxml-safe",DYNAMIC-FUNCTION("com-UserName",IssAction.AssignTo))
                '</td>'.

                ASSIGN
                    ll-fact = TRUE.

                IF Customer.ViewActivity THEN
                    FOR EACH IssActivity NO-LOCK
                        WHERE issActivity.CompanyCode = IssAction.CompanyCode
                        AND issActivity.IssueNumber = IssAction.IssueNumber
                        AND IssActivity.IssActionId = IssAction.IssActionID
                        AND IssActivity.CustomerView
                        BY IssActivity.ActDate 
                        BY IssActivity.CreateDate 
                        BY IssActivity.CreateTime:

                        IF NOT ll-fact THEN
                        DO:
                            {&prince} '<tr>' skip.
                        END.

                        {&prince} 
                        '<td>' STRING(IssActivity.ActDate,"99/99/9999") '</td>'
                        '<td>' DYNAMIC-FUNCTION("pxml-safe",IssActivity.Description).
                    
                        IF IssActivity.Notes <> ""
                            THEN {&prince} 
                        '<br />'
                        REPLACE(DYNAMIC-FUNCTION("pxml-safe",IssActivity.Notes),"~n","<br />").

                        {&prince} '</td>'
                        '<td>' 
                        IF IssActivity.SiteVisit THEN "Yes" 
                        ELSE "&nbsp;" '</td>'
                        '<td>' DYNAMIC-FUNCTION("pxml-safe",
                            DYNAMIC-FUNCTION("com-UserName",IssActivity.ActivityBy))
                        '</td>'.

                        {&prince} '</tr>' skip.
                        ll-fact = FALSE.

                    END.
                {&prince} '</tr>'.
            END.

            {&prince} '</tbody></table>'.



            /* end of td */
            
            {&prince} '</td>' skip.

            IF ll-tickCols 
                THEN {&prince} '<td column-span: 3;">&nbsp;</td>'.

            {&prince} '</tr>'.
        END.

    END.

    IF ll-HasTicket THEN
    DO:
        {&prince}
        '<tr>'
        '<th style="text-align: right; column-span: 7; border-top: 1px solid black;">Total:</th>' 
        '<th style="text-align: right; border-top: 1px solid black;">' DYNAMIC-FUNCTION("com-TimeToString",li-prev-period) '</th>' 
        '<th style="text-align: right; border-top: 1px solid black;">' DYNAMIC-FUNCTION("com-TimeToString",li-this-period) '</th>' 
        '<th style="text-align: right; border-top: 1px solid black;">' DYNAMIC-FUNCTION("com-TimeToString",li-this-period + li-prev-period) '</th>' 
        '</tr>' skip.

    END.

    {&prince}
    '</tbody></table>'.

    FOR EACH ticket NO-LOCK
        WHERE ticket.CompanyCode = pc-CompanyCode
        AND ticket.AccountNumber = pc-AccountNumber
        AND ticket.TxnDate <= ld-hi-date
        /*
        AND ticket.TxnType = "TCK" 
            */:

        /*
        ***
        *** New Ticket in this period
        ***
        */
        IF ticket.TxnDate >= ld-lo-date AND ticket.TxnType = "TCK" 
            THEN ASSIGN li-TicketNew = li-TicketNew + ticket.Amount.

        /*
        ***
        *** Bfwd balance
        ***
        */
        IF ticket.TxnDate < ld-lo-date THEN
        DO: 
            IF Ticket.IssActivityID <> 0 AND pl-includeAdmin = FALSE THEN
            DO:
                IF com-IsActivityChargeable(Ticket.IssActivityID) = FALSE THEN NEXT.
            END.
            ASSIGN 
                li-TicketPrev = li-TicketPrev + ticket.Amount. 
        END.
        
    END.

    /*
    ***
    *** For ticket customers show bfwd figures
    ***
    */
    IF ll-TickCols THEN
    DO:
        {&prince}
        '<br/>'
        '<span class="total">'
        '<table class="ticket">'
        '<thead>'
        '<tr>'
        '<th style="text-align: center; column-span: 4;">Ticket Balance</th>'
                   
                    
        '</tr>' skip
                '<tr>'
                    '<th style="text-align: right;">Hours Brought Forward</th>'
                    '<th style="text-align: right;">Hours Purchased In Period</th>'
                    '<th style="text-align: right;">Hours Used In Period</th>'
                    '<th style="text-align: right;">Hours Carried Forward</th>'
                    '<th style="text-align: right;">Available Hours As Of ' string(now,"99/99/9999 hh:mm") '</th>'
                    
                '</tr>' skip
            '</thead>' skip
            '<tbody>' skip.

        {&prince}
        '<tr>' skip
                '<td style="text-align: right;">' dynamic-function("com-TimeToString",li-TicketPrev) '</td>' 
                '<td style="text-align: right;">' dynamic-function("com-TimeToString",li-TicketNew) '</td>' 
                '<td style="text-align: right;">' 
                dynamic-function("com-TimeToString",li-this-period) 
                  '</td>' 
                '<td style="text-align: right;">' dynamic-function("com-TimeToString",( li-TicketPrev + li-TicketNew)
                                                                                      - ( li-this-period )) '</td>' 
                                                                                      
                   '<td style="text-align: right;">' 
                dynamic-function("com-TimeToString",li-BalanceNow) 
                  '</td>' 



            '</tr>' skip.

        {&prince}
        '</tbody></table>'.

        {&prince}
        '</span>'.

        
    END.


    

END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-fnUserName) = 0 &THEN

FUNCTION fnUserName RETURNS CHARACTER
    ( pc-LoginID  AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER webUser FOR webUser.
 
    FIND webUser
        WHERE webuser.LoginID = pc-LoginID NO-LOCK NO-ERROR.

    IF AVAILABLE webUser 
        THEN RETURN DYNAMIC-FUNCTION("pxml-safe",webUser.Name).
    ELSE RETURN "&nbsp;".




END FUNCTION.


&ENDIF

