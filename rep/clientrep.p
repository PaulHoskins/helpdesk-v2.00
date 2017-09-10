/***********************************************************************

    Program:        rep/clientrep.p
    
    Purpose:        Issue Log Report
    
    Notes:
    
    
    When        Who         What
   
 
    09/04/2017  phoski      Date Types
           
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE BUFFER this-user FOR WebUser.

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-char        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Account     AS CHARACTER NO-UNDO.
DEFINE VARIABLE ld-lodate      AS DATE      NO-UNDO.
DEFINE VARIABLE ld-hidate      AS DATE      NO-UNDO.
DEFINE VARIABLE ll-Customer    AS LOG       NO-UNDO.
DEFINE VARIABLE lc-list-acc    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-aname  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-filename    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-CodeName    AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop        AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-ClassList   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-dtype       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-month       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-year        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sel-month   AS CHARACTER INITIAL '01|02|03|04|05|06|07|08|09|10|11|12' NO-UNDO.
DEFINE VARIABLE lc-sel-year    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-reptype     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-dtcode AS CHARACTER INITIAL 'ISS|ACT|ISSACT' NO-UNDO.
DEFINE VARIABLE lc-list-dtdesc AS CHARACTER INITIAL 'Issue|Activity|Issue And Activity' NO-UNDO.
DEFINE VARIABLE lc-labels      AS CHARACTER EXTENT 3 NO-UNDO.
DEFINE VARIABLE lc-doc-key      AS CHARACTER NO-UNDO.


DEFINE TEMP-TABLE tt-cid NO-UNDO
    FIELD id AS CHARACTER 
    INDEX MainKey IS UNIQUE
    id.
DEFINE TEMP-TABLE tt-data NO-UNDO
    FIELD id     AS CHARACTER     
    FIELD lbl    AS CHARACTER
    FIELD val    AS DECIMAL
    FIELD setVal AS DECIMAL   EXTENT 2
    INDEX MainKey IS UNIQUE
    id lbl.
        
DEFINE TEMP-TABLE tt-month NO-UNDO
    FIELD AreaCode AS CHARACTER
    FIELD Val      AS DECIMAL EXTENT 3
    INDEX MainKey IS UNIQUE
    AreaCode.
      
          
            
    
   
{rep/clientreptt.i}
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

    {&out} SKIP
        '<script language="JavaScript" src="/scripts/js/hidedisplay.js"></script>' SKIP
        '<script language="JavaScript" src="/asset/chart/Chart.js"></script>'.

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
        
     {&out}  '<style>' SKIP
     '@media print~{' SKIP
     '#noprint~{' SKIP
     'display:none;' SKIP
     '~}' SKIP
     '~}' SKIP
     '</style>' SKIP.
     
  
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
    DEFINE VARIABLE li-loop AS INTEGER   NO-UNDO.
    
    
    DO li-loop = YEAR(TODAY) TO YEAR(TODAY) - 10 BY -1:
        IF lc-sel-year = ""
            THEN lc-sel-year = STRING(li-loop,"9999").
        ELSE lc-sel-year = lc-sel-year + "|" + STRING(li-loop,"9999").
        
    END.
    
    IF ll-customer THEN
    DO:
        ASSIGN 
            lc-Account = this-user.AccountNumber.
        set-user-field("accountnumber",this-user.AccountNumber).
        
    END.
        
    ASSIGN
        lc-Account = get-value("accountnumber")
        lc-submit  = get-value("submitsource")
        lc-temp    = get-value("allcust")
        lc-month   = get-value("month")
        lc-year    = get-value("year")
        lc-reptype = get-value("reptype")
        lc-dtype   = get-value("dtype").
    
    
    IF lc-temp = "on"
        THEN RUN com-GetCustomerAccount( lc-global-accStatus-HelpDesk-All , lc-global-company , lc-global-user, OUTPUT lc-list-acc, OUTPUT lc-list-aname ).
    ELSE RUN com-GetCustomerAccount( lc-global-accStatus-HelpDesk-Active , lc-global-company , lc-global-user, OUTPUT lc-list-acc, OUTPUT lc-list-aname ).


  
    
    

    IF request_method = "GET" THEN
    DO:
        IF lc-month = "" THEN lc-month = STRING(MONTH(TODAY),"99").
        IF lc-year = "" THEN lc-year = STRING(YEAR(TODAY),"9999").
        IF lc-repType = "" THEN lc-repType = "1".
        
        
        IF lc-dtype = "" THEN lc-Dtype = "ISS".
        
      
        
        IF lc-Account = ""
            THEN ASSIGN lc-Account = ENTRY(1,lc-list-acc,"|").
    
        
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
    DEFINE VARIABLE li-count        AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-tr           AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-eng          AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-Banner1      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-Banner2      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-mth-label    AS CHARACTER NO-UNDO.
       
                   
    DEFINE BUFFER tt-ilog FOR tt-ilog.
    
    ASSIGN
        lc-Banner1 =    "Issue Number^right|Description^left|Issue Class^left|Raised By^left|System^left|SLA^left|" +
                "Date Raised^right|Time Raised^right|Date Completed^right|Time Completed^right|Date First Activity^right|Time First Activity^right|Activity Duration^right|SLA Achieved^left|SLA Comment^left|" +
                "Closed By^left".
                
    ASSIGN
        lc-Banner2 =    "Issue Number^right|Description^left|Raised By^left|System^left|SLA^left|" +
                        "Date Raised^right|Time Raised^right|" + 
                        "Latest Status Comments|Issue With".
                
                   
 
    
    FOR EACH tt-ilog NO-LOCK
        WHERE tt-ilog.isClosed = TRUE
        BREAK BY tt-ilog.AccountNumber
              BY tt-ilog.period DESC
              BY tt-ilog.IssueNumber
        :

        IF FIRST-OF(tt-ilog.AccountNumber) THEN
        DO:
            FIND customer WHERE customer.CompanyCode = lc-global-company
                AND customer.AccountNumber = tt-ilog.AccountNumber
                NO-LOCK NO-ERROR.
             RUN ip-SummaryPage (tt-ilog.AccountNumber).
        END.
        
        IF FIRST-OF(tt-ilog.period) THEN
        DO:           
            
            ASSIGN 
                lc-mth-label = "Issues raised during the month of "  + 
                ENTRY(MONTH(tt-ilog.CreateDate),lc-Global-Months-Name,"|") + " " + string(YEAR(tt-ilog.CreateDate),"9999").
            {&out} SKIP
                htmlib-StartMntTable() SKIP
                '<tr><td colspan=' NUM-ENTRIES(lc-Banner1,"|") ' align="center"><h3>' lc-mth-label '</h3></td></tr>' SKIP
                htmlib-TableHeading(lc-Banner1) SKIP.

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
            htmlib-MntTableField(html-encode(STRING(tt-ilog.iType)),'left')

            htmlib-MntTableField(html-encode(STRING(tt-ilog.RaisedLoginID)),'left')

            htmlib-MntTableField(html-encode(STRING(tt-ilog.AreaCode)),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.SLADesc)),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.CreateDate,"99/99/9999")),'right')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.CreateTime,"hh:mm")),'right').
        
        IF tt-ilog.CompDate <> ? THEN
            {&out} 
                htmlib-MntTableField(html-encode(STRING(tt-ilog.CompDate,"99/99/9999")),'right')
                htmlib-MntTableField(html-encode(STRING(tt-ilog.CompTime,"hh:mm")),'right').
        ELSE
            {&out} 
                htmlib-MntTableField(html-encode(""),'right')
                htmlib-MntTableField(html-encode(""),'right').    

        IF tt-ilog.fActDate <> ? THEN
            {&out} 
                htmlib-MntTableField(html-encode(STRING(tt-ilog.fActDate,"99/99/9999")),'right')
                htmlib-MntTableField(html-encode(STRING(tt-ilog.fActTime,"hh:mm")),'right').
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

        {&out} 
            '</tr>' SKIP.

        IF LAST-OF(tt-ilog.period) THEN
        DO:
            {&out} SKIP 
                htmlib-EndTable()
                SKIP.

        END.

    END.
    
    /** Open issue */
    
    FOR EACH tt-ilog NO-LOCK
        WHERE tt-ilog.isClosed = FALSE
          AND tt-ilog.catCode <> "Project"
        BREAK BY tt-ilog.AccountNumber
              BY tt-ilog.period DESC
              BY tt-ilog.IssueNumber
        :

               
        IF FIRST(tt-ilog.period) THEN
        DO:           
            
            ASSIGN 
                lc-mth-label = "Outstanding issues".
            {&out} SKIP
                htmlib-StartMntTable() SKIP
                '<tr><td colspan=' NUM-ENTRIES(lc-Banner2,"|") ' align="center"><h3>' lc-mth-label '</h3></td></tr>' SKIP
                htmlib-TableHeading(lc-Banner2) SKIP.

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
   
            htmlib-MntTableField(html-encode(STRING(tt-ilog.RaisedLoginID)),'left')

            htmlib-MntTableField(html-encode(STRING(tt-ilog.AreaCode)),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.SLADesc)),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.CreateDate,"99/99/9999")),'right')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.CreateTime,"hh:mm")),'right')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.latestComment )),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.assignto)),'left')
                
       
            SKIP .

        {&out} 
            '</tr>' SKIP.

        IF LAST(tt-ilog.period) THEN
        DO:
            {&out} SKIP 
                htmlib-EndTable()
                SKIP.

        END.

    END.
    
    /** Open Project */
    
    FOR EACH tt-ilog NO-LOCK
        WHERE tt-ilog.isClosed = FALSE
          AND tt-ilog.catCode = "Project"
        BREAK BY tt-ilog.AccountNumber
              BY tt-ilog.period DESC
              BY tt-ilog.IssueNumber
        :

               
        IF FIRST(tt-ilog.period) THEN
        DO:           
            
            ASSIGN 
                lc-mth-label = "Projects".
            {&out} SKIP
                htmlib-StartMntTable() SKIP
                '<tr><td colspan=' NUM-ENTRIES(lc-Banner2,"|") ' align="center"><h3>' lc-mth-label '</h3></td></tr>' SKIP
                htmlib-TableHeading(lc-Banner2) SKIP.

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
   
            htmlib-MntTableField(html-encode(STRING(tt-ilog.RaisedLoginID)),'left')

            htmlib-MntTableField(html-encode(STRING(tt-ilog.AreaCode)),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.SLADesc)),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.CreateDate,"99/99/9999")),'right')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.CreateTime,"hh:mm")),'right')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.latestComment )),'left')
            htmlib-MntTableField(html-encode(STRING(tt-ilog.assignto)),'left')
                
       
            SKIP .

        {&out} 
            '</tr>' SKIP.

        IF LAST(tt-ilog.period) THEN
        DO:
            {&out} SKIP 
                htmlib-EndTable()
                SKIP.

        END.

    END.
    
    FIND FIRST tt-cid NO-LOCK NO-ERROR.
           
    IF AVAILABLE tt-cid THEN
    DO:
        {&out} SKIP
            '<script>' SKIP
            
            'window.onload = function()~{' SKIP
            .
        FOR EACH tt-cid NO-LOCK:
                
            {&out}      
                'var ctx = document.getElementById("' tt-cid.id '").getContext("2d");' SKIP.
            
            IF  tt-cid.id BEGINS "B" THEN 
            DO:
                {&out}
                    'window.myPie = new Chart(ctx).Bar(pd' tt-cid.id ', ~{' SKIP
                    '  responsive : true ' SKIP
                    '~});' SKIP.
               
            END.
        /*
        ELSE {&out}
                'window.myPie = new Chart(ctx).Pie(pd' tt-cid.id ');' SKIP.
        */
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



    RUN rep/clientrepbuild.p (
        lc-global-company,
        lc-global-user,
        lc-Account,
        ld-lodate,
        ld-hidate,
        SUBSTR(TRIM(lc-classlist),2),
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
            '<tr>'
            '<td align=right valign=top>' 
            (IF LOOKUP("accountnumber",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("From Customer")
            ELSE htmlib-SideLabel("From Customer"))
            
            '</td>'
            '<td align=left valign=top>' .
        {&out-long}   
            htmlib-SelectLong("accountnumber",lc-list-acc,lc-list-aname,lc-Account).
        {&out} 
            '</td></tr>'.
    END.
    


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
    {&out}
        '<tr><td valign="top" align="right">' 
        htmlib-SideLabel("Report Month/Year")
        '</td>'
        '<td align=left valign=top>' 
        htmlib-Select("month",lc-sel-month,lc-sel-month,lc-month) " / "
        htmlib-Select("year",lc-sel-year,lc-sel-year,lc-year)'</td></tr>'.
        
    {&out}
        '<tr><td valign="top" align="right">' 
        htmlib-SideLabel("Report Type")
        '</td>'
        '<td align=left valign=top>' 
        htmlib-Select("reptype","1|3","1 Month|3 Month",lc-repType) '</td></tr>'.
   
    
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

        
   /*
    {&out}
        '<tr><td valign="top" align="right">' 
        htmlib-SideLabel("Date Selection By")
        '</td>'
        '<td align=left valign=top>' 
        htmlib-Select("dtype",lc-list-dtcode,lc-list-dtdesc,lc-dtype) '</td></tr>'.
        
    
    */
    {&out} htmlib-hidden ("dtype","ISS").
    
     
  
    {&out} 
        '</table>' SKIP.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-SetDateRange:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    
    DEFINE VARIABLE ld-dt1 AS DATE NO-UNDO.
    DEFINE VARIABLE ld-dt2 AS DATE NO-UNDO.
        
    ASSIGN 
        ld-dt1 = DATE(int(lc-month),1,int(lc-year)).
    
    IF lc-repType = "1"
        THEN ASSIGN ld-dt2 = Com-MonthEnd(ld-dt1).
    ELSE
    DO:
        ASSIGN 
            ld-dt2 = Com-MonthEnd(ld-dt1)
            ld-dt1 = ADD-INTERVAL(ld-dt1,-2,"MONTH").
              
    END.
   
    ASSIGN
        ld-lodate = ld-dt1
        ld-hidate = ld-dt2.
    
END PROCEDURE.

PROCEDURE ip-SummaryPage:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-account   AS CHARACTER NO-UNDO.
    

    DEFINE BUFFER customer FOR customer.
    DEFINE BUFFER issue    FOR issue.
    DEFINE VARIABLE li-count     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-sla       AS INTEGER   EXTENT 2 NO-UNDO.
    DEFINE VARIABLE ld-sla       AS DECIMAL   EXTENT 2 NO-UNDO.
    DEFINE VARIABLE li-loop      AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-time      AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-Tot-Time  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-temp      AS INTEGER   NO-UNDO.
    DEFINE VARIABLE ld-temp      AS DECIMAL   NO-UNDO.
    DEFINE VARIABLE lc-id        AS CHARACTER EXTENT 3 NO-UNDO.
    DEFINE VARIABLE li-tot-count AS INTEGER   EXTENT 3 NO-UNDO.
    
        
    DEFINE VARIABLE lc-tr        AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-eng       AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-Co        AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-hi        AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-tCol      AS INTEGER       NO-UNDO.
    DEFINE VARIABLE lc-lb        AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-set       AS INTEGER   NO-UNDO.

    ASSIGN
        lc-co = "#F7464A,#46BFBD,#FDB45C,#949FB1,#4D5360,#FF5A5E,#5AD3D1,#FFC870,#A8B3C5,#616774" 
        lc-hi = lc-co.
  
    DEFINE BUFFER tt-ilog FOR tt-ilog.
    
    FIND customer WHERE customer.CompanyCode = lc-global-company
        AND customer.AccountNumber = pc-Account
        NO-LOCK NO-ERROR.
                
     
    FOR EACH tt-ilog NO-LOCK
        WHERE tt-ilog.AccountNumber = pc-account
        :
       
        ASSIGN 
            li-count    = li-count + 1
            li-Tot-Time = li-Tot-Time + tt-ilog.iActDuration
            li-sla[1]   = li-sla[1] + IF tt-ilog.SLAAchieved THEN 1 ELSE 0 
            li-sla[2]   = li-sla[2] + IF tt-ilog.SLAAchieved THEN 0 ELSE 1
            .
              
    END.
    
    DO li-loop = 1 TO 2:
        IF li-sla[li-loop] <> 0 THEN
            ASSIGN ld-sla[li-loop] = ROUND( li-sla[li-loop] / ( li-count / 100 ),2).
    END.
    
    
    {&out} 
        '<div style="page-break-before: always;"><br /><h1 align="center"  style="page-break-after: always;">' SKIP.
        
    FOR FIRST doch NO-LOCK
        WHERE doch.CompanyCode = lc-global-company
        AND doch.RelType = "customer"
        AND doch.RelKey  = customer.AccountNumber
        AND doch.descr = "Report Logo":
            
          ASSIGN 
            lc-doc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"Document",STRING(ROWID(doch))).
        
        {&out} '<img src="' 
             appurl 
            '/sys/docview.' 
            LC(doch.DocType) '?docid=' url-encode(lc-doc-key,"Query") '" alt="Logo" style="width: 40%;"><br><br>'.
            
                 
    END.  
             
    {&out}   
        'Service report for the period<br />'
        STRING(ld-lodate,"99/99/9999")  ' to ' STRING(ld-hidate,"99/99/9999") '<br />'
        '</div>' SKIP.

    ASSIGN
        li-Temp  = 0
        li-Time  = 0
        lc-id[1] = "N" + string(ROWID(Customer)) /* Number of issues */
        lc-id[2] = "T" + string(ROWID(Customer)) /* Time */
        lc-id[3] = "B" + string(ROWID(Customer)) /* Bar Graph */
        
        
        .
         
    DO li-loop = 1 TO 3:
        CREATE tt-cid.
        ASSIGN 
            tt-cid.id = lc-id[li-loop].
        
    END.
    FOR EACH tt-ilog NO-LOCK
        WHERE tt-ilog.AccountNumber = pc-account
        AND tt-ilog.isClosed = TRUE
        BREAK BY tt-ilog.AreaCode:
        
        ASSIGN
            li-temp = li-temp + 1
            li-time = li-time + tt-ilog.iActDuration.
            
        FIND tt-month WHERE tt-month.AreaCode = tt-ilog.areaCode EXCLUSIVE-LOCK NO-ERROR.
        IF NOT AVAILABLE tt-month THEN CREATE tt-month.
        ASSIGN 
            tt-month.areaCode            = tt-ilog.AreaCode
            tt-month.val[tt-ilog.period] = tt-month.val[tt-ilog.period] + 1.
                   
            
        IF NOT LAST-OF(tt-ilog.AreaCode) THEN NEXT.
        
        IF lc-lb = ""
            THEN lc-lb = tt-ilog.AreaCode.
        ELSE lc-lb = lc-lb + "," + tt-ilog.AreaCode.
        
        CREATE tt-data.
        ASSIGN 
            tt-data.id  = lc-id[1]
            tt-data.lbl = tt-ilog.AreaCode
            tt-data.val = li-temp.
        
        CREATE tt-data.
        ASSIGN 
            tt-data.id  = lc-id[2]
            tt-data.lbl = tt-ilog.AreaCode
            tt-data.val = ROUND(ROUND(li-time / 60,2) / 60,2).
            
        CREATE tt-data.
        ASSIGN 
            tt-data.id        = lc-id[3]
            tt-data.lbl       = tt-ilog.AreaCode
            tt-data.SetVal[1] = li-temp.
        tt-data.SetVal[2] = ROUND(ROUND(li-time / 60,2) / 60,2).
        /*              
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
       
        */
        ASSIGN 
            li-temp = 0
            li-time = 0.
          
    END. 
    
    /*     
               
    {&out} SKIP 
        htmlib-EndTable() SKIP.
    */            
    {&out} 
        '<h1 align="center">' Customer.Name ' jobs resolved for the period ' STRING(ld-lodate,"99/99/9999")  ' to ' STRING(ld-hidate,"99/99/9999") '</h1>'
        '<h2 align="center">Issues by system</h2>'
        '<table width="100%" border="0">' SKIP.
    {&out} 
        '<tr><td colspan="2" align="CENTER" style="border: 1px solid #E4ECF0;">'.
        
    {&out} 
        '<div id="canvas-holder3">' SKIP
        '<canvas id="' lc-id[3] '" width="500" height="250"/>' SKIP
        '</div>' SKIP.
         
    {&out} 
        '</td></tr></table>'     SKIP.
      
    {&out} 
        '<script>' SKIP.
    
 
    /* Array Object for Bar */
    
       
    {&out} SKIP(2)
        'var pd' lc-id[3] ' = ~{' SKIP
        ' labels : [ ' .
    DO li-loop = 1 TO NUM-ENTRIES(lc-lb):
        IF li-loop > 1
            THEN {&out} ','.
        
        {&out} 
            '"' ENTRY(li-loop,lc-lb) '"'.
    END.
    
    {&out} 
        "]," SKIP /* end of 'labels' array */
        " datasets : [" SKIP.
              
    DO li-set = 1 TO 2:
        IF li-set = 1
            THEN {&out} 
                ' ~{' SKIP
                '   fillColor : "rgba(220,220,220,0.5)",' SKIP
                '   strokeColor : "rgba(220,220,220,0.8)",' SKIP
                '   highlightFill: "rgba(220,220,220,0.75)",' SKIP
                '   highlightStroke: "rgba(220,220,220,1)",' SKIP
                '   data :' SKIP
                '   ['. 
        ELSE {&out}
                ' ~{' SKIP
                '   fillColor : "rgba(151,187,205,0.5)",' SKIP
                '   strokeColor : "rgba(151,187,205,0.8)",' SKIP
                '   highlightFill : "rgba(151,187,205,0.75)",' SKIP
                '   highlightStroke : "rgba(151,187,205,1)",' SKIP            
                '   data :' SKIP
                '   ['.
        DO li-loop = 1 TO NUM-ENTRIES(lc-lb):
            FIND tt-data WHERE tt-data.id = lc-id[3]
                AND tt-data.lbl = entry(li-loop,lc-lb) NO-LOCK.
            {&out} tt-data.setVal[li-set].
            IF li-loop <  NUM-ENTRIES(lc-lb)
                THEN {&out} ','.
            ELSE {&out} ']' SKIP.
        END. 
        IF li-set = 1
            THEN {&out} '~},' SKIP.
        ELSE {&out} '~}' SKIP.     
                           
    END.
               
    {&out} 
        "]" SKIP. /* end of 'datasets' array */
    
    {&out} SKIP 
        '~};' SKIP. /* End bar obj */
    
    {&out} SKIP
        '</script>'.
    
      
    {&out} 
         '<div style="page-break-before: always;">&nbsp;</div>'
        '<div align="center"  style="page-break-after: always;">' SKIP.
     
    IF lc-repType = "1" THEN       
        {&out} SKIP
            REPLACE(htmlib-StartMntTable(),"100","40") SKIP
            htmlib-TableHeading(
            "|" + lc-labels[1] + "^right"
            ) SKIP.
                
    ELSE          
        {&out} SKIP
            REPLACE(htmlib-StartMntTable(),"100","40") SKIP
            htmlib-TableHeading(
            "|" + lc-labels[3] + "^right|" + lc-labels[2] + "^right|" + lc-labels[1] + "^right"
            ) SKIP.
                            
    FOR EACH tt-month NO-LOCK:
         
        {&out} 
            '<tr>'
            htmlib-MntTableField(html-encode(tt-month.AreaCode),'right')
            htmlib-MntTableField(html-encode(STRING(tt-month.Val[1])),'right').
            
        IF lc-RepType <> "1"
            THEN 
            {&out} htmlib-MntTableField(html-encode(STRING(tt-month.Val[2])),'right')
                htmlib-MntTableField(html-encode(STRING(tt-month.Val[3])),'right').
          
        {&out} 
            '</tr>'.
        
        ASSIGN
         li-tot-count[1] = li-tot-count[1] + tt-month.val[1]
         li-tot-count[2] = li-tot-count[2] + tt-month.val[2]
         li-tot-count[3] = li-tot-count[3] + tt-month.val[3].
         
    END.
    {&out} 
            '<tr>'
            htmlib-MntTableField("<b>Total",'right')
            htmlib-MntTableField('<b>' + html-encode(STRING(li-tot-count[1])),'right').
            
        IF lc-RepType <> "1"
            THEN 
            {&out} htmlib-MntTableField('<b>' + html-encode(STRING(li-tot-count[2])),'right')
                htmlib-MntTableField('<b>' + html-encode(STRING(li-tot-count[3])),'right').
          
        {&out} 
            '</tr>'.
            
                 
                
                
    {&out} SKIP 
        htmlib-EndTable()
        SKIP.
                           
    {&out} 
        '</div>' SKIP.
                          
                
    {&out} 
        '</div>'
        SKIP.
                
        
        
END PROCEDURE.

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      emails:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.

    DEFINE VARIABLE li-loop  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-rowid AS CHARACTER NO-UNDO.

 
    IF ( int(lc-year) = year(TODAY) 
        AND int(lc-month) > month(TODAY)) 
        OR  ( int(lc-year) > year(TODAY) )  THEN
    DO:
        RUN htmlib-AddErrorMessage(
            'month', 
            'You must select a valid report month/year',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
            
    END.
    
    
    
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
    DEFINE VARIABLE lc-Title    AS CHARACTER NO-UNDO.
        
  
    {lib/checkloggedin.i}

    
    FIND this-user
        WHERE this-user.LoginID = lc-global-user NO-LOCK NO-ERROR.
    
    ASSIGN
        ll-customer = this-user.UserClass = "CUSTOMER".
        
    ASSIGN
        lc-title = "Client Report" .

    RUN ip-InitialProcess.

    IF request_method = "POST" AND lc-submit = "" THEN
    DO:
        
        
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).

        IF lc-error-msg = "" THEN
        DO:
            FOR FIRST Customer WHERE Customer.CompanyCode = lc-global-Company
                                 AND Customer.AccountNumber = lc-Account NO-LOCK:
                lc-title = lc-title + " " + Customer.Name.
            END.                         
            RUN ip-SetDateRange.
            RUN ip-ProcessReport.
                                   
        END.
    END.
       
    RUN outputHeader.

    {&out} DYNAMIC-FUNCTION('htmlib-CalendarInclude':U) SKIP.
    {&out} htmlib-Header(lc-title) SKIP.
    RUN ip-ExportJScript.
    {&out} htmlib-JScript-Maintenance() SKIP.
    {&out} htmlib-StartForm("mainform","post", appurl + '/rep/clientrep.p' ) SKIP.
    
    {&out} '<div id="noprint">'SKIP.
     
    {&out} htmlib-ProgramTitle("Client Report") 
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

    
    {&out} '</div>' SKIP. /* noprint */
        
    IF request_method = "POST" 
        AND lc-error-msg = "" THEN
    DO:
        RUN set-labels.
       
        RUN ip-PrintReport.   
    END.



    
    {&out} htmlib-EndForm() SKIP.
    

    {&OUT} htmlib-Footer() SKIP.


END PROCEDURE.

PROCEDURE set-labels:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-loop AS INTEGER NO-UNDO.
    DEFINE VARIABLE ld-work AS DATE    NO-UNDO.
    
    IF lc-repType = "1"
        THEN ASSIGN lc-labels[1] = ENTRY(MONTH(ld-hidate),lc-Global-Months-Name,"|") + " " + string(YEAR(ld-hiDate),"9999").
    ELSE
    DO li-loop = 3 TO 1 BY -1:
        IF li-loop = 3
            THEN ld-work = ld-hidate.
        ELSE ld-work = ADD-INTERVAL(ld-work,-1,"months").
        
        lc-labels[li-loop] = ENTRY(MONTH(ld-work),lc-Global-Months-Name,"|") + " " + string(YEAR(ld-work),"9999").
        
        
    END.

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

