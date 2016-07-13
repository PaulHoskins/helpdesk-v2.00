/***********************************************************************

    Program:        rep/issuelog.p
    
    Purpose:        Issue Log Report
    
    Notes:
    
    
    When        Who         What
    
    01/05/2014  phoski      Initial
    09/11/2014  phoski    
    07/03/2015  phoski      Summary page with graphics     
    29/03/2015  phoski      Class Code/Desc
    23/02/2015  phoski      Acive/Inactive Customers & toggle 
    21/05/2016  phoski      use Longchars for customer selection
    
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

DEFINE VARIABLE lc-ClassList  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-output     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit     AS CHARACTER NO-UNDO.



DEFINE TEMP-TABLE ttc NO-UNDO
    FIELD id AS CHARACTER 
    INDEX MainKey IS UNIQUE
    id.
DEFINE TEMP-TABLE ttd NO-UNDO
    FIELD id     AS CHARACTER     
    FIELD lbl    AS CHARACTER
    FIELD val    AS DECIMAL
    FIELD setVal AS DECIMAL   EXTENT 2
    INDEX MainKey IS UNIQUE
    id lbl.
        
    
    .
{rep/issuelogtt.i}
{lib/maillib.i}
{lib/princexml.i}



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
    
        
    pc-filename = SESSION:TEMP-DIR + "/IssueLog-" + lc-GenKey
        + ".csv".

    OUTPUT TO VALUE(pc-filename).

    PUT UNFORMATTED
                
        '"Customer","Issue Number","Description","Issue Type","Raised By","System","SLA Level","' +
        'Date Raised","Time Raised","Date Completed","Time Completed","Activity Duration","SLA Achieved","SLA Comment","' +
        '"Closed By' SKIP.


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
            tt-ilog.iType
            tt-ilog.RaisedLoginID
            tt-ilog.AreaCode
            tt-ilog.SLALevel
            tt-ilog.CreateDate
            STRING(tt-ilog.CreateTime,"hh:mm")
      
            IF tt-ilog.CompDate = ? THEN "" ELSE STRING(tt-ilog.CompDate,"99/99/9999")

            IF tt-ilog.CompTime = 0 THEN "" ELSE STRING(tt-ilog.CompTime,"hh:mm")
       
            tt-ilog.ActDuration
            tt-ilog.SLAAchieved
            tt-ilog.SLAComment
            tt-ilog.ClosedBy

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
        lc-temp       = get-value("allcust").
    
    
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

        DO li-loop = 1 TO NUM-ENTRIES(lc-global-iclass-code,"|"):
            lc-codeName = "chk" + ENTRY(li-loop,lc-global-iclass-code,"|").
            set-user-field(lc-codeName,"on").
        END.
    END.

    
    

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-PrintReport) = 0 &THEN

PROCEDURE ip-PDF:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-pdf AS CHARACTER NO-UNDO.
    
    DEFINE BUFFER customer     FOR customer.
    DEFINE BUFFER issue        FOR issue.
    
    DEFINE VARIABLE lc-html         AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lc-pdf          AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE ll-ok           AS LOG      NO-UNDO.
    DEFINE VARIABLE li-ReportNumber AS INTEGER      NO-UNDO.

    ASSIGN    
        li-ReportNumber = NEXT-VALUE(ReportNumber).
    ASSIGN 
        lc-html = SESSION:TEMP-DIR + caps(lc-global-company) + "-issueLog-" + string(li-ReportNumber).

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
    DYNAMIC-FUNCTION("pxml-Header", lc-global-company).
   
        
    {&prince}
    '<p style="text-align: center; font-size: 14px; font-weight: 900;">Issue Log - '
    'From ' STRING(DATE(lc-lodate),"99/99/9999")
    ' To ' STRING(DATE(lc-hidate),"99/99/9999") 
      
    '</div>'.


   

    
    FOR EACH tt-ilog NO-LOCK
        BREAK BY tt-ilog.AccountNumber
        BY tt-ilog.IssueNumber
        :

        IF FIRST-OF(tt-ilog.AccountNumber) THEN
        DO:
            FIND customer WHERE customer.CompanyCode = lc-global-company
                AND customer.AccountNumber = tt-ilog.AccountNumber
                NO-LOCK NO-ERROR.
            {&prince} htmlib-BeginCriteria("Customer - " + tt-ilog.AccountNumber + " " + 
                customer.NAME) SKIP.
                
            {&prince}
            '<table class="landrep">'
            '<thead>'
            '<tr>'
            htmlib-TableHeading(
                "Issue Number^right|Description^left|Issue Class^left|Raised By^left|System^left|SLA Level^left|" +
                "Date Raised^right|Time Raised^left|Date Completed^right|Time Completed^left|Activity Duration^right|SLA Achieved^left|SLA Comment^left|" +
                "Closed By^left")
                
            '</tr>'
            '</thead>'
        skip.


        END.


        {&prince}
            skip
            '<tr>'
            skip
            htmlib-MntTableField(html-encode(string(tt-ilog.issuenumber)),'right')

            htmlib-MntTableField(html-encode(string(tt-ilog.briefDescription)),'left')
            htmlib-MntTableField(html-encode(string(tt-ilog.iType)),'left')

            htmlib-MntTableField(html-encode(string(tt-ilog.RaisedLoginID)),'left')

            htmlib-MntTableField(html-encode(string(tt-ilog.AreaCode)),'left')
            htmlib-MntTableField(html-encode(string(tt-ilog.SLALevel)),'right')
            htmlib-MntTableField(html-encode(string(tt-ilog.CreateDate,"99/99/9999")),'right')
            htmlib-MntTableField(html-encode(string(tt-ilog.CreateTime,"hh:mm")),'right').
        
        IF tt-ilog.CompDate <> ? THEN
            {&prince}
        htmlib-MntTableField(html-encode(STRING(tt-ilog.CompDate,"99/99/9999")),'right')
        htmlib-MntTableField(html-encode(STRING(tt-ilog.CompTime,"hh:mm")),'right').
        ELSE
        {&prince}
            htmlib-MntTableField(html-encode(""),'right')
            htmlib-MntTableField(html-encode(""),'right').    

        {&prince}
        htmlib-MntTableField(html-encode(STRING(tt-ilog.ActDuration)),'right')
        htmlib-MntTableField(html-encode(STRING(tt-ilog.SLAAchieved)),'left')
        htmlib-MntTableField(REPLACE(tt-ilog.SLAComment,'~n','<br/>'),'left')

        htmlib-MntTableField(html-encode(STRING(tt-ilog.ClosedBy)),'left')



            SKIP .

        {&prince} '</tr>' SKIP.






        IF LAST-OF(tt-ilog.AccountNumber) THEN
        DO:
            {&prince} skip 
                htmlib-EndTable()
                skip.

            {&prince} htmlib-EndCriteria().


        END.


    END.
       

    DYNAMIC-FUNCTION("pxml-Footer",lc-global-company).
    DYNAMIC-FUNCTION("pxml-CloseStream").


    ll-ok = DYNAMIC-FUNCTION("pxml-Convert",lc-html,lc-pdf).

    OS-DELETE value(lc-html) no-error.
    
    IF ll-ok
        THEN ASSIGN pc-pdf = lc-pdf.
    

END PROCEDURE.

PROCEDURE ip-PrintReport :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER customer     FOR customer.
    DEFINE BUFFER issue        FOR issue.
    DEFINE VARIABLE li-count        AS INTEGER          NO-UNDO.
    DEFINE VARIABLE lc-tr           AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE li-eng          AS INTEGER          NO-UNDO.
    
    DEFINE BUFFER tt-ilog   FOR tt-ilog.
    
    
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
            IF get-value("summary") = "on" THEN
            DO:
                RUN ip-SummaryPage (tt-ilog.AccountNumber).
                    
            END.  
            {&out} skip
                htmlib-StartMntTable() skip
                htmlib-TableHeading(
                "Issue Number^right|Description^left|Issue Class^left|Raised By^left|System^left|SLA Level^left|" +
                "Date Raised^right|Time Raised^left|Date Completed^right|Time Completed^left|Activity Duration^right|SLA Achieved^left|SLA Comment^left|" +
                "Closed By^left"
            ) skip.

            li-count = 0.

        END.

        li-count = li-count + 1.
        IF li-count MOD 2 = 0
            THEN lc-tr = '<tr style="background: #EBEBE6;">'.
        ELSE lc-tr = '<tr style="background: white;">'.          
            

        {&out}
            skip
            lc-tr
            skip
            htmlib-MntTableField(html-encode(string(tt-ilog.issuenumber)),'right')

            htmlib-MntTableField(html-encode(string(tt-ilog.briefDescription)),'left')
            htmlib-MntTableField(html-encode(string(tt-ilog.iType)),'left')

            htmlib-MntTableField(html-encode(string(tt-ilog.RaisedLoginID)),'left')

            htmlib-MntTableField(html-encode(string(tt-ilog.AreaCode)),'left')
            htmlib-MntTableField(html-encode(string(tt-ilog.SLALevel)),'right')
            htmlib-MntTableField(html-encode(string(tt-ilog.CreateDate,"99/99/9999")),'right')
            htmlib-MntTableField(html-encode(string(tt-ilog.CreateTime,"hh:mm")),'right').
        
        IF tt-ilog.CompDate <> ? THEN
            {&out} 
        htmlib-MntTableField(html-encode(STRING(tt-ilog.CompDate,"99/99/9999")),'right')
        htmlib-MntTableField(html-encode(STRING(tt-ilog.CompTime,"hh:mm")),'right').
        ELSE
        {&out} 
            htmlib-MntTableField(html-encode(""),'right')
            htmlib-MntTableField(html-encode(""),'right').    

        {&out}
        htmlib-MntTableField(html-encode(STRING(tt-ilog.ActDuration)),'right')
        htmlib-MntTableField(html-encode(STRING(tt-ilog.SLAAchieved)),'left')
        htmlib-MntTableField(REPLACE(tt-ilog.SLAComment,'~n','<br/>'),'left')

        htmlib-MntTableField(html-encode(STRING(tt-ilog.ClosedBy)),'left')



            SKIP .

        {&out} '</tr>' SKIP.






        IF LAST-OF(tt-ilog.AccountNumber) THEN
        DO:
            {&out} skip 
                htmlib-EndTable()
                skip.

            {&out} htmlib-EndCriteria().


        END.


    END.
    
    FIND FIRST ttc NO-LOCK NO-ERROR.
    
       
    IF AVAILABLE ttc THEN
    DO:
        {&out} SKIP
            '<script>' SKIP
            
          'window.onload = function()~{' SKIP
        .
        FOR EACH ttc NO-LOCK:
                
            {&out}      
            'var ctx = document.getElementById("' ttc.id '").getContext("2d");' SKIP.
            
            IF  ttc.id BEGINS "B" THEN 
            DO:
              {&out}
            'window.myPie = new Chart(ctx).Bar(pd' ttc.id ', ~{' SKIP
            '  responsive : true ' SKIP
            '~});' SKIP.
               
            END.
            ELSE {&out}
            'window.myPie = new Chart(ctx).Pie(pd' ttc.id ');' SKIP.
            
        END.
         
        {&out}    
        '~};' SKIP
         '</script>' SKIP.
          
         
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



    RUN rep/issuelogbuild.p (
        lc-global-company,
        lc-global-user,
        lc-lo-Account,
        lc-hi-Account,
        get-value("allcust") = "on",
        DATE(lc-lodate),
        DATE(lc-hidate),
        SUBSTR(TRIM(lc-classlist),2),
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
    DEFINE VARIABLE iloop       AS INTEGER      NO-UNDO.
    DEFINE VARIABLE cPart       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE cCode       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE cDesc       AS CHARACTER     NO-UNDO.
    
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
         {&out} '</td>'.
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
    '</td>' skip.

    IF NOT ll-customer THEN 
    DO:
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
                
            {&out} '</td>'.
    END.
    
    {&out} '<td valign="top" align="right">' 
        (IF LOOKUP("hidate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("To Date")
        ELSE htmlib-SideLabel("To Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("hidate",10,lc-hidate) 
    htmlib-CalendarLink("hidate")
    '</td>' skip.

    {&out} '</tr>' SKIP.

    IF NOT ll-customer THEN
    DO:
        {&out} '<tr><td valign="top" align="right">' 
        htmlib-SideLabel("All Customers")
        '</td>'
        '<td valign="top" align="left">'
        REPLACE(htmlib-checkBox("allcust",get-value("allcust") = "on"),
        ">",' onChange="ChangeAccount()">')
        '</td></tr>' skip.
        

    END.
    
    DO li-loop = 1 TO NUM-ENTRIES(lc-global-iclass-code,"|"):
        lc-codeName = "chk" + ENTRY(li-loop,lc-global-iclass-code,"|").
        
        cCode = ENTRY(li-loop,lc-global-iclass-code,"|").
        cDesc = com-DecodeLookup(cCode,lc-global-iclass-code,lc-global-iclass-desc).
        

        {&out} '<tr><td valign="top" align="right">' 
        htmlib-SideLabel("Include Class " +  cDesc)
        '</td>'
        '<td valign="top" align="left">'
        htmlib-checkBox(lc-CodeName,get-value(lc-CodeName) = "on")
        '</td></tr>' skip.
    
    END.
    {&out} '<tr><td valign="top" align="right">' 
    htmlib-SideLabel("Summary Details On Web Output")
    '</td>'
    '<td valign="top" align="left">'
    htmlib-checkBox("summary",get-value("summary") = "on")
    '</td></tr>' skip.
        
        
    
    {&out}
    '<tr><td valign="top" align="right">' 
    htmlib-SideLabel("Report Output")
    '</td>'
    '<td align=left valign=top>' 
    htmlib-Select("output","WEB|CSV|PDF","Web Page|Email CSV|Email PDF",get-value("output")) '</td></tr>'.
    
  
    {&out} '</table>' skip.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-SummaryPage:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-account   AS CHARACTER NO-UNDO.
    

    DEFINE BUFFER customer     FOR customer.
    DEFINE BUFFER issue        FOR issue.
    DEFINE VARIABLE li-count        AS INTEGER              NO-UNDO.
    DEFINE VARIABLE li-sla          AS INTEGER EXTENT 2     NO-UNDO.
    DEFINE VARIABLE ld-sla          AS DECIMAL EXTENT 2     NO-UNDO.
    DEFINE VARIABLE li-loop         AS INTEGER              NO-UNDO.
    DEFINE VARIABLE li-time         AS INTEGER              NO-UNDO.
    DEFINE VARIABLE li-Tot-Time     AS INTEGER              NO-UNDO.
    DEFINE VARIABLE li-temp         AS INTEGER              NO-UNDO.
    DEFINE VARIABLE ld-temp         AS DECIMAL              NO-UNDO.
    DEFINE VARIABLE lc-id           AS CHARACTER EXTENT 3   NO-UNDO.
    
        
    DEFINE VARIABLE lc-tr           AS CHARACTER            NO-UNDO.
    DEFINE VARIABLE li-eng          AS INTEGER              NO-UNDO.
    DEFINE VARIABLE lc-Co           AS CHARACTER            NO-UNDO.
    DEFINE VARIABLE lc-hi           AS CHARACTER            NO-UNDO.
    DEFINE VARIABLE li-tCol         AS INT                  NO-UNDO.
    DEFINE VARIABLE lc-lb           AS CHARACTER            NO-UNDO.
    DEFINE VARIABLE li-set          AS INTEGER              NO-UNDO.
      
    
    
    
    ASSIGN
        lc-co = "#F7464A,#46BFBD,#FDB45C,#949FB1,#4D5360,#FF5A5E,#5AD3D1,#FFC870,#A8B3C5,#616774" 
        lc-hi  = lc-co.
    /*
    ASSIGN lc-co = "aqua,black,blue,gray,green,lime,maroon,navy,olive,orange,purple,red,silver,teal,yellow"
           lc-hi = lc-co.  
    */ 
    DEFINE BUFFER tt-ilog   FOR tt-ilog.
    
    FIND customer WHERE customer.CompanyCode = lc-global-company
        AND customer.AccountNumber = pc-Account
        NO-LOCK NO-ERROR.
                
     
    FOR EACH tt-ilog NO-LOCK
        WHERE tt-ilog.AccountNumber = pc-account
        :
       
        ASSIGN 
            li-count = li-count + 1
            li-Tot-Time  = li-Tot-Time + tt-ilog.iActDuration
            li-sla[1] = li-sla[1] + IF tt-ilog.SLAAchieved THEN 1 ELSE 0 
            li-sla[2] = li-sla[2] + IF tt-ilog.SLAAchieved THEN 0 ELSE 1
            .
              
    END.
    
    DO li-loop = 1 TO 2:
        IF li-sla[li-loop] <> 0 THEN
            ASSIGN ld-sla[li-loop] = ROUND( li-sla[li-loop] / ( li-count / 100 ),2).
    END.
    
    {&out} SKIP
           '<div style="padding: 15px;">' skip
                replace(htmlib-StartMntTable(),"100%","35%") SKIP.
                
    {&out} SKIP
        '<tr>'
        '<td valign="top" align="right">'
       htmlib-SideLabel("Reporting Period")
       
       '</td><td valign="top" align="left" colspan=2>'
        (lc-lodate) ' - '
        (lc-hidate)
       '</td></tr>' SKIP.
    {&out} SKIP
        '<tr>'
        '<td valign="top" align="right">'
       htmlib-SideLabel("Technical Account Manager")
       
       '</td><td valign="top" align="left" colspan=2>'
        dynamic-function('com-UserName',Customer.AccountManager)
       '</td></tr>' SKIP.
       
    {&out} SKIP
        '<tr>'
        '<td valign="top" align="right">'
       htmlib-SideLabel("Total Activity Duration")
       
       '</td><td valign="top" align="left" colspan=2>'
         /*li-time ' - ' */
         fnTimeString(li-Tot-Time)
       '</td></tr>' SKIP.
             
    {&out} SKIP
        '<tr>'
        '<td valign="top" align="right">'
       htmlib-SideLabel("Number Of Issues")
       
       '</td><td valign="top" align="left" colspan=2>'
         li-count
       '</td></tr>' SKIP.
     
    {&out} SKIP
        '<tr>'
        '<td valign="top" align="right">'
       htmlib-SideLabel("SLA Achieved")
       '</td></tr>' SKIP.
       
    {&out} SKIP
        '<tr>'
        '<td valign="top" align="right">'
       "Yes"
       
       '</td><td valign="top" align="right">'
         li-sla[1] 
          '</td><td valign="top" align="right">'
           string(ld-sla[1],"zzzz9.99-") '%'
       '</td></tr>' SKIP.
    {&out} SKIP
        '<tr>'
        '<td valign="top" align="right">'
      "No"
       
       '</td><td valign="top" align="right">'
         li-sla[2]
          '</td><td valign="top" align="right">'
           string(ld-sla[2],"zzzz9.99-") '%'
       '</td></tr>' SKIP.
         
    {&out} SKIP
        '<tr>'
        '<td valign="top" align="right">'
       htmlib-SideLabel("Number Of Issues By SLA Level")
       '</td></tr>' SKIP.
    
    ASSIGN
        li-Temp = 0.
         
    FOR EACH tt-ilog NO-LOCK
        WHERE tt-ilog.AccountNumber = pc-account
        BREAK BY tt-ilog.SLALevel:
        
        ASSIGN
            li-temp = li-temp + 1.
            
        IF NOT LAST-OF(tt-ilog.SLALevel) THEN NEXT.
        
        ld-temp = ROUND( li-temp / ( li-count / 100 ),2).
        
        {&out} SKIP
            '<tr>'
            '<td valign="top" align="right">'
            tt-ilog.SLALevel
       
       '</td><td valign="top" align="right">'
         li-temp 
        '</td><td valign="top" align="right">'
          string(ld-temp,">>>>9.99-") '%'
       '</td></tr>' SKIP.
       
        
        ASSIGN 
            li-temp = 0.
          
    END.    
    
    {&out} SKIP
        '<tr>'
        '<td valign="top" align="right">'
       htmlib-SideLabel("Number Of Issues By Class")
       '</td></tr>' SKIP.
    
    ASSIGN
        li-Temp = 0.
         
    FOR EACH tt-ilog NO-LOCK
        WHERE tt-ilog.AccountNumber = pc-account
        BREAK BY tt-ilog.iType:
        
        ASSIGN
            li-temp = li-temp + 1.
            
        IF NOT LAST-OF(tt-ilog.iType) THEN NEXT.
        
        ld-temp = ROUND( li-temp / ( li-count / 100 ),2).
        
        {&out} SKIP
            '<tr>'
            '<td valign="top" align="right">'
            tt-ilog.iType
       
       '</td><td valign="top" align="right">'
         li-temp 
        '</td><td valign="top" align="right">'
          string(ld-temp,">>>>9.99-") '%'
       '</td></tr>' SKIP.
       
        
        ASSIGN 
            li-temp = 0.
          
    END.  
    {&out} SKIP
        '<tr>'
        '<td valign="top" align="right">'
       htmlib-SideLabel("Issues By System Area")
       '</td></tr>' SKIP.
    
    ASSIGN
        li-Temp = 0
        li-Time = 0
        lc-id[1] = "N" + string(ROWID(Customer)) /* Number of issues */
        lc-id[2] = "T" + string(ROWID(Customer)) /* Time */
        lc-id[3] = "B" + string(ROWID(Customer)) /* Bar Graph */
        
        
        .
         
    DO li-loop = 1 TO 3:
        CREATE ttc.
        ASSIGN 
            ttc.id = lc-id[li-loop].
        
    END.
    FOR EACH tt-ilog NO-LOCK
        WHERE tt-ilog.AccountNumber = pc-account
        BREAK BY tt-ilog.AreaCode:
        
        ASSIGN
            li-temp = li-temp + 1
            li-time = li-time + tt-ilog.iActDuration.
            
        IF NOT LAST-OF(tt-ilog.AreaCode) THEN NEXT.
        
        IF lc-lb = ""
        THEN lc-lb = tt-ilog.AreaCode.
        ELSE lc-lb = lc-lb + "," + tt-ilog.AreaCode.
        
        CREATE ttd.
        ASSIGN 
            ttd.id = lc-id[1]
            ttd.lbl = tt-ilog.AreaCode
            ttd.val = li-temp.
               
        CREATE ttd.
        ASSIGN 
            ttd.id = lc-id[2]
            ttd.lbl = tt-ilog.AreaCode
            ttd.val = ROUND(ROUND(li-time / 60,2) / 60,2).
               
        CREATE ttd.
        ASSIGN 
            ttd.id = lc-id[3]
            ttd.lbl = tt-ilog.AreaCode
            ttd.SetVal[1] = li-temp.
        ttd.SetVal[2] = ROUND(ROUND(li-time / 60,2) / 60,2).
                      
        {&out} SKIP
            '<tr>'
            '<td valign="top" align="right">'
            STRING(tt-ilog.AreaCode)
       
       '</td><td valign="top" align="right">'
         li-temp 
        '</td><td valign="top" align="right">'
          /*li-time ' - ' */
         fnTimeString(li-Time)
         
       '</td></tr>' SKIP.
       
        
        ASSIGN 
            li-temp = 0
            li-time = 0.
          
    END.      
               
    {&out} skip 
                htmlib-EndTable() SKIP.
                
    {&out} '<table width="100%" border="0">' SKIP
            '<TR>'
            '<td valign="top" align="CENTER">'
       replace(htmlib-SideLabel("Number of Issues By System Area"),":","")
       '</td>'
       '<td valign="top" align="CENTER">'
       replace(htmlib-SideLabel("Time By System Area In Hours"),":","")
       '</td></tr>'
       
            '<tr><td align="CENTER" style="border: 1px solid #E4ECF0;">' SKIP.            
    {&out} 
    '<div id="canvas-holder1" >' SKIP
        
        '<canvas id="' lc-id[1] '" width="300" height="300"/>' SKIP
        
        '</div>' SKIP.
        
    {&out} '</td><td align="CENTER" style="border: 1px solid #E4ECF0;">'.
     
    {&out} 
    '<div id="canvas-holder2">' skip
        '<canvas id="' lc-id[2] '" width="300" height="300"/>' SKIP
         '</div>' SKIP.
     
    {&out} '</td></tr><tr><td colspan="2" align="CENTER" style="border: 1px solid #E4ECF0;">'.
     
    {&out} 
    '<div id="canvas-holder3">' skip
        '<canvas id="' lc-id[3] '" width="500" height="300"/>' SKIP
         '</div>' SKIP.
         
    {&out} '</td></tr></table>'     SKIP.
      
    {&out} '<script>' SKIP.
    
    /*
    ***
    *** Array object for pie graphs 
    ***
    */
    DO li-loop = 1 TO 2:
        
        {&out} SKIP
               'var pd' lc-id[li-loop] ' = [' SKIP.
               
        li-tcol = 0.
        FOR EACH ttd NO-LOCK 
            WHERE ttd.id = lc-id[li-loop]
            AND ttd.val > 0
            BREAK BY  ttd.id:
                  
            li-tCol = li-tCol + 1.
            IF li-tCol > num-entries(lc-co)
                THEN li-tCol = 1.
              
            {&out} '~{' SKIP
                    ' value: ' ttd.val ',' SKIP
                    ' color: ~"' entry(li-tCol,lc-co) '",' SKIP
                    ' highlight: ~"' entry(li-tCol,lc-hi) '",' SKIP
                    ' label: ~"' ttd.lbl '"' SKIP
                    '~}'.
                    
            IF NOT LAST-OF(ttd.id)
                THEN {&out} ',' SKIP.
               ELSE {&out} SKIP.     
                    
            .
              
                  
                 
        END.       
        {&out} '];' SKIP.
                
          
            
                   
    END.  
    /* Array Object for Bar */
    
    {&out} SKIP(2)
               'var pd' lc-id[3] ' = ~{' SKIP
               ' labels : [ ' .
    DO li-loop = 1 TO NUM-ENTRIES(lc-lb):
        IF li-loop > 1
        THEN {&out} ','.
        
        {&out} '"' ENTRY(li-loop,lc-lb) '"'.
    END.
    
    {&out} "]," SKIP /* end of 'labels' array */
           " datasets : [" SKIP.
              
    DO li-set = 1 TO 2:
        IF li-set = 1
        THEN {&out} 
                ' ~{' skip
                '   fillColor : "rgba(220,220,220,0.5)",' skip
                '   strokeColor : "rgba(220,220,220,0.8)",' skip
                '   highlightFill: "rgba(220,220,220,0.75)",' skip
                '   highlightStroke: "rgba(220,220,220,1)",' skip
                '   data :' SKIP
                '   ['. 
        ELSE {&out}
                ' ~{' skip
                '   fillColor : "rgba(151,187,205,0.5)",' skip
                '   strokeColor : "rgba(151,187,205,0.8)",' skip
                '   highlightFill : "rgba(151,187,205,0.75)",' skip
                '   highlightStroke : "rgba(151,187,205,1)",' skip            
                '   data :' SKIP
                '   ['.
        DO li-loop = 1 TO NUM-ENTRIES(lc-lb):
            FIND ttd WHERE ttd.id = lc-id[3]
              AND ttd.lbl = entry(li-loop,lc-lb) NO-LOCK.
             {&out} ttd.setVal[li-set].
             IF li-loop <  NUM-ENTRIES(lc-lb)
             THEN {&out} ','.
             else {&out} ']' SKIP.
        END. 
        IF li-set = 1
        THEN {&out} '~},' SKIP.
        ELSE {&out} '~}' SKIP.     
                           
    END.
               
    {&out} "]" SKIP. /* end of 'datasets' array */
    
    {&out} SKIP '~};' SKIP. /* End bar obj */
    
    {&out} SKIP
           '</script>'.
    
               
                
    {&out} '</div>'
                skip.
                
        
        
END PROCEDURE.

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
            ELSE
                IF lc-output = "PDF" THEN RUN ip-PDF (OUTPUT lc-filename).
            
            IF lc-output <> "WEB" THEN 
            DO:
                mlib-SendAttEmail 
                    ( lc-global-company,
                    "",
                    "HelpDesk Issue Log Report ",
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

    {&out} DYNAMIC-FUNCTION('htmlib-CalendarInclude':U) skip.
    {&out} htmlib-Header("Issue Log") skip.
    RUN ip-ExportJScript.
    {&out} htmlib-JScript-Maintenance() skip.
    {&out} htmlib-StartForm("mainform","post", appurl + '/rep/issuelog.p' ) skip.
    {&out} htmlib-ProgramTitle("Issue Log") 
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
        AND lc-error-msg = "" THEN
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

