/***********************************************************************

    Program:        sys/surveycomplete.p
    
    Purpose:        Account Survey Complete        
    
    Notes:
    
    
    When        Who         What
    21/06/2016  phoski      Initial
    
***********************************************************************/

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE BUFFER acs_head FOR acs_head.
DEFINE BUFFER acs_line FOR acs_line.
DEFINE BUFFER company  FOR Company.
DEFINE BUFFER acs_rq   FOR acs_rq.
DEFINE BUFFER Issue    FOR Issue.

DEFINE VARIABLE ll-ok      AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lc-request AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-begin   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-end     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-efld    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-fld     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-id      AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop    AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-checked AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-complete AS LOGICAL  NO-UNDO.


DEFINE TEMP-TABLE tt-res NO-UNDO
    FIELD acs_line_id AS INTEGER
    FIELD rvalue      AS CHARACTER 
    INDEX acs_line_id acs_line_id.
    

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



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */


RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

PROCEDURE ip-Page:
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/

    
    {&out}  htmlib-StartInputTable() skip.
   
    {&out} '<tr><td style="padding-bottom: 8px;font-size:14px ">' REPLACE(lc-begin,'~n','<br />') '</td></tr>' SKIP.
    
       
    {&out} '<tr><td><br>' SKIP.
    
    {&out} '<table>' SKIP.
    
    FOR EACH acs_line NO-LOCK OF acs_head:
        
        IF acs_line.qType = "PARA"
            THEN
            {&out} '<tr><td style="font-size:14px;">' REPLACE(acs_line.qText,'~n','<br />') '</td>' SKIP.
        ELSE
        {&out} '<tr><td style="text-align: right;font-size:14px">' REPLACE(acs_line.qText,'~n','<br />') '</td>' SKIP.
        
    
        
        ASSIGN
            lc-fld = "f" + string(acs_line.DisplayOrder)
            lc-efld = "e" + string(acs_line.DisplayOrder).
        
        
        CASE acs_line.qType :
            WHEN "PARA" THEN
                DO:
                    {&out} '<td>&nbsp;</td><td>&nbsp;</td>' SKIP.
                END.
            WHEN "RANGE1-10" THEN
                DO:
                    {&out} '<td nowrap>' SKIP.
                
                    {&out} '<table><tr>' SKIP.
                    DO li-loop = 1 TO 10:
                        lc-id = lc-fld + "-" + string(li-loop).
                        
                        IF get-value(lc-id) = "on"
                            THEN lc-checked = "checked".
                        ELSE lc-checked = "".
                        {&out} 
                        '<td style="text-align=right">&nbsp;' 
                        IF li-loop = 10 THEN '' 
                        ELSE '&nbsp;' STRING(li-loop) '<br />'
                        SUBSTITUTE(
                            '<input class="inputfield" type="checkbox" id="&1" name="&1" &2 >',
                            lc-id,
                            lc-checked)
                        '</td>' skip.
        
                    END.
                
                    {&out} '</tr></table>' SKIP.
                               
                    {&out} '</td><td>' get-value(lc-efld) '</td>' SKIP.
                END.
            WHEN "LOG" THEN
                DO:
                    {&out} '<td nowrap>' SKIP.
                    {&out}  htmlib-Select-By-ID(lc-fld,"|Yes|No","|Yes|No",get-value(lc-fld)) SKIP.
               
                    {&out} '</td><td>' get-value(lc-efld) '</td>' SKIP.
              
                END.
            WHEN "COM" THEN
                DO:
                    {&out} '<td nowrap>' SKIP.
                
                    {&out} htmlib-TextArea(lc-fld,get-value(lc-fld),5,60) SKIP.
                
                    {&out} '</td><td>' get-value(lc-efld) '</td>' SKIP.
                END.
            WHEN "FIELD" THEN
                DO:
                    {&out} '<td nowrap>' SKIP.
                
                    {&out} htmlib-InputField(lc-fld,20,get-value(lc-fld))  SKIP.
                
                    {&out} '</td><td>' get-value(lc-efld) '</td>' SKIP.
                
                END.
               
            WHEN "NUMBER" THEN
                DO:
                    {&out} '<td nowrap>' SKIP.
                
                    {&out} htmlib-InputField(lc-fld,10,get-value(lc-fld))  SKIP.
                
                    {&out} '</td><td>' get-value(lc-efld) '</td>' SKIP.
                
                END.
                
            
        END CASE.
        
        {&out} '</tr>' SKIP.
              
    END.
    
    
    {&out} '</table>' SKIP.
    
    
    {&out} '</td></tr>' SKIP.
    
    
    
    {&out} '<tr><td style="padding-top: 8px;font-size:14px ">'  REPLACE(lc-end,'~n','<br />') '</td></tr>' SKIP.
    
     
    {&out} htmlib-EndTable() skip.
    

    {&out} '<br/ ><center>' htmlib-SubmitButton("submitform","Complete Survey") 
    '</center>' skip.
    
END PROCEDURE.

PROCEDURE ip-Validate:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE OUTPUT PARAMETER pl-ok        AS LOG NO-UNDO.
    
    DEFINE VARIABLE icount      AS INT      NO-UNDO.
    DEFINE VARIABLE lf-value    AS DECIMAL  NO-UNDO.
    
    
    EMPTY TEMP-TABLE tt-res.
    
    ASSIGN
        pl-ok = TRUE.
    FOR EACH acs_line NO-LOCK OF acs_head:
        
        IF acs_line.qType = "PARA" THEN NEXT.
        
        ASSIGN
            lc-fld = "f" + string(acs_line.DisplayOrder)
            lc-efld = "e" + string(acs_line.DisplayOrder).
        
        CREATE tt-res.
        ASSIGN 
            tt-res.acs_line_id = acs_line.acs_line_id
            tt-res.rvalue = get-value(lc-fld).
                   
        
        CASE acs_line.qType:
            WHEN "RANGE1-10" THEN
                DO:
                    ASSIGN 
                        iCount = 0.
                    
                    DO li-loop = 1 TO 10:
                        lc-id = lc-fld + "-" + string(li-loop).
                        
                        IF get-value(lc-id) = "on"
                        THEN ASSIGN
                                tt-res.rvalue = STRING(li-loop)
                                icount = icount + 1.
                               
                    END.
                    IF icount > 1
                        THEN set-user-field(lc-efld,"Please tick only one value.").
                    ELSE
                        IF icount = 0
                            AND acs_line.isMandatory 
                            THEN set-user-field(lc-efld,"Mandatory - Please tick one value.").
                
                
                END.
            WHEN "LOG" THEN
                DO:
                    IF get-value(lc-fld) = ""
                        AND acs_line.isMandatory 
                        THEN set-user-field(lc-efld,"Mandatory - Please select Yes Or No.").
                       
              
                END.
            WHEN "COM" THEN
                DO:
                    IF get-value(lc-fld) = ""
                        AND acs_line.isMandatory 
                        THEN set-user-field(lc-efld,"Mandatory - Please enter your reponse.").
                    
                    
                END.
            WHEN "FIELD" THEN
                DO:
                    IF get-value(lc-fld) = ""
                        AND acs_line.isMandatory 
                        THEN set-user-field(lc-efld,"Mandatory - Please enter your reponse.").
                
                END.
            WHEN "NUMBER" THEN
                DO:
                    IF get-value(lc-fld) = ""
                        AND acs_line.isMandatory 
                        THEN set-user-field(lc-efld,"Mandatory - Please enter your reponse.").
                    ELSE
                    DO:
                        lf-value = dec( get-value(lc-fld)) NO-ERROR.
                        IF ERROR-STATUS:ERROR
                            OR lf-value = ?
                            THEN set-user-field(lc-efld,"Mandatory - Please enter a valid number.").
                    END.    
                
                END.
            
            
            
        END CASE.
        
        IF get-value(lc-efld) <> "" THEN
        DO:
            set-user-field(lc-efld,'<b><div style="color:red">' + get-value(lc-efld) + '</div></b>').
             
            pl-ok = FALSE.
             
        END.
        
        
        
    
    END.
    
    RETURN.
    
    
    


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
  
      
    ASSIGN 
        lc-request    = get-value("request")
        ll-complete   = NO.
        
        
    FIND acs_rq WHERE acs_rq.rq_id = lc-request EXCLUSIVE-LOCK NO-ERROR.
    
    IF NOT AVAILABLE acs_rq THEN
    DO:
        RUN outputHeader.
        {&out} '<b>The survey you have requested does not exist</b>'.
        RETURN.
        
    END.
    
    IF acs_rq.rq_status <> 0 THEN
    DO:
        RUN outputHeader.
        IF acs_rq.rq_status = 99
            THEN {&out} '<b>The survey you have requested has expired</b>'.
       ELSE {&out} '<b>The survey you have requested has been completed</b>'.
        RETURN.
 
    END.
      
    FIND acs_head 
        WHERE acs_head.CompanyCode = acs_rq.CompanyCode
        AND acs_head.acs_code = acs_rq.acs_code NO-LOCK NO-ERROR.
       
   
    FIND Issue WHERE Issue.CompanyCode = acs_rq.CompanyCode
        AND Issue.IssueNumber = acs_rq.IssueNumber
        NO-LOCK NO-ERROR.
        
    IF request_method = "POST" THEN
    DO:
                    
        RUN ip-Validate( OUTPUT ll-ok ).
        
        IF ll-ok THEN
        DO:
            ASSIGN
                acs_rq.rq_status = 1
                acs_rq.rq_completed = NOW.
                
                
            FOR EACH acs_res OF acs_rq EXCLUSIVE-LOCK:
                DELETE acs_res.
            END.
            FOR EACH tt-res NO-LOCK:
                CREATE acs_res.
                BUFFER-COPY tt-res TO acs_res
                    ASSIGN 
                    acs_res.rq_id = acs_rq.rq_id.
                    
            END.
                
            RUN islib-CreateNote( Issue.CompanyCode,
                    Issue.IssueNumber,
                    "SYSTEM",
                    "SYS.MISC",
                    "Completed Survey " + acs_rq.rq_id + " " + acs_head.descr).
                     
            ASSIGN
                ll-complete = TRUE.
                
            
        END.
        
            
           
    
    END.
    
    RUN outputHeader.
    
    {&out} htmlib-Header(acs_head.wp_subject) skip.

    
    {&out} htmlib-StartForm("mainform","post", appurl + '/sys/surveycomplete.p' ) skip.


    {&out} 
    '<div style="padding: 10px 20px 10px 20px;">'
    htmlib-ProgramTitle(acs_head.wp_subject) skip.
    
    
           
    RUN lib/translatetemplate.p 
        (
        Issue.company,
        "None",
        Issue.issueNumber,
        NO,
        acs_head.wp_begin,
        OUTPUT lc-begin,
        OUTPUT lc-error
        ).
                                          
    RUN lib/translatetemplate.p 
        (
        Issue.company,
        "None",
        Issue.issueNumber,
        NO,
        acs_head.wp_end,
        OUTPUT lc-end,
        OUTPUT lc-error
        ).

    
    IF NOT ll-complete THEN RUN ip-Page.
    ELSE {&out} '<br/><br/><b><center>Thank you for completing the survey</center></b>' SKIP.
    
    
        
    {&out} SKIP
           '</div>'
           htmlib-Hidden("request", lc-request) skip
                      skip.

    
    {&out} htmlib-EndForm().

    
    {&OUT} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

