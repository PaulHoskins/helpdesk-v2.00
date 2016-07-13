/***********************************************************************

    Program:        sys/webacsquestionmnt.p
    
    Purpose:        Account Survey Maintenance - Test Survey
    
    Notes:
    
    
    When        Who         What
    18/06/2016  phoski      Initial
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-mode        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title       AS CHARACTER NO-UNDO.


DEFINE BUFFER b-valid FOR acs_line.
DEFINE BUFFER b-table FOR acs_line.


DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-field        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-issue        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-projcode     AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop         AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-qtype        AS CHARACTER NO-UNDO.





{src/web2/wrap-cgi.i}
{lib/htmlib.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      emails:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.


    DEFINE VARIABLE li-int   AS INTEGER NO-UNDO.
    
    IF lc-issue = ""
        OR lc-issue = ?
        THEN RUN htmlib-AddErrorMessage(
            'issue', 
            'You must enter the issue',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    IF pc-error-msg <> "" THEN RETURN.
    
    li-int = INTEGER(lc-issue) NO-ERROR.
    
    IF ERROR-STATUS:ERROR
        OR NOT CAN-FIND(Issue WHERE Issue.CompanyCode = lc-global-company
        AND Issue.IssueNumber = li-int)
        THEN RUN htmlib-AddErrorMessage(
            'issue', 
            'The issue does not exist',
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
      emails:       In the event that this Web object is state-aware, this is
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
      emails:       
    ------------------------------------------------------------------------------*/
    DEFINE BUFFER this-surv     FOR acs_head.
     
    {lib/checkloggedin.i} 

    ASSIGN 
        lc-ProjCode  = get-value("projectcode")
        lc-mode = get-value("mode")
        lc-rowid = get-value("rowid")
        lc-search = get-value("search")
        lc-firstrow = get-value("firstrow")
        lc-lastrow  = get-value("lastrow")
        lc-navigation = get-value("navigation").

    IF lc-mode = "" 
        THEN ASSIGN lc-mode = get-field("savemode")
            lc-rowid = get-field("saverowid")
            lc-search = get-value("savesearch")
            lc-firstrow = get-value("savefirstrow")
            lc-lastrow  = get-value("savelastrow")
            lc-navigation = get-value("savenavigation").

    ASSIGN 
        lc-parameters = "search=" + lc-search +
                           "&firstrow=" + lc-firstrow + 
                           "&lastrow=" + lc-lastrow.

    CASE lc-mode:
        WHEN 'add'
        THEN 
            ASSIGN 
                lc-title = 'Add'
                lc-link-label = "Cancel addition"
                lc-submit-label = "Add Question".
        WHEN 'view'
        THEN 
            ASSIGN 
                lc-title = 'View'
                lc-link-label = "Back"
                lc-submit-label = "".
        WHEN 'delete'
        THEN 
            ASSIGN 
                lc-title = 'Delete'
                lc-link-label = 'Cancel deletion'
                lc-submit-label = 'Delete Question'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Question'.
    END CASE.
    
    ASSIGN 
        lc-link-label = "Cancel Test"
        .

    FIND this-surv WHERE this-surv.CompanyCode = lc-global-company
        AND this-surv.acs_code = lc-projCode
        NO-LOCK NO-ERROR.
            
                     

    ASSIGN
        lc-title = ' Survey Test -<i> ' + lc-ProjCode + " " + this-surv.descr + '</i>'
        lc-link-url = appurl + '/sys/webacs.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&projectcode=' + lc-projCode +
                                  '&time=' + string(TIME)
        .

    
    
    
    

    IF request_method = "POST" THEN
    DO:

       
        ASSIGN 
            lc-issue  = get-value("issue")
            .

            
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).

        IF lc-error-msg = "" THEN
        DO:
            FIND LAST Issue WHERE Issue.CompanyCode = lc-global-company
                              AND Issue.IssueNumber = int(lc-issue) NO-LOCK.

            FIND webuser
            WHERE webuser.LoginID = lc-global-user
                NO-LOCK NO-ERROR.
            
            RUN lib/createSurveyRequest.p 
                ( Issue.CompanyCode , lc-ProjCode ,
                  Issue.IssueNumber, lc-global-user , webuser.Email,NO,OUTPUT lc-error-msg).
   
            RUN outputHeader.
            set-user-field("navigation",'refresh').
            set-user-field("firstrow",lc-firstrow).
            set-user-field("search",lc-search).
            set-user-field("projectcode",lc-projCode).
            set-user-field("testsent","YES").
            RUN run-web-object IN web-utilities-hdl ("sys/webacs.p").
            RETURN.
        END.
    END.


    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/sys/webacstest.p' )
           htmlib-ProgramTitle(lc-title) skip.

    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) SKIP
           htmlib-Hidden("projectcode", lc-projcode) skip
           htmlib-Hidden ("nullfield", lc-navigation) skip.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    {&out} htmlib-StartInputTable() skip.

    
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("issue",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Issue Number")
        ELSE htmlib-SideLabel("Issue Number"))
    '</TD>'.
    
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("issue",20,lc-issue) skip
        '</TD>' skip.
    
    {&out} '</TR>' skip.
    

    
    {&out} htmlib-EndTable() skip.


    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.

   
    {&out} '<br /><center>' htmlib-SubmitButton("submitform","Test Survey") 
        '</center>' skip.
      
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

