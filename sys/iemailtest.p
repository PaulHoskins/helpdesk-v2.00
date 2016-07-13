/***********************************************************************

    Program:        sys/iemailtest.p
    
    Purpose:        Email Template Tester  
    
    Notes:
    
    
    When        Who         What
    02/06/2014  phoski      Initial      
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


DEFINE BUFFER b-valid FOR iemailtmp.
DEFINE BUFFER b-table FOR iemailtmp.
DEFINE BUFFER issue   FOR issue.



DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.



DEFINE VARIABLE lc-descr        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-tmpcode      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-tmptxt       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-issue        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-convtxt      AS CHARACTER NO-UNDO.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






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

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      emails:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-int      AS INTEGER      NO-UNDO.


    ASSIGN 
        li-int = INT(lc-issue) NO-ERROR.

    IF ERROR-STATUS:ERROR
        OR li-int < 1 THEN
    DO:
        RUN htmlib-AddErrorMessage(
            'issue', 
            'The issue number must be entered',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
        RETURN.

    END.

    FIND issue WHERE issue.companyCode = lc-global-company
        AND issue.issueNumber = li-int NO-LOCK NO-ERROR.

    IF NOT AVAILABLE issue THEN
    DO:
        RUN htmlib-AddErrorMessage(
            'issue', 
            'The issue number does not exist',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
        RETURN.

    END.
    
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
     *      The following example sets cutmpcode=23 and expires tomorrow at (about) the 
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
    
    DEFINE VARIABLE iloop       AS INTEGER      NO-UNDO.
    DEFINE VARIABLE cPart       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE cCode       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE cDesc       AS CHARACTER     NO-UNDO.

    {lib/checkloggedin.i} 
    

    ASSIGN 
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
  
        WHEN 'testv'
        THEN 
            ASSIGN 
                lc-link-label = "Back"
                lc-submit-label = "Test Email Template".
  
    END CASE.


    ASSIGN 
        lc-title = 'Test Email Template'
        lc-link-url = appurl + '/sys/iemailtmp.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&time=' + string(TIME)
        .


    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
        NO-LOCK NO-ERROR.
    IF NOT AVAILABLE b-table THEN
    DO:
        set-user-field("mode",lc-mode).
        set-user-field("title",lc-title).
        set-user-field("nexturl",appurl + "/sys/iemailtmp.p").
        RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
        RETURN.
    END.



    IF request_method = "POST" THEN
    DO:
    
        ASSIGN 
            lc-issue     = get-value("issue")
            .
        
           
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).
    
        IF lc-error-msg = "" THEN
        DO:
            RUN lib/translatetemplate.p 
                (
                lc-global-company,
                b-table.tmpCode,
                issue.issueNumber,
                YES,
                b-table.tmptxt,
                OUTPUT lc-convtxt,
                OUTPUT lc-error-msg
                ).
         

           
            
        END.
 
        
    END.
    ELSE
    DO:

        FIND LAST issue WHERE issue.companyCode = lc-global-company
            AND issue.AssignTo = lc-user NO-LOCK NO-ERROR.
        IF NOT AVAILABLE issue THEN
            FIND LAST issue WHERE issue.companyCode = lc-global-company
                NO-LOCK NO-ERROR.


        IF AVAILABLE issue
            THEN lc-issue = STRING(issue.IssueNumber).
    END.


    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
    ASSIGN 
        lc-tmpcode = STRING(b-table.tmpcode)
        lc-descr   = b-table.descr
        lc-tmptxt  = b-table.tmptxt.


    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/sys/iemailtest.p' )
           htmlib-ProgramTitle(lc-title) skip.

    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip
           htmlib-Hidden ("nullfield", lc-navigation) skip.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    {&out} htmlib-StartInputTable() skip.



    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("tmpcode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Template Code")
        ELSE htmlib-SideLabel("Template Code"))
    '</TD>' skip
    .

    {&out} htmlib-TableField(html-encode(lc-tmpcode),'left')
           skip.


    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("descr",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Description")
        ELSE htmlib-SideLabel("Description"))
    '</TD>'
    htmlib-TableField(html-encode(lc-descr),'left')
            SKIP
            '</TR>'.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("tmptxt",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Template Text")
        ELSE htmlib-SideLabel("Template Text"))
    '</TD>'
    htmlib-TableField(REPLACE(lc-tmptxt,'~n','<br />'),'left')
    '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("issue",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Test Issue Number")
        ELSE htmlib-SideLabel("Test Issue Number"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("issue",15,lc-issue) 
    '</TD></tr>' skip.

    IF request_method = "POST" THEN
    DO:
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        htmlib-SideLabel("Merged Template")
        '</TD>'
        htmlib-TableField(REPLACE(lc-convtxt,'~n','<br />'),'left')
        '</TR>' skip.

    END.

    {&out} htmlib-EndTable() skip.


    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.

    IF lc-submit-label <> "" THEN
    DO:
        {&out} '<center>' htmlib-SubmitButton("submitform",lc-submit-label) 
        '</center>' skip.
    END.
         
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

