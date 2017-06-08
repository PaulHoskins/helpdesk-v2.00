/***********************************************************************

    Program:        rep/issueexport.p
    
    Purpose:        Issue Export Report
    
    Notes:
    
    
    When        Who         What
    
    08/06/2017  phoski      Initial
    
           
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-char        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-lo-account  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-hi-account  AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-lodate      AS CHARACTER FORMAT "99/99/9999" NO-UNDO.
DEFINE VARIABLE lc-hidate      AS CHARACTER FORMAT "99/99/9999" NO-UNDO.

DEFINE BUFFER this-user FOR WebUser.
  
DEFINE VARIABLE ll-Customer    AS LOG       NO-UNDO.

DEFINE VARIABLE lc-list-acc    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-aname  AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-stcode AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-stname AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-filename    AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-CodeName    AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop        AS INTEGER   NO-UNDO.

DEFINE VARIABLE lc-ClassList   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-output      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-1Day        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-st-num      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-dtype       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-dtcode AS CHARACTER INITIAL 'ISS|ACT|ISSACT' NO-UNDO.
DEFINE VARIABLE lc-list-dtdesc AS CHARACTER INITIAL 'Issue|Activity|Issue And Activity' NO-UNDO.



{rep/issueexporttt.i}
{lib/maillib.i}

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-Format-Select-Account) = 0 &THEN

FUNCTION CSVHeader RETURNS CHARACTER 
    (pc-data AS CHARACTER) FORWARD.

FUNCTION fnTimeString RETURNS CHARACTER 
    (pi-Seconds AS INTEGER) FORWARD.

FUNCTION Format-Select-Account RETURNS CHARACTER
    ( pc-htm AS CHARACTER )  FORWARD.


&ENDIF


/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 14.15
         WIDTH              = 60.57.
/* END WINDOW DEFINITION */
                                                                        */

/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}
    {lib/htmlib.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */


RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-ExportJScript) = 0 &THEN

PROCEDURE ip-ExportJScript :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    {&out} SKIP
        '<script language="JavaScript" src="/scripts/js/hidedisplay.js"></script>' SKIP.

    {&out} SKIP 
        '<script language="JavaScript">' SKIP.

    {&out} SKIP
        'function ChangeAccount() ~{' SKIP
        '   SubmitThePage("AccountChange")' SKIP
        '~}' SKIP

        'function ChangeStatus() ~{' SKIP
        '   SubmitThePage("StatusChange")' SKIP
        '~}' SKIP

        'function ChangeDates() ~{' SKIP
        /* '   SubmitThePage("DatesChange")' skip */
        '~}' SKIP.

    {&out} SKIP
        '</script>' SKIP.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-ExportReport) = 0 &THEN

PROCEDURE ip-ExportReport :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-filename AS CHARACTER NO-UNDO.
    

    DEFINE BUFFER customer FOR customer.
    DEFINE BUFFER issue    FOR issue.
    

    DEFINE VARIABLE lc-GenKey AS CHARACTER NO-UNDO.

   
    ASSIGN
        lc-genkey = STRING(NEXT-VALUE(ReportNumber)).
    
        
    pc-filename = SESSION:TEMP-DIR + "/IssueExport-" + lc-GenKey
        + ".csv".

    OUTPUT TO VALUE(pc-filename).

    PUT UNFORMATTED
        CSVHeader(
        "Customer|Issue Number|Description|Issue Date|Contract|Billable|Details|Raised By|Area|Status" +
        "|Issue Class|SLA|Assign To|Action Type|Action Date" +  
        "|Action Assigned To|Action Note|Action Status|Customer View|Activity Type|Activity Date|Activity Start Date|Acivity Description" +
        "|Description|Activity By|Site Visit|Duration|Billable|Administration"
         
        )
               
        SKIP.


    FOR EACH tt-ilog NO-LOCK
        BREAK BY tt-ilog.AccountNumber
        BY tt-ilog.IssueNumber
        :
            
        FIND customer WHERE customer.CompanyCode = lc-global-company
            AND customer.AccountNumber = tt-ilog.AccountNumber
            NO-LOCK NO-ERROR.


        EXPORT DELIMITER ','
            ( customer.AccountNumber + " " + customer.NAME )
            tt-ilog.issuenumber
            tt-ilog.briefDescription
            STRING(tt-ilog.CreateDate,"99/99/9999")
            STRING(tt-ilog.ContractType)
            STRING(tt-ilog.iBillable)
            STRING(tt-ilog.iLongDesc)
            STRING(tt-ilog.RaisedLoginID)
            STRING(tt-ilog.cArea)
            STRING(tt-ilog.cStatus)
            STRING(tt-ilog.iType)
            STRING(tt-ilog.SLADesc)    
            STRING(tt-ilog.cAssignTo) 
            STRING(tt-ilog.cActionType)
            STRING(tt-ilog.actionDate,"99/99/9999")
            STRING(tt-ilog.cActionAssignTo) 
            STRING(tt-ilog.ActionNote)
            STRING(tt-ilog.Actionstatus)     
            STRING(tt-ilog.ActionCustomerView)  
            STRING(tt-ilog.ActivityType)
            STRING(tt-ilog.actDate,"99/99/9999") 
            STRING(tt-ilog.startDate,"99/99/9999")    
            STRING(tt-ilog.ActTypeDesc)
            STRING(tt-ilog.ActDesc) 
            STRING(tt-ilog.ActivityBy)
            STRING(tt-ilog.SiteVisit) 
            STRING(tt-ilog.duration) 
            STRING(tt-ilog.ActBillable)
            STRING(tt-ilog.isAdmin)   
            .
            
            

        . 
           
    END.

    OUTPUT CLOSE.


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-InitialProcess) = 0 &THEN

PROCEDURE ip-InitialProcess :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-temp AS CHARACTER NO-UNDO.
    
    IF ll-customer THEN
    DO:
        ASSIGN 
            lc-lo-account = this-user.AccountNumber.
        set-user-field("loaccount",this-user.AccountNumber).
        set-user-field("hiaccount",this-user.AccountNumber).
    END.
        
    ASSIGN
        lc-lo-account = get-value("loaccount")
        lc-hi-account = get-value("hiaccount")    
        lc-lodate     = get-value("lodate")         
        lc-hidate     = get-value("hidate")
        lc-output     = get-value("output")
        lc-submit     = get-value("submitsource")
        lc-temp       = get-value("allcust")
        lc-st-num     = get-value("st-num")
        lc-dtype      = get-value("dtype").
    
    
    IF lc-temp = "on"
        THEN RUN com-GetCustomerAccount( lc-global-accStatus-HelpDesk-All , lc-global-company , lc-global-user, OUTPUT lc-list-acc, OUTPUT lc-list-aname ).
    ELSE RUN com-GetCustomerAccount( lc-global-accStatus-HelpDesk-Active , lc-global-company , lc-global-user, OUTPUT lc-list-acc, OUTPUT lc-list-aname ).


    ASSIGN
        lc-list-stcode = "ALL"
        lc-list-stname = "All Support Teams".
        
    FOR EACH steam WHERE steam.CompanyCode = lc-global-company:
        ASSIGN
            lc-list-stcode = lc-list-stcode + "|" + string(steam.st-num)
            lc-list-stname = lc-list-stname + "|" + steam.descr.
        
    END.
    
    

    IF request_method = "GET" THEN
    DO:
        IF lc-st-num = "" THEN lc-st-num = "ALL".
        IF lc-dtype = "" THEN lc-Dtype = "ISS".
        
                
        IF lc-lodate = ""
            THEN ASSIGN lc-lodate = STRING(TODAY - 365, "99/99/9999").
        
        IF lc-hidate = ""
            THEN ASSIGN lc-hidate = STRING(TODAY, "99/99/9999").
        
        
        IF lc-lo-account = ""
            THEN ASSIGN lc-lo-account = ENTRY(1,lc-list-acc,"|").
    
        IF lc-hi-account = ""
            THEN ASSIGN lc-hi-account = ENTRY(NUM-ENTRIES(lc-list-acc,"|"),lc-list-acc,"|").

        DO li-loop = 1 TO NUM-ENTRIES(lc-global-iclass-code,"|"):
            lc-codeName = "chk" + ENTRY(li-loop,lc-global-iclass-code,"|").
            set-user-field(lc-codeName,"on").
        END.
    END.

    
    

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-PrintReport) = 0 &THEN


PROCEDURE ip-PrintReport :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER customer FOR customer.
    DEFINE BUFFER issue    FOR issue.
    DEFINE VARIABLE li-count AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-tr    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-eng   AS INTEGER   NO-UNDO.
    
    DEFINE BUFFER tt-ilog FOR tt-ilog.
    
    
    FOR EACH tt-ilog NO-LOCK
        BREAK BY tt-ilog.AccountNumber
        BY tt-ilog.IssueNumber
        :

        IF FIRST-OF(tt-ilog.AccountNumber) THEN
        DO:
            FIND customer WHERE customer.CompanyCode = lc-global-company
                AND customer.AccountNumber = tt-ilog.AccountNumber
                NO-LOCK NO-ERROR.
            {&out} htmlib-BeginCriteria("Customer - " + tt-ilog.AccountNumber + " " + 
                customer.NAME) SKIP.
             
            {&out} SKIP
                htmlib-StartMntTable() SKIP
                htmlib-TableHeading(
                "Issue Number^right|Description^left|Issue Date^right|Contract^left|Billable|Details|Raised By^left|Area|Status" 
                + "|Issue Class^left|SLA^left|Assign To|Action Type|Action Date^right" 
                + "|Action Assigned To|Action Note|Action Status|Customer View|Activity Type|Activity Date^right|Activity Start Date^right|Acivity Description"
                + "|Description|Activity By|Site Visit|Duration^right|Billable|Administration"
               
                ) SKIP.

            li-count = 0.

        END.

        li-count = li-count + 1.
        IF li-count MOD 2 = 0
            THEN lc-tr = '<tr style="background: #EBEBE6;">'.
        ELSE lc-tr = '<tr style="background: white;">'.          
            

        {&out}
            SKIP
            lc-tr
            SKIP
            htmlib-MntTableField(html-encode(STRING(tt-ilog.issuenumber)),'right')

            htmlib-MntTableField(html-encode(STRING(tt-ilog.briefDescription)),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.CreateDate,"99/99/9999")),'right')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.ContractType)),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.iBillable)),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.iLongDesc)),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.RaisedLoginID)),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.cArea)),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.cStatus)),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.iType)),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.SLADesc)),'left')         
            htmlib-MntTableField(html-encode(STRING(tt-ilog.cAssignTo)),'left')    
            htmlib-MntTableField(html-encode(STRING(tt-ilog.cActionType)),'left')   
            htmlib-MntTableField(html-encode(STRING(tt-ilog.actionDate,"99/99/9999")),'right')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.cActionAssignTo)),'left')    
            htmlib-MntTableField(html-encode(STRING(tt-ilog.ActionNote)),'left') 
            htmlib-MntTableField(html-encode(STRING(tt-ilog.Actionstatus)),'left')       
            htmlib-MntTableField(html-encode(STRING(tt-ilog.ActionCustomerView)),'left')    
            htmlib-MntTableField(html-encode(STRING(tt-ilog.ActivityType)),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.actDate,"99/99/9999")),'right')      
            htmlib-MntTableField(html-encode(STRING(tt-ilog.startDate,"99/99/9999")),'right')     
            htmlib-MntTableField(html-encode(STRING(tt-ilog.ActTypeDesc)),'left') 
            htmlib-MntTableField(html-encode(STRING(tt-ilog.ActDesc)),'left')    
            htmlib-MntTableField(html-encode(STRING(tt-ilog.ActivityBy)),'left')  
            htmlib-MntTableField(html-encode(STRING(tt-ilog.SiteVisit)),'left')  
            htmlib-MntTableField(html-encode(STRING(tt-ilog.duration)),'right')  
            htmlib-MntTableField(html-encode(STRING(tt-ilog.ActBillable)),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.isAdmin)),'left')    
            .

        {&out} 
            '</tr>' SKIP.

        IF LAST-OF(tt-ilog.AccountNumber) THEN
        DO:
            {&out} SKIP 
                htmlib-EndTable()
                SKIP.

            {&out} htmlib-EndCriteria().


        END.


    END.
    
   

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-ProcessReport) = 0 &THEN

PROCEDURE ip-ProcessReport :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/



    RUN rep/issueexportbuild.p (
        lc-global-company,
        lc-global-user,
        lc-lo-Account,
        lc-hi-Account,
        get-value("allcust") = "on",
        DATE(lc-lodate),
        DATE(lc-hidate),
        SUBSTR(TRIM(lc-classlist),2),
        lc-st-num,
        lc-dtype,
        OUTPUT TABLE tt-ilog

        ).

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Selection) = 0 &THEN

PROCEDURE ip-Selection :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE iloop AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cPart AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cCode AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cDesc AS CHARACTER NO-UNDO.
    
    FIND this-user
        WHERE this-user.LoginID = lc-global-user NO-LOCK NO-ERROR.

    IF NOT ll-customer THEN
    DO:
        {&out}
            '<td align=right valign=top>' 
            (IF LOOKUP("loaccount",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("From Customer")
            ELSE htmlib-SideLabel("From Customer"))
            
            '</td>'
            '<td align=left valign=top>' .
        {&out-long}   
            htmlib-SelectLong("loaccount",lc-list-acc,lc-list-aname,lc-lo-account).
        {&out} 
            '</td>'.
    END.
    
    
    {&out} 
        '<td valign="top" align="right">' 
        (IF LOOKUP("lodate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("From Date")
        ELSE htmlib-SideLabel("From Date"))
        '</td>'
        '<td valign="top" align="left">'
        htmlib-CalendarInputField("lodate",10,lc-lodate) 
        htmlib-CalendarLink("lodate")
        '</td>' SKIP.

    IF NOT ll-customer THEN 
    DO:
        {&out}
            '</tr><tr>' SKIP
            '<td align=right valign=top>' 
            (IF LOOKUP("loaccount",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("To Customer")
            ELSE htmlib-SideLabel("To Customer"))
        
            '</td>'
            '<td align=left valign=top>'.
        {&out-long}
            htmlib-SelectLong("hiaccount",lc-list-acc,lc-list-aname,lc-hi-account).
                
        {&out} 
            '</td>'.
    END.
    
    {&out} 
        '<td valign="top" align="right">' 
        (IF LOOKUP("hidate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("To Date")
        ELSE htmlib-SideLabel("To Date"))
        '</td>'
        '<td valign="top" align="left">'
        htmlib-CalendarInputField("hidate",10,lc-hidate) 
        htmlib-CalendarLink("hidate")
        '</td>' SKIP.

    {&out} 
        '</tr>' SKIP.

    IF NOT ll-customer THEN
    DO:
        {&out} 
            '<tr><td valign="top" align="right">' 
            htmlib-SideLabel("All Customers")
            '</td>'
            '<td valign="top" align="left">'
            REPLACE(htmlib-checkBox("allcust",get-value("allcust") = "on"),
            ">",' onChange="ChangeAccount()">')
            '</td></tr>' SKIP.
        

    END.
       
    
    DO li-loop = 1 TO NUM-ENTRIES(lc-global-iclass-code,"|"):
        lc-codeName = "chk" + ENTRY(li-loop,lc-global-iclass-code,"|").
        
        cCode = ENTRY(li-loop,lc-global-iclass-code,"|").
        cDesc = com-DecodeLookup(cCode,lc-global-iclass-code,lc-global-iclass-desc).
        

        {&out} 
            '<tr><td valign="top" align="right">' 
            htmlib-SideLabel("Include Class " +  cDesc)
            '</td>'
            '<td valign="top" align="left">'
            htmlib-checkBox(lc-CodeName,get-value(lc-CodeName) = "on")
            '</td></tr>' SKIP.
    
    END.
   
        
    {&out}
        '<tr><td valign="top" align="right">' 
        htmlib-SideLabel("Support Team")
        '</td>'
        '<td align=left valign=top>' 
        htmlib-Select("st-num",lc-list-stcode,lc-list-stname,lc-st-num) '</td></tr>'.
    
    {&out}
        '<tr><td valign="top" align="right">' 
        htmlib-SideLabel("Date Selection By")
        '</td>'
        '<td align=left valign=top>' 
        htmlib-Select("dtype",lc-list-dtcode,lc-list-dtdesc,lc-dtype) '</td></tr>'.
        
    
    {&out}
        '<tr><td valign="top" align="right">' 
        htmlib-SideLabel("Report Output")
        '</td>'
        '<td align=left valign=top>' 
        htmlib-Select("output","WEB|CSV","Web Page|Email CSV",get-value("output")) '</td></tr>'.
    
  
    {&out} 
        '</table>' SKIP.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      emails:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.


    DEFINE VARIABLE ld-lodate AS DATE      NO-UNDO.
    DEFINE VARIABLE ld-hidate AS DATE      NO-UNDO.
    DEFINE VARIABLE li-loop   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-rowid  AS CHARACTER NO-UNDO.

    ASSIGN
        ld-lodate = DATE(lc-lodate) no-error.
    IF ERROR-STATUS:ERROR 
        OR ld-lodate = ?
        THEN RUN htmlib-AddErrorMessage(
            'lodate', 
            'The from date is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    ASSIGN
        ld-hidate = DATE(lc-hidate) no-error.
    IF ERROR-STATUS:ERROR 
        OR ld-hidate = ?
        THEN RUN htmlib-AddErrorMessage(
            'hidate', 
            'The to date is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF ld-lodate > ld-hidate 
        THEN RUN htmlib-AddErrorMessage(
            'lodate', 
            'The date range is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF lc-lo-account > lc-hi-account 
        THEN RUN htmlib-AddErrorMessage(
            'loaccount', 
            'The customer range is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).


    DO li-loop = 1 TO NUM-ENTRIES(lc-global-iclass-code,"|"):
        lc-codeName = "chk" + ENTRY(li-loop,lc-global-iclass-code,"|").
    
    
        IF get-value(lc-CodeName) = "on" THEN
        DO:
            lc-classlist = lc-ClassList + "," + 
                ENTRY(li-loop,lc-global-iclass-code,"|").
        END.
      
        
    END.
    IF TRIM(lc-classlist ) = "" 
        THEN RUN htmlib-AddErrorMessage(
            'Lalal', 
            'You must select one or more classes',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).





END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

PROCEDURE outputHeader :
    /*------------------------------------------------------------------------------
      Purpose:     Output the MIME header, and any "cookie" information needed 
                   by this procedure.  
      Parameters:  <none>
      Notes:       In the event that this Web object is state-aware, this is
                   a good place to set the webState and webTimeout attributes.
    ------------------------------------------------------------------------------*/

    /* To make this a state-aware Web object, pass in the timeout period 
     * (in minutes) before running outputContentType.  If you supply a timeout 
     * period greater than 0, the Web object becomes state-aware and the 
     * following happens:
     *
     *   - 4GL variables webState and webTimeout are set
     *   - a cookie is created for the broker to id the client on the return trip
     *   - a cookie is created to id the correct procedure on the return trip
     *
     * If you supply a timeout period less than 1, the following happens:
     *
     *   - 4GL variables webState and webTimeout are set to an empty string
     *   - a cookie is killed for the broker to id the client on the return trip
     *   - a cookie is killed to id the correct procedure on the return trip
     *
     * Example: Timeout period of 5 minutes for this Web object.
     *
     *   setWebState (5.0).
     */
    
    /* 
     * Output additional cookie information here before running outputContentType.
     *      For more information about the Netscape Cookie Specification, see
     *      http://home.netscape.com/newsref/std/cookie_spec.html  
     *   
     *      Name         - name of the cookie
     *      Value        - value of the cookie
     *      Expires date - Date to expire (optional). See TODAY function.
     *      Expires time - Time to expire (optional). See TIME function.
     *      Path         - Override default URL path (optional)
     *      Domain       - Override default domain (optional)
     *      Secure       - "secure" or unknown (optional)
     * 
     *      The following example sets cust-num=23 and expires tomorrow at (about) the 
     *      same time but only for secure (https) connections.
     *      
     *      RUN SetCookie IN web-utilities-hdl 
     *        ("custNum":U, "23":U, TODAY + 1, TIME, ?, ?, "secure":U).
     */ 
    output-content-type ("text/html":U).
  
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-process-web-request) = 0 &THEN

PROCEDURE process-web-request :
    /*------------------------------------------------------------------------------
      Purpose:     Process the web request.
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-filename AS CHARACTER NO-UNDO.
    
  
    {lib/checkloggedin.i}

    
    FIND this-user
        WHERE this-user.LoginID = lc-global-user NO-LOCK NO-ERROR.
    
    ASSIGN
        ll-customer = this-user.UserClass = "CUSTOMER".

    RUN ip-InitialProcess.

    IF request_method = "POST" AND lc-submit = "" THEN
    DO:
                
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).

        IF lc-error-msg = "" THEN
        DO:
            RUN ip-ProcessReport.
            
            IF lc-output = "CSV" THEN RUN ip-ExportReport (OUTPUT lc-filename).
        
            IF lc-output <> "WEB" THEN 
            DO:
                mlib-SendAttEmail 
                    ( lc-global-company,
                    "",
                    "HelpDesk Issue Export Report ",
                    "Please find attached your report covering the period "
                    + string(DATE(lc-lodate),"99/99/9999") + " to " +
                    string(DATE(lc-hidate),'99/99/9999'),
                    this-user.email,
                    "",
                    "",
                    lc-filename).
                OS-DELETE value(lc-filename).
            END.
         
        END.
    END.
       
    RUN outputHeader.

    {&out} DYNAMIC-FUNCTION('htmlib-CalendarInclude':U) SKIP.
    {&out} htmlib-Header("Issue Export") SKIP.
    RUN ip-ExportJScript.
    {&out} htmlib-JScript-Maintenance() SKIP.
    {&out} htmlib-StartForm("mainform","post", selfurl ) SKIP.
    {&out} htmlib-ProgramTitle("Issue Export") 
        htmlib-hidden("submitsource","") SKIP.
    {&out} htmlib-BeginCriteria("Report Criteria").
   
    
    {&out} 
        '<table align=center><tr>' SKIP.

    RUN ip-Selection.

    {&out} htmlib-EndCriteria().

    

    IF lc-error-msg <> "" THEN
    DO:
        {&out} 
            '<BR><BR><CENTER>' 
            htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' SKIP.
    END.

    {&out} 
        '<center>' htmlib-SubmitButton("submitform","Report") 
        '</center>' SKIP.

    
    
    
    IF request_method = "POST" 
        AND lc-error-msg = "" THEN
    DO:
       
        IF lc-output = "WEB" THEN RUN ip-PrintReport.   
        ELSE
            {&out} '<div class="infobox" style="font-size: 10px;">Your report has been emailed to '
                this-user.email
                '</div>'.
            
        
    END.



    
    {&out} htmlib-EndForm() SKIP.
    {&out} htmlib-CalendarScript("lodate") SKIP
        htmlib-CalendarScript("hidate") SKIP.
   

    {&OUT} htmlib-Footer() SKIP.


END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-Format-Select-Account) = 0 &THEN

FUNCTION CSVHeader RETURNS CHARACTER 
    ( pc-data AS CHARACTER  ):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/	

    DEFINE VARIABLE lc-Return AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-loop   AS INT       NO-UNDO.
    DEFINE VARIABLE lc-bit    AS CHARACTER NO-UNDO.
		
    DO li-loop = 1 TO NUM-ENTRIES(pc-data,"|"):
        lc-bit = '"' + entry(li-loop,pc-data,"|") + '"'.
        IF li-loop < num-entries(pc-data,"|")
            THEN lc-bit = lc-bit + ",".
        lc-return = TRIM(lc-return + lc-bit).
    END.
	

    RETURN lc-return.


		
END FUNCTION.

FUNCTION fnTimeString RETURNS CHARACTER 
    ( pi-Seconds AS INTEGER  ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    DEFINE VARIABLE result  AS CHARACTER NO-UNDO.

    DEFINE VARIABLE li-min  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-hr   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-work AS INTEGER   NO-UNDO.
    
    IF pi-seconds > 0 THEN
    DO:
        pi-seconds = ROUND(pi-seconds / 60,0).

        li-min = pi-seconds MOD 60.

        IF pi-seconds - li-min >= 60 THEN
            ASSIGN
                li-hr = ROUND( (pi-seconds - li-min) / 60 , 0 ).
        ELSE li-hr = 0.

        ASSIGN
            result = STRING(li-hr) + ":" + STRING(li-min,'99')
            .

    END.
        
    RETURN result.


		
END FUNCTION.

FUNCTION Format-Select-Account RETURNS CHARACTER
    ( pc-htm AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

    lc-htm = REPLACE(pc-htm,'<select',
        '<select onChange="ChangeAccount()"')
        . 


    RETURN lc-htm.


END FUNCTION.


&ENDIF

