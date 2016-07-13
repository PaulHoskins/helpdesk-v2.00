/***********************************************************************

    Program:        rep/engtime.p
    
    Purpose:        Enqineer Time Management
    
    Notes:
    
    
    When        Who         What
    
    03/12/2014  phoski      Initial
    12/03/2016  phoski      Engineer in multi select instead of range
    02/07/2016  phoski      Admin Time option
         
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-char           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lodate         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-hidate         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-RepType        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-engType        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-eng-code       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-eng-desc       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-selectengineer AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-admin          AS CHARACTER NO-UNDO.


DEFINE BUFFER this-user FOR WebUser.
{rep/engtimett.i}
{lib/maillib.i}
{lib/princexml.i}



/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

FUNCTION percentage-calc RETURNS DECIMAL 
    (p-one AS INTEGER,
    p-two AS INTEGER) FORWARD.



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
{lib/replib.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */


RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-ExportJScript) = 0 &THEN


PROCEDURE ip-engineer-select:

    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER WebUser FOR WebUser.
    
    {&out} 
    '<select id="selectengineer" name="selectengineer" class="inputfield" ' skip
            'multiple="multiple" size=8 width="200px" style="width:200px;" >' skip.

 
    {&out}
    '<option value="ALL" selected >Select All</option>' skip.

    FOR EACH webUser NO-LOCK
        WHERE webuser.company = lc-global-company
        AND   webuser.UserClass = "internal"
        BY webUser.name:

                
 
        {&out}
        '<option value="'  webUser.loginid '" ' '>'  html-encode(webuser.name) '</option>' skip.
 
    END.
  
      

    {&out} '</select>'.



END PROCEDURE.



PROCEDURE ip-ExportJScript :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    {&out} skip
            '<script language="JavaScript" src="/scripts/js/hidedisplay.js"></script>' skip.

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


&IF DEFINED(EXCLUDE-ip-InitialProcess) = 0 &THEN

PROCEDURE ip-InitialProcess :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    
        
    ASSIGN
        ENTRY(1,lc-global-engType-Desc,"|") = "All"
        lc-lodate                           = get-value("lodate")         
        lc-hidate                           = get-value("hidate")
        lc-engType                          = get-value("engtype")
        lc-repType                          = get-value("reptype")
        lc-selectengineer = get-value("selectengineer")
        lc-admin          = get-value("admin")
        
        .
    IF request_method = "GET" THEN
    DO:
        
        IF lc-lodate = ""
            THEN ASSIGN lc-lodate = STRING(TODAY - 7, "99/99/9999").
        
        IF lc-hidate = ""
            THEN ASSIGN lc-hidate = STRING(TODAY, "99/99/9999").

        
    END.

    
    

END PROCEDURE.


&ENDIF

PROCEDURE ip-ProcessReport :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/


    RUN rep/engtimebuild.p (
        lc-global-company,
        lc-global-user,
        DATE(lc-lodate),
        DATE(lc-hidate),
        lc-selectEngineer,
        lc-engtype,
        lc-admin = "on",
        OUTPUT TABLE tt-engtime

        ).


END PROCEDURE.




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

           
    {&out}
    '<table align="center"><tr>' 
    '<td valign="top" align="right">' 
        (IF LOOKUP("lodate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("From Date")
        ELSE htmlib-SideLabel("From Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("lodate",10,lc-lodate) 
    htmlib-CalendarLink("lodate")
    '</td>' SKIP
    '<td valign="top" align="right">' 
        (IF LOOKUP("hidate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("To Date")
        ELSE htmlib-SideLabel("To Date"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("hidate",10,lc-hidate) 
    htmlib-CalendarLink("hidate")
    '</td>' skip.
    
    {&out} '<TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("engtype",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Engineer Type")
        ELSE htmlib-SideLabel("Engineer Type"))    '</TD>'.
    
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("engtype",lc-global-engType-Code,lc-global-engType-desc,lc-engtype) 
    '</TD>' skip.
    
    {&out} '<TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("reptype",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Report Type")
        ELSE htmlib-SideLabel("Report Type"))    '</TD>'.
    
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("reptype","DET|SUM","Detailed|Summary",lc-reptype) 
    '</TD></tr>' skip.
    
    {&out} '<tr><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("selectengineer",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Engineer(s)")
        ELSE htmlib-SideLabel("Engineer(s)"))    '</TD><td colpan="7">'.
    RUN ip-engineer-select.
     
    {&out} '</td>'.
    
     {&out} '</tr><tr>'
            '<TD VALIGN="TOP"  ALIGN="right">&nbsp;' 
            htmlib-SideLabel("Exclude Administration Time?")
     
             '</td><TD VALIGN="TOP" ALIGN="left">'
                htmlib-CheckBox("admin", IF lc-admin = 'on'
                                        THEN TRUE ELSE FALSE) 
            '</TD>'.
            
     

   
    {&out} '</tr></table>' skip.
END PROCEDURE.





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
   
    IF lc-selectengineer BEGINS "ALL," AND NUM-ENTRIES(lc-selectengineer) > 1 THEN lc-selectengineer = substr(lc-selectengineer,INDEX(lc-selectengineer,",") + 1).
    
    IF lc-selectEngineer = ""
    THEN lc-selectEngineer  = "ALL".
    
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


END PROCEDURE.


&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

PROCEDURE ip-Web:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-info         AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE lc-style        AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE lf-paid%        AS DECIMAL          NO-UNDO.
    DEFINE VARIABLE lf-prod%        AS DECIMAL          NO-UNDO.
    DEFINE VARIABLE li-stdmins      AS INTEGER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE li-adjtime      AS INTEGER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE li-availtime    AS INTEGER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE li-billable     AS INTEGER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE li-nonbillable  AS INTEGER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE li-loop         AS INTEGER          NO-UNDO.
    DEFINE VARIABLE li-count        AS INTEGER          NO-UNDO.
    DEFINE VARIABLE lc-tr           AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE li-eng          AS INTEGER          NO-UNDO.
    
        
    

    {&out} htmlib-StartMntTable() SKIP.

    IF lc-RepType = "DET"
        THEN {&out} htmlib-TableHeading('Engineer^left|Date^left|Standard<br/>Hours^right|Adjustment<br/>Hours^right|Reason^left|Total<br/>Available^right|Billable^right|Non Billable^right|Total<br/>Worked^right|Paid<br/>%^right|Productivity<br/>%^right') SKIP.
    ELSE {&out} htmlib-TableHeading('Engineer^left|Standard<br/>Hours^right|Adjustment<br/>Hours^right|Total<br/>Available^right|Billable^right|Non Billable^right|Total<br/>Worked^right|Paid<br/>%^right|Productivity<br/>%^right') SKIP.
    

    
    
    FOR EACH tt-engtime NO-LOCK
        BREAK BY tt-engtime.loginid
        BY tt-engtime.startdate
        :
   
        IF FIRST-OF(tt-engtime.loginid) THEN
        DO:
            ASSIGN
                lc-info = com-userName(tt-engtime.loginid)
                lc-style = 'font-weight:bold'
                li-stdmins[1] = 0
                li-adjtime[1] = 0
                li-availtime[1] = 0
                li-billable[1] = 0
                li-nonbillable[1] = 0
                li-count = 0
                .
        END.
        ELSE ASSIGN lc-info = ""
                lc-style = ""
                li-count = li-count + 1.
        
        
        DO li-loop = 1 TO 2:
        
            ASSIGN
                li-stdmins[li-loop] = li-stdmins[li-loop] + tt-engtime.StdMins
                li-adjtime[li-loop] = li-adjtime[li-loop] + tt-engtime.AdjTime
                li-availtime[li-loop] = li-availtime[li-loop] + tt-engtime.AvailTime
                li-billable[li-loop] = li-billable[li-loop] + tt-engtime.BillAble
                li-nonbillable[li-loop] = li-nonbillable[li-loop] + tt-engtime.nonBillAble
                .
                
        END.
        
          
        ASSIGN
            lf-paid% = 0
            lf-prod% = 0.
            
        IF tt-engtime.AvailTime <> 0 THEN
        DO:
            ASSIGN
                lf-paid% = percentage-calc(tt-engtime.BillAble,tt-engtime.AvailTime)
                lf-prod% = percentage-calc(tt-engtime.BillAble +  tt-engtime.NonBillAble,tt-engtime.AvailTime)
                .
        END.
         
        IF lc-RepType = "DET" THEN
        DO:    
            IF li-count MOD 2 = 0
                THEN lc-tr = '<tr style="background: #EBEBE6;">'.
            ELSE lc-tr = '<tr style="background: white;">'.            
            {&out}
            lc-tr SKIP
                  replib-RepField(lc-info,'',lc-style)
                  replib-RepField( string(tt-engtime.startdate,"99/99/9999")  + ' ' +
                                    com-DayName(tt-engtime.startdate,"S")
                                  ,'left','')
                  replib-RepField(com-TimeToString(tt-engtime.StdMins),'right','')
                  replib-RepField(com-TimeToString(tt-engtime.AdjTime),'right','')
                  replib-RepField(tt-engtime.AdjReason,'left','')
                  replib-RepField(com-TimeToString(tt-engtime.AvailTime),'right','')
                  replib-RepField(com-TimeToString(tt-engtime.billable),'right','')
                  replib-RepField(com-TimeToString(tt-engtime.nonbillable),'right','')
                  replib-RepField(com-TimeToString(tt-engtime.billable + tt-engtime.nonbillable),'right','')
                  replib-RepField(String(lf-paid%,"->>>>>>>>>>>9.99"),'right','')
                  replib-RepField(String(lf-prod%,"->>>>>>>>>>>9.99"),'right','')
                  
                '</tr>' SKIP.
        END.
                
        IF LAST-OF(tt-engtime.loginid) THEN
        DO:
            ASSIGN
                lc-info = (IF lc-repType = 'DET' THEN 'Total ' ELSE '' ) + com-userName(tt-engtime.loginid)
                lc-style = IF lc-repType = 'DET' THEN
                           'font-weight:bold;border-top:1px solid black;border-bottom:1px solid black;'
                           ELSE ''
                li-loop = 1.
            IF li-availtime[li-loop] <> 0 THEN
            DO:
                ASSIGN
                    lf-paid% = percentage-calc(li-billable[li-loop],li-availtime[li-loop])
                    lf-prod% = percentage-calc(li-billable[li-loop]+  li-nonbillable[li-loop],li-availtime[li-loop])
                    .
            END.
              
            IF lc-reptype = 'DET'
                THEN lc-tr = '<tr>'.
            ELSE
            DO:
                ASSIGN
                    li-eng = li-eng + 1.
              
                IF li-eng MOD 2 <> 0
                    THEN lc-tr = '<tr style="background: #EBEBE6;">'.
                ELSE lc-tr = '<tr style="background: white;">'.       
            END.    
            IF lc-repType = "DET" THEN
            DO:         
                {&out}
                lc-tr SKIP
                  replace(replib-RepField(lc-info,'right','font-weight:bold;'),'<td','<td colspan=2 ')
                                         
                  replib-RepField(com-TimeToString(li-stdmins[li-loop]),'right',lc-style)
                  replib-RepField(com-TimeToString(li-adjtime[li-loop]),'right',lc-style)
                  
                  replib-RepField('','left','')
                  
                  replib-RepField(com-TimeToString(li-availtime[li-loop]),'right',lc-style)
                  
                  replib-RepField(com-TimeToString(li-billable[li-loop]),'right',lc-style)
                  replib-RepField(com-TimeToString(li-nonbillable[li-loop]),'right',lc-style)
                  replib-RepField(com-TimeToString(li-billable[li-loop] + li-nonbillable[li-loop]),'right',lc-style)
                  replib-RepField(String(lf-paid%,"->>>>>>>>>>>9.99"),'right',lc-style)
                  replib-RepField(String(lf-prod%,"->>>>>>>>>>>9.99"),'right',lc-style)
                  
                '</tr>' SKIP
                '<tr>'
                replib-RepField('','left','')
                '</tr>' SKIP
                .
            END.
            ELSE
            DO:
                {&out}
                lc-tr SKIP
                  replib-RepField(lc-info,'left','')
                                         
                  replib-RepField(com-TimeToString(li-stdmins[li-loop]),'right',lc-style)
                  replib-RepField(com-TimeToString(li-adjtime[li-loop]),'right',lc-style)
                  
                           
                  replib-RepField(com-TimeToString(li-availtime[li-loop]),'right',lc-style)
                  
                  replib-RepField(com-TimeToString(li-billable[li-loop]),'right',lc-style)
                  replib-RepField(com-TimeToString(li-nonbillable[li-loop]),'right',lc-style)
                  replib-RepField(com-TimeToString(li-billable[li-loop] + li-nonbillable[li-loop]),'right',lc-style)
                  replib-RepField(String(lf-paid%,"->>>>>>>>>>>9.99"),'right',lc-style)
                  replib-RepField(String(lf-prod%,"->>>>>>>>>>>9.99"),'right',lc-style)
                  
                '</tr>' SKIP
                .
            END.
              
        END.
        IF LAST(tt-engtime.loginid) THEN
        DO:
            ASSIGN
                lc-info = 'Report Total'
                lc-style = 'font-weight:bold;border-top:1px solid black;border-bottom:1px solid black;'
                li-loop = 2.
            IF li-availtime[li-loop] <> 0 THEN
            DO:
                ASSIGN
                    lf-paid% = percentage-calc(li-billable[li-loop],li-availtime[li-loop])
                    lf-prod% = percentage-calc(li-billable[li-loop]+  li-nonbillable[li-loop],li-availtime[li-loop])
                    .
            END.
                 
            IF lc-repType = 'DET' THEN
            DO:             
                {&out}
                '<tr>' SKIP
                  replace(replib-RepField(lc-info,'right','font-weight:bold;'),'<td','<td colspan=2 ')
               
                                 
                  replib-RepField(com-TimeToString(li-stdmins[li-loop]),'right',lc-style)
                  replib-RepField(com-TimeToString(li-adjtime[li-loop]),'right',lc-style)
                  
                  replib-RepField('','left','')
                  
                  replib-RepField(com-TimeToString(li-availtime[li-loop]),'right',lc-style)
                  
                  replib-RepField(com-TimeToString(li-billable[li-loop]),'right',lc-style)
                  replib-RepField(com-TimeToString(li-nonbillable[li-loop]),'right',lc-style)
                  replib-RepField(com-TimeToString(li-billable[li-loop] + li-nonbillable[li-loop]),'right',lc-style)
                  replib-RepField(String(lf-paid%,"->>>>>>>>>>>9.99"),'right',lc-style)
                  replib-RepField(String(lf-prod%,"->>>>>>>>>>>9.99"),'right',lc-style)
                  
                '</tr>' SKIP.
            END.
            ELSE
            DO:
                {&out}
                '<tr>' SKIP
                  replib-RepField(lc-info,'right','font-weight:bold;')
                                   
                  replib-RepField(com-TimeToString(li-stdmins[li-loop]),'right',lc-style)
                  replib-RepField(com-TimeToString(li-adjtime[li-loop]),'right',lc-style)
                  
          
                  
                  replib-RepField(com-TimeToString(li-availtime[li-loop]),'right',lc-style)
                  
                  replib-RepField(com-TimeToString(li-billable[li-loop]),'right',lc-style)
                  replib-RepField(com-TimeToString(li-nonbillable[li-loop]),'right',lc-style)
                  replib-RepField(com-TimeToString(li-billable[li-loop] + li-nonbillable[li-loop]),'right',lc-style)
                  replib-RepField(String(lf-paid%,"->>>>>>>>>>>9.99"),'right',lc-style)
                  replib-RepField(String(lf-prod%,"->>>>>>>>>>>9.99"),'right',lc-style)
                  
                '</tr>' SKIP.
                    
            END.    
                    
                    
        END.
        
                    
                
    END.
    {&out} '</table>' SKIP.
    
            
END PROCEDURE.

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
   
    RUN ip-InitialProcess.

    IF request_method = "POST" THEN
    DO:
        
        
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).

        IF lc-error-msg = "" THEN
        DO:
            RUN ip-ProcessReport.
            
            
            
        END.
    END.

    
    RUN outputHeader.

    {&out} DYNAMIC-FUNCTION('htmlib-CalendarInclude':U) skip.
    {&out} htmlib-Header("Engineer Time Management") skip.
    RUN ip-ExportJScript.
    {&out} htmlib-JScript-Maintenance() skip.
    {&out} htmlib-StartForm("mainform","post", appurl + '/rep/engtime.p' ) skip.
    {&out} htmlib-ProgramTitle("Engineer Time Management") 
    htmlib-hidden("submitsource","") skip.
    {&out} htmlib-BeginCriteria("Report Criteria").
    
    
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
       
        {&out} htmlib-BeginCriteria("Report") '<div id="repdata">' SKIP.
        
        RUN ip-Web. 
        {&out} '</div>' htmlib-EndCriteria() SKIP.               
        
    END.



    
    {&out} htmlib-EndForm() skip.
    {&out} htmlib-CalendarScript("lodate") skip
           htmlib-CalendarScript("hidate") skip.
   

    {&OUT} htmlib-Footer() skip.


END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

FUNCTION percentage-calc RETURNS DECIMAL 
    ( p-one AS INTEGER ,
    p-two AS INTEGER  ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE p-result AS DECIMAL.
    /*  p-one =   billable/nonbillable total      */
    /*  p-two =   productivity / contarcted hours */
    p-result = ROUND(( p-one * 100) / p-two , 2).
    RETURN p-result.

		
END FUNCTION.



