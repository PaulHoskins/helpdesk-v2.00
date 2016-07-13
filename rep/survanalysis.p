/***********************************************************************

    Program:        rep/survanalysis.p
    
    Purpose:        Survey Analysis Report
    
    Notes:
    
    
    When        Who         What
    
    29/06/2016  phoski      Initial

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
  
DEFINE VARIABLE ll-Customer   AS LOG       NO-UNDO.

DEFINE VARIABLE lc-list-acc   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-aname AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-filename   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-CodeName   AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop       AS INTEGER   NO-UNDO.

DEFINE VARIABLE lc-output     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sv-code    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sv-desc    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-iss-survey AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-eng-code   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-eng-desc   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sort       AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-loeng      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-hieng      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-question   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-showall    AS CHARACTER NO-UNDO.


DEFINE TEMP-TABLE   tt-res NO-UNDO
    FIELD ivalue    AS INTEGER
    FIELD dperc     AS DEC
    FIELD icount    AS INTEGER
    INDEX ivalue    ivalue.


{rep/survanalysistt.i}


/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-Format-Select-Account) = 0 &THEN

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
{lib/maillib.i}
{lib/replib.i}


 




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

    {&out} skip
            '<script language="JavaScript" src="/scripts/js/hidedisplay.js"></script>' SKIP
            '<script language="JavaScript" src="/asset/chart/Chart.js"></script>'.

    {&out} skip 
          '<script language="JavaScript">' skip.

    {&out} skip
        'function ChangeAccount() ~{' skip
        '   SubmitThePage("AccountChange")' skip
        '~}' skip

        'function ChangeStatus() ~{' skip
        '   SubmitThePage("StatusChange")' skip
        '~}' skip

            'function ChangeDates() ~{' skip
       /* '   SubmitThePage("DatesChange")' skip */
        '~}' skip.

    {&out} skip
           '</script>' skip.
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
    

    DEFINE BUFFER customer     FOR customer.
    DEFINE BUFFER issue        FOR issue.
    

    DEFINE VARIABLE lc-GenKey     AS CHARACTER NO-UNDO.

   
    ASSIGN
        lc-genkey = STRING(NEXT-VALUE(ReportNumber)).
    
        
    pc-filename = SESSION:TEMP-DIR + "/survanalysis-" + lc-GenKey
        + ".csv".

    OUTPUT TO VALUE(pc-filename).

    PUT UNFORMATTED
              
        '"Customer","Engineer","Sent To","Issue","Description","Issue Date","Sent","Completed","Response"' SKIP.


    FOR EACH tt-san NO-LOCK:
        EXPORT DELIMITER ','
             tt-san.cname
             tt-san.eName   
             tt-san.cuName
             tt-san.issueNumber
             tt-san.iDesc
             tt-san.issDate
             DATE(tt-san.rq_created)
             DATE(tt-san.rq_completed)
             tt-san.iValue.
              
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
        lc-sv-code = htmlib-null()
        lc-sv-desc = "Select Survey" .
        
    FOR EACH acs_head NO-LOCK
        WHERE acs_head.CompanyCode = lc-global-company:
        ASSIGN
            lc-sv-code = lc-sv-code + "|" + acs_head.acs_code
            lc-sv-desc = lc-sv-desc + "|" + acs_head.descr.
                          
    END.   
        
    RUN com-GetEngineerList ( lc-global-company , "", OUTPUT lc-eng-code , OUTPUT lc-eng-desc ).
    
    ASSIGN
        lc-lo-account = get-value("loaccount")
        lc-hi-account = get-value("hiaccount")    
        lc-lodate     = get-value("lodate")         
        lc-hidate     = get-value("hidate")
        lc-output     = get-value("output")
        lc-submit     = get-value("submitsource")
        lc-temp       = get-value("allcust")
        lc-iss-survey = get-value("iss-survey")
        lc-loeng    = get-value("loeng")
        lc-hieng    = get-value("hieng")   
        lc-sort     = get-value("sort") 
        lc-question = get-value("question")
        lc-showall = get-value("showall").
    
    
    IF lc-temp = "on"
        THEN RUN com-GetCustomerAccount ( lc-global-company , lc-global-user, OUTPUT lc-list-acc, OUTPUT lc-list-aname ).
    ELSE RUN com-GetCustomerAccountActiveOnly ( lc-global-company , lc-global-user, OUTPUT lc-list-acc, OUTPUT lc-list-aname ).



    IF request_method = "GET" THEN
    DO:
        
        IF lc-lodate = ""
            THEN ASSIGN lc-lodate = STRING(TODAY - 365, "99/99/9999").
        
        IF lc-hidate = ""
            THEN ASSIGN lc-hidate = STRING(TODAY, "99/99/9999").
        
        
        IF lc-lo-account = ""
            THEN ASSIGN lc-lo-account = ENTRY(1,lc-list-acc,"|").
    
        IF lc-hi-account = ""
            THEN ASSIGN lc-hi-account = ENTRY(NUM-ENTRIES(lc-list-acc,"|"),lc-list-acc,"|").

        
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

    DEFINE VARIABLE li-count        AS INTEGER          NO-UNDO.
    DEFINE VARIABLE li-count2       AS INTEGER          NO-UNDO.
    DEFINE VARIABLE lc-tr           AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE li-eng          AS INTEGER          NO-UNDO.
    
   

    {&out} 
    htmlib-StartMntTable() SKIP
        htmlib-TableHeading('Customer^left|Engineer^left|Sent To^left|Issue^right|Description|Issue Date|Survey Sent|Survey Completed|Response^right') SKIP.
      
    FOR EACH tt-san NO-LOCK BY tt-san.rseq:
        
        ASSIGN
            li-count = li-count + 1
            li-count2 = li-count2 + 1.
        IF li-count2 MOD 2 = 0
            THEN lc-tr = '<tr style="background: #EBEBE6;">'.
        ELSE lc-tr = '<tr style="background: white;">'. 
        
        {&out}
            skip
            lc-tr
            htmlib-MntTableField(html-encode(tt-san.cName),'left')
            htmlib-MntTableField(html-encode(tt-san.eName),'left')
            htmlib-MntTableField(html-encode(tt-san.cuname),'left')
            htmlib-MntTableField(html-encode(string(tt-san.issuenumber)),'right')
            htmlib-MntTableField(html-encode(tt-san.iDesc),'left')
            htmlib-MntTableField(html-encode(string(tt-san.issDate,'99/99/9999')),'left')
            htmlib-MntTableField(html-encode(string(tt-san.rq_created,'99/99/9999')),'left')
            htmlib-MntTableField(html-encode(string(tt-san.rq_completed,'99/99/9999')),'left')
            htmlib-MntTableField(html-encode(string(tt-san.ivalue)),'right')
         
            
            
            '</tr>' SKIP.
            
        FIND tt-res
            WHERE tt-res.ivalue = tt-san.ivalue NO-ERROR.
        IF NOT AVAILABLE tt-res THEN CREATE tt-res.
        ASSIGN
            tt-res.icount = tt-res.icount + 1
            tt-res.ivalue = tt-san.iValue.
            
            
        IF lc-ShowAll = "ON" THEN
        DO:
            FOR EACH acs_res NO-LOCK
                WHERE acs_res.rq_id = tt-san.rq_id :
                    
            FIND acs_line WHERE acs_line.acs_line_id = acs_res.acs_line_id NO-LOCK NO-ERROR.
             
                   
            ASSIGN li-count2 = li-count2 + 1. 
            IF li-count2 MOD 2 = 0
            THEN lc-tr = '<tr style="background: #EBEBE6;">'.
            ELSE lc-tr = '<tr style="background: white;">'. 
        
            {&out}
                skip
                lc-tr
                replace(htmlib-MntTableField(html-encode(acs_line.qText),'right'),'<td','<td colspan=8')
                htmlib-MntTableField(html-encode(string(acs_res.rvalue)),'right')
                                               
                '</tr>' SKIP.
                  
                
                    
            END.
        END.
            
            
    END.
     
    {&out} skip 
                htmlib-EndTable()
                skip.
                
    FOR EACH tt-res EXCLUSIVE-LOCK:
        
        ASSIGN tt-res.dperc = ROUND(
            tt-res.icount / ( li-count / 100)
        ,2).
    END.          
                
    {&out} '<br/><br/><div style="width:50%">'
    htmlib-StartMntTable() SKIP
        htmlib-TableHeading('Response^right|% Of Total^right|Survey Count^right') SKIP.
        
    ASSIGN li-count2 = 0.
    
    FOR EACH tt-res NO-LOCK:
         ASSIGN
             li-count2 = li-count2 + 1.
        IF li-count2 MOD 2 = 0
            THEN lc-tr = '<tr style="background: #EBEBE6;">'.
        ELSE lc-tr = '<tr style="background: white;">'. 
        
        {&out}
            skip
            lc-tr
   
            htmlib-MntTableField(string(tt-res.ivalue),'right')
            htmlib-MntTableField(string(tt-res.dperc,">>>>>>>>9.99-"),'right')
            htmlib-MntTableField(string(tt-res.icount),'right')
            
            '</tr>' SKIP.
             
               
    END.
          
    {&out} skip 
                htmlib-EndTable()
                '</div>' skip
                skip.
                
                
                 
            
     
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-BuildData) = 0 &THEN

PROCEDURE ip-BuildData :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    RUN rep/survanalysis-build.p
        (
        lc-global-company,
        lc-iss-survey,
        int(lc-question),
        lc-lo-account,
        lc-hi-account,
        get-value("allcust") = "on",
        DATE(lc-lodate),
        DATE(lc-hidate),
        lc-loeng,
        lc-hieng,
        lc-sort,
        OUTPUT TABLE tt-san
   
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
    DEFINE VARIABLE iloop       AS INTEGER      NO-UNDO.
    DEFINE VARIABLE cPart       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE cCode       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE cDesc       AS CHARACTER     NO-UNDO.
    
    FIND this-user
        WHERE this-user.LoginID = lc-global-user NO-LOCK NO-ERROR.

    {&out}
    '<td align=right valign=top>' 
        (IF LOOKUP("iss-survey",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Survey")
        ELSE htmlib-SideLabel("Survey"))
    '</td>'
    '<td align=left valign=top colspan=4>' 
    REPLACE(htmlib-Select("iss-survey",lc-sv-code ,lc-sv-desc,lc-iss-survey), 
        ">",' onChange="ChangeAccount()">')
        SKIP
            '</td></tr>' SKIP.
    FIND acs_head WHERE acs_head.CompanyCode = lc-global-company
        AND acs_head.acs_code = lc-iss-survey NO-LOCK NO-ERROR.
    ASSIGN
        cCode = "0"
        cDesc = "All Questions On Survey".
        
    IF AVAILABLE acs_head THEN
    DO:
        FOR EACH acs_line OF acs_head  WHERE acs_line.qType BEGINS "RANGE"  NO-LOCK:
            IF cCode = "" THEN
            DO:
                ASSIGN
                    cCode = STRING(acs_line.acs_line_id)
                    cDesc = acs_line.qText.
               
                
            END.
            ELSE ASSIGN
                    cCode = cCode + "|" + string(acs_line.acs_line_id)
                    cDesc = cDesc + "|" + acs_line.qText.
            
        END.
        
        
        {&out}
        '<td align=right valign=top>' 
            (IF LOOKUP("question",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Question")
            ELSE htmlib-SideLabel("Question"))
        '</td>'
        '<td align=left valign=top colspan=4>' 
        htmlib-Select("question",cCode ,CDesc,lc-question)
            SKIP
                '</td></tr>' SKIP.
    END.       
    {&out}        
    '<tr><td align=right valign=top>' 
        (IF LOOKUP("loeng",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("From Engineer")
        ELSE htmlib-SideLabel("From Engineer"))

    '</td>'
    '<td align=left valign=top colspan=4>' 
    htmlib-Select("loeng",lc-eng-Code,lc-eng-desc,lc-loeng)  '</td></tr>' skip.
    
    {&out}        
    '<tr><td align=right valign=top>' 
        (IF LOOKUP("hieng",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("To Engineer")
        ELSE htmlib-SideLabel("To Engineer"))

    '</td>'
    '<td align=left valign=top colspan=4>' 
    htmlib-Select("hieng",lc-eng-Code,lc-eng-desc,lc-hieng)  '</td></tr>' skip.
    
    {&out} 
    '<tr><td valign="top" align="right">' 
        (IF LOOKUP("lodate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Issues From Date")
        ELSE htmlib-SideLabel("Issues From Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("lodate",10,lc-lodate) 
    htmlib-CalendarLink("lodate")
    '</td></tr>' skip.
    
    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("hidate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Issues To Date")
        ELSE htmlib-SideLabel("Issues To Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("hidate",10,lc-hidate) 
    htmlib-CalendarLink("hidate")
    '</td>' skip.

    {&out} '</tr>' SKIP.
    
    
            
    {&out}
    '<tr><td align=right valign=top>' 
        (IF LOOKUP("loaccount",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("From Customer")
        ELSE htmlib-SideLabel("From Customer"))
            
    '</td>'
    '<td align=left valign=top>' .
    {&out-long}   
    htmlib-SelectLong("loaccount",lc-list-acc,lc-list-aname,lc-lo-account).
    {&out} '</td>'.
   
    
  
    {&out}
    '</tr><tr>' SKIP
           '<td align=right valign=top>' 
           (if lookup("loaccount",lc-error-field,'|') > 0 
            then htmlib-SideLabelError("To Customer")
            else htmlib-SideLabel("To Customer"))
        
            '</td>'
           '<td align=left valign=top>'.
    {&out-long}
    htmlib-SelectLong("hiaccount",lc-list-acc,lc-list-aname,lc-hi-account).
                
    {&out} '</td></tr>'.
     

    {&out} '<tr><td valign="top" align="right">' 
    htmlib-SideLabel("All Customers")
    '</td>'
    '<td valign="top" align="left">'
    REPLACE(htmlib-checkBox("allcust",get-value("allcust") = "on"),
        ">",' onChange="ChangeAccount()">')
    '</td></tr>' skip.
    
    
    {&out}
    '<tr><td valign="top" align="right">' 
    htmlib-SideLabel("Sort By")
    '</td>'
    '<td align=left valign=top>' 
    htmlib-Select("sort","TSHI|TSLO|ENG|CUST","Total Score (High to Low)|Total Score (Low To High)|Engineer|Customer",get-value("sort")) '</td></tr>'.
    
    {&out} '<tr><td valign="top" align="right">' 
    htmlib-SideLabel("Show Full Survey Results")
    '</td>'
    '<td valign="top" align="left">'
    htmlib-checkBox("showall",get-value("showall") = "on")
    '</td></tr>' skip.
    
    
    
    {&out}
    '<tr><td valign="top" align="right">' 
    htmlib-SideLabel("Report Output")
    '</td>'
    '<td align=left valign=top>' 
    htmlib-Select("output","WEB|CSV","Web Page|Email CSV",get-value("output")) '</td></tr>'.
    
  
    {&out} '</table>' skip.
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


    DEFINE VARIABLE ld-lodate   AS DATE     NO-UNDO.
    DEFINE VARIABLE ld-hidate   AS DATE     NO-UNDO.
    DEFINE VARIABLE li-loop     AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lc-rowid    AS CHARACTER     NO-UNDO.

    IF lc-iss-survey = ""
        OR lc-iss-survey = htmlib-null() THEN
        RUN htmlib-AddErrorMessage(
            'iss-survey', 
            'The survey must be selected',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    ELSE
        IF lc-question  = "" 
            THEN RUN htmlib-AddErrorMessage(
                'iss-survey', 
                'This survey does not contain any relevant questions',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
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
            RUN ip-BuildData.
            FIND FIRST tt-san NO-LOCK NO-ERROR.
            IF NOT AVAILABLE tt-san THEN
            DO:
                ASSIGN
                    lc-error-field = "iss-survey"
                    lc-error-msg   = "No completed survey data for selected ranges".
            END.
            ELSE
            DO:
                IF lc-output = "CSV" THEN RUN ip-ExportReport (OUTPUT lc-filename).

            
                IF lc-output <> "WEB" THEN 
                DO:
                    mlib-SendAttEmail 
                        ( lc-global-company,
                        "",
                        "HelpDesk Survey Analysis Report ",
                        "Please find  your report attached",
                        this-user.email,
                        "",
                        "",
                        lc-filename).
                    OS-DELETE value(lc-filename).
                END.
            END.
            
        END.
    END.
       
    RUN outputHeader.

    {&out} DYNAMIC-FUNCTION('htmlib-CalendarInclude':U) skip.
    {&out} htmlib-Header("Survey Analysis") skip.
    RUN ip-ExportJScript.
    {&out} htmlib-JScript-Maintenance() skip.
    {&out} htmlib-StartForm("mainform","post", appurl + '/rep/survanalysis.p' ) skip.
    {&out} htmlib-ProgramTitle("Survey Analysis") 
    htmlib-hidden("submitsource","") skip.
    {&out} htmlib-BeginCriteria("Report Criteria").
    
    {&out} '<table align=center><tr>' skip.

    RUN ip-Selection.

    {&out} htmlib-EndCriteria().

    

    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.

    {&out} '<center>' htmlib-SubmitButton("submitform","Report") 
    '</center>' skip.

    
    
    
    IF request_method = "POST" 
        AND lc-error-msg = "" AND lc-submit = "" THEN
    DO:
       
        IF lc-output = "WEB" THEN RUN ip-PrintReport.   
        ELSE
            {&out} '<div class="infobox" style="font-size: 10px;">Your report has been emailed to '
        this-user.email
        '</div>'.
            
        
    END.



    
    {&out} htmlib-EndForm() skip.
    {&out} htmlib-CalendarScript("lodate") skip
           htmlib-CalendarScript("hidate") skip.
   

    {&OUT} htmlib-Footer() skip.


END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-Format-Select-Account) = 0 &THEN

FUNCTION fnTimeString RETURNS CHARACTER 
    ( pi-Seconds AS INTEGER  ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    DEFINE VARIABLE result AS CHARACTER NO-UNDO.

    DEFINE VARIABLE li-min      AS INTEGER      NO-UNDO.
    DEFINE VARIABLE li-hr       AS INTEGER      NO-UNDO.
    DEFINE VARIABLE li-work     AS INTEGER      NO-UNDO.
    
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

