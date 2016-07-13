/***********************************************************************

    Program:        iss/ajax/actionbox.p
    
    Purpose:        Issue status rebuild   
    
    Notes:
    
    
    When        Who         What
    08/11/2014  phoski      Initial
  

***********************************************************************/
CREATE WIDGET-POOL.


DEFINE BUFFER b-table FOR issue.
DEFINE BUFFER webattr FOR WebAttr.
DEFINE VARIABLE lc-rowid         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-box           AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-OpenActions   AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-list-status   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-sname    AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-IsOpen        AS LOG       NO-UNDO.
DEFINE VARIABLE lc-currentstatus AS CHARACTER NO-UNDO.





{src/web2/wrap-cgi.i}
{lib/htmlib.i}
{iss/issue.i}
{lib/ticket.i}



/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

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
    output-content-type("text/plain~; charset=iso-8859-1":U).
  
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-process-web-request) = 0 &THEN

PROCEDURE process-web-request :
    /*------------------------------------------------------------------------------
      Purpose:     Process the web request.
      Parameters:  <none>
      objtargets:       
    ------------------------------------------------------------------------------*/
    
    ASSIGN
        lc-rowid = get-value("rowid")
        lc-box = get-value("box")
        lc-currentstatus = get-value("currentstatus").
        
    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
    
    lc-Global-Company = b-table.companyCode.

    
    RUN outputHeader.
    
    IF lc-box = "1" THEN
    DO:
        li-OpenActions = com-IssueActionsStatus(b-table.companyCode,b-table.issueNumber,'Open').

        IF li-OpenActions = 0 
            THEN RUN com-GetStatusIssue ( lc-global-company , OUTPUT lc-list-status, OUTPUT lc-list-sname ).
        ELSE RUN com-GetStatusIssueOpen ( lc-global-company , OUTPUT lc-list-status, OUTPUT lc-list-sname ).
   
        IF DYNAMIC-FUNCTION("islib-StatusIsClosed",
            b-table.CompanyCode,
            b-table.StatusCode) 
            THEN ll-IsOpen = FALSE.
        ELSE ll-isOpen = TRUE.
    
        IF li-OpenActions <> 0  THEN
        DO:
            {&out} '<div class="infobox" style="font-size: 10px;">This issue has open actions ('
            li-openActions 
            ') and can not be closed.</div>'
            SKIP.
        END.
        ELSE
        DO:
            IF ll-IsOpen THEN
            DO:
                FIND WebAttr WHERE WebAttr.SystemID = "SYSTEM"
                    AND   WebAttr.AttrID   = "ISSCLOSEWARNING" NO-LOCK NO-ERROR.
             
                IF AVAILABLE webattr THEN
                DO:
                    {&out} '<div class="infobox" style="font-size: 10px;">' REPLACE(webattr.attrValue,'~n','<br/>')
                    '</div>'
                SKIP.
                END.
            END.
        END.
       
        {&out} htmlib-Select("currentstatus",lc-list-status,lc-list-sname,
            lc-currentstatus).
           
    END.
    
    
    
    
    
    
  
END PROCEDURE.


&ENDIF

