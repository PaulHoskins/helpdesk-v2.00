/***********************************************************************

    Program:        rep/issue.p
    
    Purpose:        Issue PDF Report     
    
    Notes:
    
    
    When        Who         What
    11/04/2006  phoski      Initial - replace old version      
    
    14/09/2010  DJS         3708 Additional changes for date selection
***********************************************************************/
                                          
{lib/htmlib.i}
{lib/princexml.i}


&IF DEFINED(UIB_is_Running) EQ 0 &THEN

DEFINE INPUT PARAMETER pc-CompanyCode      AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-Account          AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-Status           AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-Assign           AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-Area             AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-user             AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-category         AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-lodate           AS CHARACTER NO-UNDO.  /* 3708  */
DEFINE INPUT PARAMETER pc-hidate           AS CHARACTER NO-UNDO.  /* 3708  */
DEFINE OUTPUT PARAMETER pc-pdf             AS CHARACTER NO-UNDO.

&ELSE

DEFINE VARIABLE pc-CompanyCode              AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-Account                  AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-Status                   AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-Assign                   AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-Area                     AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-user                     AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-category                 AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-lodate                   AS CHARACTER NO-UNDO.     /* 3708  */  
DEFINE VARIABLE pc-hidate                   AS CHARACTER NO-UNDO.     /* 3708  */  
DEFINE VARIABLE pc-pdf                      AS CHARACTER NO-UNDO.

ASSIGN 
    pc-Account   = htmlib-Null()
    pc-status = htmlib-Null()
    pc-assign = htmlib-Null()
    pc-Area   = htmlib-Null()
    pc-user   = 'phoski'
    pc-category = htmlib-Null()
    pc-CompanyCode = "MICAR"
    pc-lodate  = STRING(TODAY - 30 )       /* 3708  */  
    pc-hidate  = STRING(TODAY)             /* 3708  */  
    .

&ENDIF


DEFINE TEMP-TABLE tt NO-UNDO
    FIELD lineno        AS INTEGER
    FIELD n-date        AS DATE
    FIELD n-time        AS INTEGER
    FIELD n-user        AS CHARACTER
    FIELD n-contents    AS CHARACTER
    FIELD s-date        AS DATE
    FIELD s-time        AS INTEGER
    FIELD s-user        AS CHARACTER
    FIELD s-status      AS CHARACTER
    INDEX lineno
    lineno.

DEFINE BUFFER  WebUser     FOR WebUser.
DEFINE BUFFER  b-query     FOR Issue.
DEFINE BUFFER  b-status    FOR WebStatus.
DEFINE BUFFER  b-area      FOR WebIssArea.
DEFINE BUFFER  b-user      FOR WebUser.

DEFINE QUERY q FOR b-query SCROLLING.


DEFINE VARIABLE lc-pdf-file     AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-current-y    AS INTEGER NO-UNDO.
DEFINE VARIABLE li-max-y        AS INTEGER INITIAL 50 NO-UNDO.
DEFINE VARIABLE li-current-page AS INTEGER NO-UNDO.

DEFINE VARIABLE lc-status       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-area         AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-open-status  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-closed-status AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-acc-lo       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-acc-hi       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ass-lo       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ass-hi       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-area-lo      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-area-hi      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-srch-status  AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop         AS INTEGER NO-UNDO.
DEFINE VARIABLE lc-char         AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-count        AS INTEGER  NO-UNDO.
DEFINE VARIABLE lc-cat-lo       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-cat-hi       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-date-lo      AS CHARACTER NO-UNDO.        /* 3708  */  
DEFINE VARIABLE lc-date-hi      AS CHARACTER NO-UNDO.        /* 3708  */  

DEFINE VARIABLE lc-html         AS CHARACTER     NO-UNDO.
DEFINE VARIABLE lc-pdf          AS CHARACTER     NO-UNDO.
DEFINE VARIABLE ll-ok           AS LOG      NO-UNDO.
DEFINE VARIABLE li-ReportNumber AS INTEGER      NO-UNDO.
DEFINE VARIABLE ll-customer     AS LOG      NO-UNDO.




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


FIND WebUser WHERE WebUser.LoginID = pc-user NO-LOCK NO-ERROR.
ASSIGN
    ll-customer = WebUser.UserClass = "CUSTOMER".

RUN ip-StatusType ( OUTPUT lc-open-status , OUTPUT lc-closed-status ).

RUN ip-SetRanges.

ASSIGN
    pc-pdf = ?
    li-ReportNumber = NEXT-VALUE(ReportNumber).
ASSIGN 
    lc-html = SESSION:TEMP-DIR + caps(pc-CompanyCode) + "-IssueReport-" + string(li-ReportNumber).

ASSIGN 
    lc-pdf = lc-html + ".pdf"
    lc-html = lc-html + ".html".

OS-DELETE value(lc-pdf) no-error.
OS-DELETE value(lc-html) no-error.


DYNAMIC-FUNCTION("pxml-Initialise").

CREATE tt-pxml.
ASSIGN 
    tt-pxml.PageOrientation = "LANDSCAPE".

DYNAMIC-FUNCTION("pxml-OpenStream",lc-html).
DYNAMIC-FUNCTION("pxml-Header", pc-CompanyCode).

RUN ip-Print.

DYNAMIC-FUNCTION("pxml-Footer",pc-CompanyCode).
DYNAMIC-FUNCTION("pxml-CloseStream").


ll-ok = DYNAMIC-FUNCTION("pxml-Convert",lc-html,lc-pdf).

IF ll-ok
    THEN ASSIGN pc-pdf = lc-pdf.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-Print) = 0 &THEN

PROCEDURE ip-Print :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER IssNote FOR IssNote.
    DEFINE BUFFER Customer FOR Customer.
    DEFINE BUFFER b-assign FOR WebUser.


    DEFINE VARIABLE lc-customer AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-assign   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-line     AS INTEGER  NO-UNDO.

    OPEN QUERY q FOR EACH b-query NO-LOCK
        WHERE b-query.CompanyCode = pc-CompanyCode
        AND b-query.AccountNumber >= lc-acc-lo
        AND b-query.AccountNumber <= lc-acc-hi
        AND b-query.AssignTo >= lc-ass-lo
        AND b-query.AssignTo <= lc-ass-hi
        AND b-query.AreaCode >= lc-area-lo
        AND b-query.AreaCode <= lc-area-hi
        AND b-query.CatCode  >= lc-cat-lo
        AND b-query.CatCode  <= lc-cat-hi
        AND b-query.CreateDate  >= date(lc-date-lo)              /* 3708  */  
        AND b-query.CreateDate  <= date(lc-date-hi)              /* 3708  */  
        AND can-do(lc-srch-status,b-query.StatusCode)
        BY b-query.IssueNumber.

    GET FIRST q NO-LOCK.
    REPEAT WHILE AVAILABLE b-query:

        FIND b-status OF b-query NO-LOCK NO-ERROR.

        IF AVAILABLE b-status THEN
        DO:
            ASSIGN 
                lc-status = b-status.Description.
            IF b-status.CompletedStatus
                THEN lc-status = lc-status + ' (closed)'.
            ELSE lc-status = lc-status + ' (open)'.

            ASSIGN 
                lc-status = pxml-safe(lc-status).
        END.
        ELSE lc-status = "&nbsp;".

        FIND b-area OF b-query NO-LOCK NO-ERROR.
        ASSIGN 
            lc-area = IF AVAILABLE b-area 
                     THEN pxml-safe(b-area.Description)
                     ELSE "&nbsp;".

        FIND Customer OF b-query NO-LOCK 
            NO-ERROR.
        ASSIGN 
            lc-customer = IF AVAILABLE Customer
                        THEN pxml-safe(Customer.name) ELSE "Missing".
    
        FIND b-assign WHERE b-assign.loginid = b-query.AssignTo NO-LOCK NO-ERROR.
        ASSIGN 
            lc-assign = IF AVAILABLE b-assign THEN pxml-safe(b-assign.Name)
                       ELSE "".
    

    
        /*
        ***
        *** Header Here
        ***
        */

        {&prince}
        '<table class="hinfo">' skip
        '<thead><tr>' skip
            '<th>Issue Number:</th><td>' b-query.IssueNumber '</td>' skip
             '<th>Date:</th>' skip
            '<td>' string(b-query.Issuedate,'99/99/9999') '</td>' skip
            '<th>Status:</th><td>' lc-status '</td>' skip
            '<th>Area:</th><td>' lc-area '</td>' skip

        '</tr>' skip.
        {&prince}
        '<tr>'
        '<th>Customer:</th>'
        '<td>' lc-Customer '</td>' skip
            '<td colspan="4">' 
                replace(pxml-safe(b-query.BriefDescription + '~n' + b-query.longdescription),'~n','<BR>')
            '</td>'
            '<th>Assigned:</th>'
            '<td>' lc-assign '</td>'
        '</tr></thead>' skip.      


        {&prince} '</table>'.
        EMPTY TEMP-TABLE tt.

        ASSIGN 
            li-line = 0.

        FOR EACH IssNote NO-LOCK OF b-query
            BY IssNote.CreateDate DESCENDING
            BY IssNote.CreateTime DESCENDING
            :
            FIND webnote OF IssNote NO-LOCK NO-ERROR.
            IF NOT AVAILABLE webNote THEN NEXT.
            IF ll-customer AND NOT WebNote.CustomerCanView THEN NEXT.
        
            FIND b-user WHERE b-user.loginid = IssNote.Loginid NO-LOCK NO-ERROR.

            ASSIGN 
                li-line = li-line + 1.
            CREATE tt.
            ASSIGN 
                tt.lineno = li-line
                tt.n-date = IssNote.CreateDate
                tt.n-time = IssNote.CreateTime
                tt.n-user = IF AVAILABLE b-user 
                           THEN b-user.name ELSE ""
                tt.n-contents = IssNote.contents.
        END.

        FOR EACH IssStatus NO-LOCK OF b-query
            BY IssStatus.ChangeDate DESCENDING
            BY IssStatus.ChangeTime DESCENDING:

            FIND b-user WHERE b-user.Loginid = IssStatus.LoginId NO-LOCK NO-ERROR.
            FIND b-status WHERE b-status.companyCode = b-query.CompanyCode
                AND b-status.StatusCode = IssStatus.NewStatusCode
                NO-LOCK NO-ERROR.
            FIND FIRST tt WHERE tt.s-date = ? EXCLUSIVE-LOCK NO-ERROR.
            IF NOT AVAILABLE tt THEN
            DO:
                FIND LAST tt NO-LOCK NO-ERROR.
                ASSIGN 
                    li-line = IF AVAILABLE tt THEN tt.lineno + 1
                               ELSE 1.
                CREATE tt.
                ASSIGN 
                    tt.lineno = li-line.
            END.
            ASSIGN 
                tt.s-date = IssStatus.ChangeDate
                tt.s-time = IssStatus.ChangeTime
                tt.s-user = IF AVAILABLE b-user THEN b-user.name ELSE ""
                tt.s-status = IF AVAILABLE b-status THEN b-status.description
                             ELSE "".
        END.

        FIND FIRST tt NO-LOCK NO-ERROR.
        IF AVAILABLE tt THEN
        DO:
            {&prince}
            '<table class="browse">' skip
            '<thead>' skip
            '<tr><th colspan="3" style="border-bottom: none;">Notes</th><th colspan="3" style="border-bottom: none;">Status Changes</th></tr>'
            '<tr><th>Date</th><th>User</th><th>Details</th><th>Date</th><th>User</th><th>Status</tr></thead>' skip.

            FOR EACH tt NO-LOCK:
                {&prince}
                '<tr>'
                '<td>'
                IF tt.n-date = ? THEN "&nbsp;" 
                ELSE STRING(tt.n-date,"99/99/9999") + "&nbsp;" + string(tt.n-time,"hh:mm am")
                '</td>'
                '<td>'
                IF tt.n-user = "" THEN "&nbsp;"
                ELSE pxml-safe(tt.n-user)
                '</td>'
                '<td>'
                IF tt.n-contents = "" THEN "&nbsp;"
                ELSE REPLACE(pxml-safe(tt.n-contents),'~n','<BR>')
                '</td>'

                '<td>'
                IF tt.s-date = ? THEN "&nbsp;" 
                ELSE STRING(tt.s-date,"99/99/9999") + "&nbsp;" + string(tt.s-time,"hh:mm am")
                '</td>'
                '<td>'
                IF tt.s-user = "" THEN "&nbsp;"
                ELSE pxml-safe(tt.s-user)
                '</td>'
                '<td>'
                IF tt.s-status = "" THEN "&nbsp;"
                ELSE pxml-safe(tt.s-status)
                '</td>'



                '</tr>' skip.


            
            END.

            {&prince} '</table>' skip.
        
        END.

        {&prince}
        '<br>' skip.
    
        GET NEXT q NO-LOCK.

    
    END.




END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-PrintRange) = 0 &THEN

PROCEDURE ip-PrintRange :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-account      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-status       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-area         AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-assign       AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-cust FOR Customer.
    DEFINE BUFFER b-Status FOR WebStatus.
    DEFINE BUFFER b-Area   FOR WebIssArea.
    DEFINE BUFFER b-user   FOR WebUser.

    IF pc-account = htmlib-Null()
        THEN ASSIGN lc-account = 'All'.
    ELSE
    DO:
        FIND b-cust WHERE b-cust.AccountNumber = pc-account NO-LOCK NO-ERROR.
        ASSIGN 
            lc-account = IF AVAILABLE b-cust THEN b-cust.name ELSE "".
    END.

    CASE pc-status:
        WHEN 'allopen' THEN 
            lc-status = 'Open'.
        WHEN 'allclosed' THEN 
            lc-status = 'Closed'.
        WHEN htmlib-null() THEN 
            lc-status = 'All'.
        OTHERWISE
        DO:
            FIND b-status WHERE b-status.StatusCode = pc-status NO-LOCK NO-ERROR.
            ASSIGN 
                lc-status = IF AVAILABLE b-status
                               THEN b-status.Description ELSE pc-status.
        END.
    END CASE.

    IF pc-Area = htmlib-Null()
        THEN ASSIGN lc-area = 'All'.
    ELSE
    DO:
        FIND b-area WHERE b-area.AreaCode = pc-Area NO-LOCK NO-ERROR.
        ASSIGN 
            lc-area = IF AVAILABLE b-area 
                         THEN b-area.Description ELSE "".
    END.

    CASE pc-Assign:
        WHEN 'NotAssigned' THEN 
            lc-assign = 'Not Assigned'.
        WHEN htmlib-Null() THEN 
            lc-assign = 'All'.
        OTHERWISE
        DO:
            FIND b-user WHERE b-user.LoginID = pc-assign NO-LOCK NO-ERROR.
            ASSIGN 
                lc-assign = IF AVAILABLE b-user THEN b-user.name ELSE "".
        END.
    END CASE.
    
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-SetRanges) = 0 &THEN

PROCEDURE ip-SetRanges :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    IF pc-account = htmlib-Null()
        THEN ASSIGN lc-acc-lo = ""
            lc-acc-hi = "ZZZZZZZZZZZZZZZZZZZZZZZZ".
    ELSE ASSIGN lc-acc-lo = pc-account
            lc-acc-hi = pc-account.

    IF ll-Customer
        THEN ASSIGN lc-acc-lo = webuser.AccountNumber
            lc-acc-hi = webUser.AccountNumber.

    IF pc-status = htmlib-Null() 
        THEN ASSIGN lc-srch-status = "*".
    ELSE
        IF pc-status = "AllOpen" 
            THEN ASSIGN lc-srch-status = lc-open-status.
        ELSE 
            IF pc-status = "AllClosed"
                THEN ASSIGN lc-srch-status = lc-closed-status.
            ELSE ASSIGN lc-srch-status = pc-status.

    
    IF pc-assign = htmlib-null() 
        THEN ASSIGN lc-ass-lo = ""
            lc-ass-hi = "ZZZZZZZZZZZZZZZZ".
    ELSE
        IF pc-assign = "NotAssigned" 
            THEN ASSIGN lc-ass-lo = ""
                lc-ass-hi = "".
        ELSE ASSIGN lc-ass-lo = pc-assign
                lc-ass-hi = pc-assign.

    IF pc-area = htmlib-null() 
        THEN ASSIGN lc-area-lo = ""
            lc-area-hi = "ZZZZZZZZZZZZZZZZ".
    ELSE
        IF pc-area = "NotAssigned" 
            THEN ASSIGN lc-area-lo = ""
                lc-area-hi = "".
        ELSE ASSIGN lc-area-lo = pc-area
                lc-area-hi = pc-area.

    IF pc-category = htmlib-Null()
        THEN ASSIGN lc-cat-lo = ""
            lc-cat-hi = "zzzzzzzzzzzzzzz".
    ELSE ASSIGN lc-cat-lo = pc-category
            lc-cat-hi = pc-category.

    IF pc-lodate = htmlib-Null()                             /* 3708  */  
        THEN ASSIGN lc-date-lo = STRING(TODAY - 365)             /* 3708  */  
            lc-date-hi = STRING(TODAY).                  /* 3708  */  
    ELSE ASSIGN lc-date-lo = pc-lodate                       /* 3708  */  
            lc-date-hi = pc-hidate.



END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-StatusType) = 0 &THEN

PROCEDURE ip-StatusType :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE OUTPUT PARAMETER    pc-open-status      AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER    pc-closed-status    AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-status FOR WebStatus.

    FOR EACH b-status NO-LOCK:
        IF b-status.CompletedStatus = FALSE 
            THEN ASSIGN pc-open-status = TRIM(pc-open-status + ',' + b-status.StatusCode).
        ELSE ASSIGN pc-closed-status = TRIM(pc-closed-status + ',' + b-status.StatusCode).
       
    END.

END PROCEDURE.


&ENDIF

