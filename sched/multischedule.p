/***********************************************************************

    Program:        sched/multischedule.p
    
    Purpose:        Show Multiple Engineers Schedule - Select Engineers
    
    Notes:
    
    
    When        Who         What
    10/05/2015  phoski      Initial
    

***********************************************************************/
CREATE WIDGET-POOL.



DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.
DEFINE VARIABLE ld-rundate     AS DATE      NO-UNDO.
DEFINE VARIABLE lc-rundate     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-eng-list    AS CHARACTER NO-UNDO.



DEFINE BUFFER b-table FOR esched.
DEFINE BUFFER blogin  FOR webuser.





/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 14.14
         WIDTH              = 60.6.
/* END WINDOW DEFINITION */
                                                                        */

/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}
{lib/htmlib.i}
{iss/issue.i}
{lib/ticket.i}
{lib/project.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

PROCEDURE ip-HeaderInclude-Calendar:
/*------------------------------------------------------------------------------
        Purpose:  																	  
        Notes:  																	  
------------------------------------------------------------------------------*/


END PROCEDURE.

PROCEDURE ip-HTM-Header:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-return       AS CHARACTER NO-UNDO.

    pc-return = 
        lc-global-jquery +
        '<script src="/asset/sched/codebase/dhtmlxscheduler.js" type="text/javascript" charset="utf-8"></script>~n' + 
        '<link rel="stylesheet" href="/asset/sched/codebase/dhtmlxscheduler.css" type="text/css" media="screen" title="no title" charset="utf-8">~n' +
        '<script src="/asset/sched/codebase/ext/dhtmlxscheduler_year_view.js"></script>' +
        '<script src="/asset/sched/codebase/ext/dhtmlxscheduler_readonly.js"></script>' +
        '<script src="/asset/sched/codebase/ext/dhtmlxscheduler_tooltip.js"></script>' +
        '<script language="JavaScript" src="/asset/page/multischedule.js?v=1.0.0"></script>~n' 
        
        .
    

      
END PROCEDURE.

PROCEDURE ip-Page:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
        
    DEFINE BUFFER WebUser FOR WebUser.
        
    DEFINE VARIABLE li-count   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-col     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-name    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-checked AS CHARACTER NO-UNDO.
        
       
        
        
        
    {&out} htmlib-StartInputTable() skip.
        
    {&out} '<TR>'
    '<TD VALIGN="TOP" ALIGN="right">' 

            
        (IF LOOKUP("engineer",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Select Engineers")
        ELSE htmlib-SideLabel("Select Engineers"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">'.
            
    
        
    {&out} htmlib-StartInputTable() skip. /** Engineer **/
        
    ASSIGN 
        li-count = 0
        li-col   = 5.
        
    FOR EACH WebUser NO-LOCK
        WHERE CAN-DO(lc-global-internal,webuser.UserClass)
        AND webuser.CompanyCode = lc-Global-Company
        BY WebUser.Name:
            
        li-count = li-count + 1.
        IF li-count > li-col THEN
        DO:
            {&out} '</tr>' SKIP.
            li-count = 1.  
        END.             
        IF li-count = 1 THEN
        DO:
            {&out} '<tr>'.
                
        END.
        ASSIGN
            lc-name = "user" + string(ROWID(webuser)).
            
            
        IF request_method = "GET" 
            THEN ASSIGN lc-checked = IF LOOKUP(WebUser.loginid,lc-eng-list) > 0 THEN "on" ELSE "".
        ELSE ASSIGN     
                lc-checked = get-value(lc-name).
            
             
        {&out}
        '<td align="left">'
        htmlib-CheckBox(lc-name, IF lc-checked = 'on' THEN TRUE ELSE FALSE) 
                      
        DYNAMIC-FUNCTION("com-UserName",webuser.loginid)
        '&nbsp;&nbsp;'
        '</td>'.
                 
              
    END.
        
    IF li-count > 0
        THEN {&out} '</tr>' SKIP.
        
                     
    {&out} htmlib-EndTable() skip.
        
    {&out} '</tr>'
    '<TR>'
    '<TD VALIGN="TOP" ALIGN="right">' 

            
        (IF LOOKUP("rundate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Date")
        ELSE htmlib-SideLabel("Date"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">'
    
    htmlib-InputField("rundate",10,lc-rundate) 
    htmlib-CalendarLink("rundate")
            
    
    '</td></tr>' SKIP.
    
    
       

    {&out} htmlib-EndTable() skip.
END PROCEDURE.

PROCEDURE ip-SchedulePage:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE li-count    AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-this     AS INTEGER NO-UNDO.
    
    FOR EACH tt-schedule NO-LOCK:
        li-count = li-count + 1.
    END.
      

    {&out}
    '<div id="scheduler_here" class="dhx_cal_container" style="width:100%; height:900px;">
    <div class="dhx_cal_navline">
        <div class="dhx_cal_prev_button">&nbsp;</div>
        <div class="dhx_cal_next_button">&nbsp;</div>
        <div class="dhx_cal_today_button"></div>
        <div class="dhx_cal_date"></div>
        <div class="dhx_cal_tab" name="day_tab" style="right:204px;"></div>
        <div class="dhx_cal_tab" name="week_tab" style="right:140px;"></div>
        <div class="dhx_cal_tab" name="month_tab" style="right:76px;"></div>
        <div class="dhx_cal_tab" name="year_tab" style="right:280px;"></div>
    </div>
    <div class="dhx_cal_header"></div>
    <div class="dhx_cal_data"></div>       
    </div>'
        skip.
 
    
    {&out} '<script>' SKIP
            'var events = [' SKIP.
     
    FOR EACH tt-schedule NO-LOCK:
     
        li-this = li-this + 1.
        
        {&out} '~{' 
        'id:' tt-schedule.id 
        ', text:"' tt-schedule.txt + ' ' + tt-schedule.custName + ' - <b>' + tt-schedule.EngName '</b>"'
        ', start_date:"' DYNAMIC-FUNCTION("com-MMDDYYYY",tt-schedule.StartDate) " 08:30" '"'
        ', end_date:"' DYNAMIC-FUNCTION("com-MMDDYYYY",tt-schedule.EndDate) " 17:30" '"'
        ', engname:"'  tt-schedule.EngName '"'
        ', engcode:"'  tt-schedule.EngCode '"'
        ', issue:"'  tt-schedule.IssueNumber '"'
        ', custname:"'  tt-schedule.CustName '"'
        ', bdesc:"'  tt-schedule.bdesc '"'
        ', section_id:' tt-schedule.section_id
        ', crow:"'  tt-schedule.cRow '"~}'
            .
        IF li-this <> li-count THEN 
            {&out} ',' SKIP.
        ELSE
        {&out} SKIP.
    END.
    /*
    ***
    *** object contains all enqineers names - not used yet but could be later (timeline on sched)
    ***
    */              
    {&out} SKIP
            '];' SKIP
            'var sections=['
            SKIP.
    FOR EACH tt-schedule NO-LOCK
        BREAK BY tt-schedule.section_id:
        
        IF LAST-OF(tt-schedule.section_id) THEN
        DO:
            {&out} '~{key:' tt-schedule.section_id ', label:"' tt-schedule.engName '"~}'.
            IF NOT LAST(tt-schedule.section_id) 
                THEN {&out} ',' SKIP.  
            
        END.      
    END.  
    
    {&out} SKIP '];' SKIP. /* end of sections */
                  
            
            
    {&out} SKIP
        'drawSchedule ();' skip
        '</script>' SKIP.

END PROCEDURE.

PROCEDURE ip-validate:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.


    
    DEFINE VARIABLE lc-name  AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE ld-date  AS DATE      NO-UNDO.
    DEFINE VARIABLE li-loop  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-rowid AS CHARACTER NO-UNDO.
    
    DEFINE BUFFER webuser FOR webuser.
        
    ASSIGN
        ld-date = DATE(lc-rundate) no-error.
    IF ERROR-STATUS:ERROR 
        OR ld-date = ?
        THEN RUN htmlib-AddErrorMessage(
            'rundate', 
            'The date is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
            
    FOR EACH WebUser NO-LOCK
        WHERE CAN-DO(lc-global-internal,webuser.UserClass)
        AND webuser.CompanyCode = lc-Global-Company
        BY WebUser.Name:
            
        ASSIGN
            lc-name = "user" + string(ROWID(webuser)).
        
        IF get-value(lc-name) <> "on" THEN NEXT.
            
        lc-eng-list = TRIM(lc-eng-list + "," + WebUser.Loginid).
          
                   

    END.
     
    IF lc-eng-list = "" THEN
        RUN htmlib-AddErrorMessage(
            'engineer', 
            'You must select one or more engineers',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    ELSE ASSIGN lc-eng-list = substr(lc-eng-list,2).
     
     
END PROCEDURE.

PROCEDURE outputHeader :
    /*------------------------------------------------------------------------------
      Purpose:     Output the MIME header, and any "cookie" information needed 
                   by this procedure.  
      Parameters:  <none>
      objtargets:       In the event that this Web object is state-aware, this is
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
      objtargets:       
    ------------------------------------------------------------------------------*/
    
    {lib/checkloggedin.i} 

    IF request_method = "GET" THEN
    DO:
        ASSIGN 
            ld-rundate = TODAY - 7
            lc-eng-list = DYNAMIC-FUNCTION("com-ReadParam",lc-global-user,'/sched/multischedule.p')
            lc-rundate = STRING(ld-rundate,"99/99/9999").

        
                    
    END.
    ELSE
    DO:
        ASSIGN 
            lc-rundate  = get-value("rundate")
            lc-eng-list = "".
               
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).
            
        IF lc-error-msg = "" THEN
        DO:
               
            ASSIGN
                ld-rundate = DATE(lc-rundate).
            
                 
            DYNAMIC-FUNCTION("com-WriteParam",lc-global-user,'/sched/multischedule.p',lc-eng-list). 
            RUN prjlib-BuildScheduleData ( 
                lc-global-user,
                lc-global-company,
                lc-eng-list,
                ld-rundate,
                OUTPUT TABLE tt-schedule
                ).
                
            FIND FIRST  tt-schedule NO-LOCK NO-ERROR.
                
            IF NOT AVAILABLE tt-schedule
                THEN lc-error-msg = "No schedule found for selection".
         
        
        END.
               

        
              
    END.    
   
          
    RUN outputHeader.
     
         
    {&out} htmlib-Header("Multiple Engineer Schedule") skip.
  

    {&out} htmlib-StartForm("mainform","post", appurl + '/sched/multischedule.p' ) skip.
    
    
    {&out} htmlib-ProgramTitle("Multiple Engineer Schedule"). 
   
    
    IF request_method = "GET"
        OR lc-error-msg <> "" THEN
    DO:
        RUN ip-page.
    
    
        IF lc-error-msg <> "" THEN
        DO:
            {&out} '<BR><BR><CENTER>' 
            htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
        END.
        
        {&out} '<center>' htmlib-SubmitButton("submitform","Show Schedule") 
        '</center>' SKIP
        htmlib-CalendarScript("rundate") skip.
        
    END.
    ELSE
    DO:
        RUN ip-SchedulePage.
        
    END. 
    
    
                         
    {&out} htmlib-EndForm() SKIP
    .

   

    {&OUT} htmlib-Footer() skip.
    
   
    
END PROCEDURE.


&ENDIF

