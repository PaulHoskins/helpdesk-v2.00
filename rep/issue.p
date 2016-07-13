/*------------------------------------------------------------------------
    File        : 
    Purpose     :

    Syntax      :

    Description :

    Author(s)   :
    Created     :
    Notes       :
  ----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


{lib/htmlib.i}
{lib/pdf_inc.i}
{lib/pdf_rep.i}

&IF DEFINED(UIB_is_Running) EQ 0 &THEN

DEFINE INPUT PARAMETER pc-Account          AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-Status           AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-Assign           AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-Area             AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-user             AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER pc-file            AS CHARACTER NO-UNDO.

&ELSE

DEFINE VARIABLE pc-Account                  AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-Status                   AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-Assign                   AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-Area                     AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-user                     AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-file                     AS CHARACTER NO-UNDO.

ASSIGN 
    pc-Account   = htmlib-Null()
    pc-status = htmlib-Null()
    pc-assign = htmlib-Null()
    pc-Area   = htmlib-Null()
    pc-user   = 'phoskins'.

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




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-CheckPage) = 0 &THEN

FUNCTION CheckPage RETURNS LOGICAL
    ( /* parameter-definitions */ )  FORWARD.


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


RUN ip-StatusType ( OUTPUT lc-open-status , OUTPUT lc-closed-status ).

RUN ip-SetRanges.

ASSIGN 
    pc-file = replib-FileName().

OS-DELETE value(pc-file) no-error.

RUN pdf_new ("Spdf",pc-file).

RUN pdf_set_Orientation ("Spdf","Landscape").
RUN pdf_set_PaperType ("Spdf","A4").

RUN replib-NewPage("Micar Computer Systems","Issue Report",
    INPUT-OUTPUT li-current-page).
RUN ip-PrintRange.

RUN ip-ReportHeading.

RUN ip-Print.

RUN pdf_set_font ("Spdf","Times-Bold",10.0).
DO li-count = 1 TO 20:
    RUN pdf_skip("Spdf").
END.
RUN pdf_text_at ( "Spdf", "End of report",140).


RUN pdf_close("Spdf").



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-Print) = 0 &THEN

PROCEDURE ip-Print :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER b-note FOR IssNote.
    DEFINE BUFFER b-cust FOR Customer.
    DEFINE BUFFER b-assign FOR WebUser.


    DEFINE VARIABLE lc-customer AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-assign   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-line     AS INTEGER  NO-UNDO.

    OPEN QUERY q FOR EACH b-query NO-LOCK
        WHERE b-query.AccountNumber >= lc-acc-lo
        AND b-query.AccountNumber <= lc-acc-hi
        AND b-query.AssignTo >= lc-ass-lo
        AND b-query.AssignTo <= lc-ass-hi
        AND b-query.AreaCode >= lc-area-lo
        AND b-query.AreaCode <= lc-area-hi
        AND can-do(lc-srch-status,b-query.StatusCode)
        BY b-query.IssueNumber.

    GET FIRST q NO-LOCK.
    REPEAT WHILE AVAILABLE b-query:

        FIND b-status WHERE b-status.StatusCode = 
            b-query.StatusCode NO-LOCK NO-ERROR.
        IF AVAILABLE b-status THEN
        DO:
            ASSIGN 
                lc-status = b-status.Description.
            IF b-status.CompletedStatus
                THEN lc-status = lc-status + ' (closed)'.
            ELSE lc-status = lc-status + ' (open)'.
        END.
        ELSE lc-status = "".

        FIND b-area WHERE b-area.AreaCode = b-query.AreaCode 
            NO-LOCK NO-ERROR.
        ASSIGN 
            lc-area = IF AVAILABLE b-area 
                     THEN b-area.Description ELSE "".

        FIND b-cust WHERE b-cust.AccountNumber = b-query.AccountNumber NO-LOCK 
            NO-ERROR.
        ASSIGN 
            lc-customer = IF AVAILABLE b-cust
                        THEN b-cust.name ELSE "Missing".
    
        FIND b-assign WHERE b-assign.loginid = b-query.AssignTo NO-LOCK NO-ERROR.
        ASSIGN 
            lc-assign = IF AVAILABLE b-assign THEN b-assign.Name
                       ELSE "".
        CheckPage().


        RUN pdf_set_font ("Spdf","Times-Bold",10.0).
        RUN pdf_text_at ( "Spdf", '      Issue: ' + string(b-Query.IssueNumber)
            ,1).
        RUN pdf_text_at ( "Spdf", b-Query.BriefDescription,30).


        RUN pdf_text_at ( "Spdf", 'Date: ' + string(b-Query.IssueDate,'99/99/9999'),
            120).
    
        RUN pdf_text_at ( "Spdf", 'Status: ' + lc-status,
            150).

        RUN pdf_text_at ( "Spdf", 'Area: ' + lc-area,
            240).
        RUN pdf_skip("Spdf").
    
        DO li-loop = 1 TO NUM-ENTRIES(b-Query.LongDescription,'~n'):
            CheckPage().
            RUN pdf_set_font ("Spdf","Times-Roman",10.0).
            ASSIGN 
                lc-char = ENTRY(li-loop,b-Query.LongDescription,'~n').
            RUN pdf_text_at  ("Spdf", lc-char,30).
            RUN pdf_skip("Spdf").
        END.

        CheckPage().
        RUN pdf_set_font ("Spdf","Times-Roman",10.0).
        RUN pdf_text_at ( "Spdf", 'Customer: ' + lc-customer
            ,1).
        RUN pdf_text_at ( "Spdf", 'Assigned: ' + lc-assign,
            114).
        RUN pdf_skip("Spdf").

        FOR EACH tt EXCLUSIVE-LOCK:
            DELETE tt.
        END.

        ASSIGN 
            li-line = 0.

        FOR EACH b-note NO-LOCK 
            WHERE b-note.IssueNumber = b-Query.IssueNumber 
            BY b-note.CreateDate DESCENDING
            BY b-note.CreateTime DESCENDING
           
            :
        
            FIND b-user WHERE b-user.loginid = b-note.Loginid NO-LOCK NO-ERROR.

            ASSIGN 
                li-line = li-line + 1.
            CREATE tt.
            ASSIGN 
                tt.lineno = li-line
                tt.n-date = b-note.CreateDate
                tt.n-time = b-note.CreateTime
                tt.n-user = IF AVAILABLE b-user 
                           THEN b-user.name ELSE ""
                tt.n-contents = ENTRY(1,b-note.contents,'~n').
            .
            IF NUM-ENTRIES(b-note.contents,'~n') > 1 THEN
            DO li-loop = 2 TO NUM-ENTRIES(b-note.contents,'~n'):
                IF TRIM(ENTRY(li-loop,b-note.contents,'~n')) = '' THEN NEXT.
                ASSIGN 
                    li-line = li-line + 1.
                CREATE tt.
                ASSIGN 
                    tt.lineno = li-line
                    tt.n-contents = ENTRY(li-loop,b-note.contents,'~n').

            END.
        END.

        FOR EACH IssStatus NO-LOCK
            WHERE IssStatus.IssueNumber = b-query.IssueNumber
            BY IssStatus.ChangeDate DESCENDING
            BY IssStatus.ChangeTime DESCENDING:

            FIND b-user WHERE b-user.Loginid = IssStatus.LoginId NO-LOCK NO-ERROR.
            FIND b-status WHERE b-status.StatusCode = IssStatus.NewStatusCode
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
            CheckPage().
            RUN pdf_set_font ("Spdf","Times-Bold",10.0).
            RUN pdf_text_at ( "Spdf","Notes",1).
            RUN pdf_text_at ( "Spdf","Status Changes",175).
            RUN pdf_skip ("Spdf").
            CheckPage().
            RUN pdf_set_font ("Spdf","Times-Roman",10.0).
            RUN pdf_text_at ( "Spdf","Date",1).
            RUN pdf_text_at ( "Spdf","User",38).
            RUN pdf_text_at ( "Spdf","Details",65).

            RUN pdf_text_at ("Spdf","Date",175).
            RUN pdf_text_at ("Spdf","User",212).
            RUN pdf_text_at ("Spdf","Status",240).

            RUN pdf_skip ("Spdf").

            FOR EACH tt:
                CheckPage().
                IF tt.n-date <> ?
                    OR tt.n-contents <> "" THEN
                DO:
                    IF tt.n-date <> ? 
                        THEN RUN pdf_text_at("Spdf",STRING(tt.n-date,'99/99/9999') 
                            + ' ' + string(tt.n-time,'hh:mm am'),1).
                END.
                RUN pdf_text_at ("Spdf", tt.n-user,38).
                RUN pdf_text_at ("Spdf", tt.n-contents,65).

                IF tt.s-date <> ? THEN
                DO:
                    RUN pdf_text_at("Spdf",STRING(tt.s-date,'99/99/9999') 
                        + ' ' + string(tt.s-time,'hh:mm am'),175).
                END.
                RUN pdf_text_at("Spdf",tt.s-user,212).
                RUN pdf_text_at("Spdf",tt.s-status,240).
                RUN pdf_Skip("Spdf").
            END.
        
        END.

   
        RUN pdf_set_dash ("Spdf",1,0).
        RUN pdf_line  ("Spdf", pdf_LeftMargin("Spdf"), pdf_TextY("Spdf") + 5, pdf_PageWidth("Spdf") - 20 , pdf_TextY("Spdf") + 5, 2).
        RUN pdf_skip ("Spdf").

        GET NEXT q NO-LOCK.

        IF AVAILABLE b-query THEN
        DO:
            IF NOT CheckPage()
                THEN RUN pdf_skip("Spdf").
        END.
    
    END.

    DO WHILE TRUE:
        RUN pdf_skip("Spdf").
        RUN pdf_text_at  ("Spdf", FILL(" ",60),1).
        IF CheckPage() THEN LEAVE.
    
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
    RUN pdf_set_font ("Spdf","Times-Bold",12.0).
    RUN pdf_text_at ( "Spdf", "Report Criteria",30).
    RUN pdf_skip("Spdf").
    RUN pdf_text_at  ("Spdf", "Account:",30).
    RUN pdf_text_at  ("Spdf",lc-Account,50).
    RUN pdf_skip("Spdf").
    RUN pdf_text_at  ("Spdf", "Status:",34).
    RUN pdf_text_at  ("Spdf",lc-Status,50).
    RUN pdf_skip("Spdf").
    RUN pdf_text_at  ("Spdf", "Area:",36).
    RUN pdf_text_at  ("Spdf",lc-Area,50).
    RUN pdf_skip("Spdf").
    RUN pdf_text_at  ("Spdf", "Assigned To:",23).
    RUN pdf_text_at  ("Spdf",lc-assign,50).
    RUN pdf_skip("Spdf").
    RUN pdf_skip("Spdf").
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-ReportHeading) = 0 &THEN

PROCEDURE ip-ReportHeading :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    RETURN.

    
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

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-CheckPage) = 0 &THEN

FUNCTION CheckPage RETURNS LOGICAL
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    
    DEFINE VARIABLE ll-skip AS LOG NO-UNDO.
    
    
    ASSIGN 
        li-current-y = pdf_textY("Spdf")
        ll-skip      = FALSE.
    IF li-current-y <= li-max-y THEN 
    DO:
        RUN replib-NewPage("Micar Computer Systems","Issue Report",
            INPUT-OUTPUT li-current-page).
        RUN ip-ReportHeading.
        ASSIGN 
            ll-skip = TRUE.
    END.
    RETURN ll-skip.

END FUNCTION.


&ENDIF

