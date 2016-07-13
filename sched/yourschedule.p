/***********************************************************************

    Program:        sched/yourschedule.p
    
    Purpose:        Show An Engineers Schedule - Not Edittable
    
    Notes:
    
    
    When        Who         What
    25/04/2015  phoski      Initial
    

***********************************************************************/
CREATE WIDGET-POOL.



DEFINE VARIABLE lc-rowid    AS CHARACTER    NO-UNDO.

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
            '<script language="JavaScript" src="/asset/page/yourschedule.js?v=1.0.0"></script>~n' 
        
            .
    

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

    
    ASSIGN
        lc-rowid = get-value("engineer").
        
    
    ASSIGN
        lc-rowid = DYNAMIC-FUNCTION("sysec-DecodeValue",lc-user,TODAY,"ScheduleKey",lc-rowid).
        
   
    FIND blogin WHERE ROWID(blogin) = to-rowid(lc-rowid) NO-LOCK NO-ERROR.
    
    RUN prjlib-BuildScheduleData ( 
        lc-global-user,
        lc-global-company,
                blogin.LoginID,
        TODAY - li-global-sched-days-back,
        OUTPUT TABLE tt-schedule
        ).
        
    
    
       
    RUN outputHeader.
     
         
    {&out} htmlib-Header("Project Schedule") skip.
  

    {&out} htmlib-StartForm("mainform","post", appurl + '/sched/yourschedule.p' ) skip.
    
    
    {&out} htmlib-ProgramTitle("Project Schedule - " + dynamic-function("com-UserName",blogin.LoginID)). 
   
    
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
                ', text:"' tt-schedule.txt '"'
                ', start_date:"' DYNAMIC-FUNCTION("com-MMDDYYYY",tt-schedule.StartDate) " 08:30" '"'
                ', end_date:"' DYNAMIC-FUNCTION("com-MMDDYYYY",tt-schedule.EndDate) " 17:30" '"'
                ', engname:"'  tt-schedule.EngName '"'
                ', engcode:"'  tt-schedule.EngCode '"'
                ', issue:"'  tt-schedule.IssueNumber '"'
                ', custname:"'  tt-schedule.CustName '"'
                ', bdesc:"'  tt-schedule.bdesc '"'
                ', crow:"'  tt-schedule.cRow '"~}'
                .
        IF li-this <> li-count THEN 
        {&out} ',' SKIP.
        ELSE
        {&out} SKIP.
     END.
                  
    {&out} SKIP
            '];' SKIP.
           
            
    {&out} SKIP
        'drawSchedule ();' skip
        '</script>' SKIP.
                         
    {&out} htmlib-EndForm() skip.

   

    {&OUT} htmlib-Footer() skip.
    
   
    
END PROCEDURE.


&ENDIF

