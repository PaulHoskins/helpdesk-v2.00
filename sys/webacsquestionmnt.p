/***********************************************************************

    Program:        sys/webacsquestionmnt.p
    
    Purpose:        Account Survey Maintenance - Question
    
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

DEFINE VARIABLE lc-description  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-projcode     AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop         AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-qtype        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mand         AS CHARACTER NO-UNDO.







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


  

    IF lc-description = ""
        OR lc-description = ?
        THEN RUN htmlib-AddErrorMessage(
            'description', 
            'You must enter the question',
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

    FIND this-surv WHERE this-surv.CompanyCode = lc-global-company
        AND this-surv.acs_code = lc-projCode
        NO-LOCK NO-ERROR.
                     

    ASSIGN 
        lc-title = lc-title + ' Survey Question -<i> ' + lc-ProjCode + " " + this-surv.descr + '</i>'
        lc-link-url = appurl + '/sys/webacsquestion.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&projectcode=' + lc-projCode +
                                  '&time=' + string(TIME)
        .

    
    IF CAN-DO("view,update,delete,recup,recdown",lc-mode) THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE b-table THEN
        DO:
            set-user-field("mode",lc-mode).
            set-user-field("title",lc-title).
            set-user-field("nexturl",appurl + "/sys/webacsquestion.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.
    
    IF CAN-DO("recup,recdown",lc-mode) THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF lc-mode = "recup" THEN
        DO:
            FIND LAST b-valid 
                WHERE b-valid.companyCode = b-table.CompanyCode
                AND b-valid.acs_code = b-table.acs_code
                AND b-valid.DisplayOrder < b-table.displayOrder
                EXCLUSIVE-LOCK NO-ERROR.
                                     
        END.    
        ELSE
        DO:
            FIND FIRST b-valid 
                WHERE b-valid.companyCode = b-table.CompanyCode
                AND b-valid.acs_code = b-table.acs_code
                AND b-valid.DisplayOrder > b-table.displayOrder
                EXCLUSIVE-LOCK NO-ERROR.
        END.
        IF AVAILABLE b-valid THEN
        DO:
            ASSIGN
                li-loop = b-table.displayOrder.
                
            ASSIGN
                b-table.displayOrder = b-valid.DisplayOrder
                b-valid.displayOrder = li-loop.
        END.
        
      
        set-user-field("navigation",'refresh').
 
        set-user-field("projectcode",lc-projCode).
        RUN run-web-object IN web-utilities-hdl ("sys/webacsquestion.p").
        RETURN.
                
    END.
    

    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-description  = get-value("description")
                lc-qtype        = get-value("qtype")
                lc-mand         = get-value("mand")
                .

            
            RUN ip-Validate( OUTPUT lc-error-field,
                OUTPUT lc-error-msg ).

            IF lc-error-msg = "" THEN
            DO:
                
                IF lc-mode = 'update' THEN
                DO:
                    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
                        EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                    IF LOCKED b-table 
                        THEN  RUN htmlib-AddErrorMessage(
                            'none', 
                            'This record is locked by another user',
                            INPUT-OUTPUT lc-error-field,
                            INPUT-OUTPUT lc-error-msg ).
                END.
                ELSE
                DO:
                    FIND LAST b-valid 
                        WHERE b-valid.companyCode = lc-global-company
                        AND b-valid.acs_code = lc-projcode
                        NO-LOCK NO-ERROR.
                    CREATE b-table.
                    ASSIGN 
                        b-table.acs_code = lc-ProjCode
                        b-table.acs_line_id =  NEXT-VALUE(acs_line) 
                        
                        b-table.companycode = lc-global-company
                        b-table.displayOrder = IF AVAILABLE b-valid THEN b-valid.displayOrder + 1 ELSE 1
                        lc-firstrow      = STRING(ROWID(b-table))
                        .
                    
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.qText   = lc-description
                        b-table.qType   = lc-qType
                        b-table.isMandatory = lc-mand = "on"
                        .
                    
                END.
            END.
        END.
        ELSE
        DO:
            FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
                EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            IF LOCKED b-table 
                THEN  RUN htmlib-AddErrorMessage(
                    'none', 
                    'This record is locked by another user',
                    INPUT-OUTPUT lc-error-field,
                    INPUT-OUTPUT lc-error-msg ).
            ELSE 
            DO:
                DELETE b-table.
                li-loop = 0.
                FOR EACH b-valid 
                    WHERE b-valid.companyCode = lc-global-company
                    AND b-valid.acs_code = lc-projcode
                    EXCLUSIVE-LOCK:
                    
                    ASSIGN
                        li-loop = li-loop + 1
                        b-valid.displayOrder = li-loop.
                                         
                END.
                
                        
                
            END.
        END.

        IF lc-error-field = "" THEN
        DO:
            RUN outputHeader.
            set-user-field("navigation",'refresh').
            set-user-field("firstrow",lc-firstrow).
            set-user-field("search",lc-search).
            set-user-field("projectcode",lc-projCode).
            RUN run-web-object IN web-utilities-hdl ("sys/webacsquestion.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
      
        IF CAN-DO("view,delete",lc-mode) OR request_method <> "post"
            THEN 
        DO:
            ASSIGN 
                lc-description   = b-table.qtext
                lc-qtype         = b-table.qtype
                lc-mand          = IF b-table.isMandatory THEN "on" ELSE ""
                .
                    
           
        END.
       
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/sys/webacsquestionmnt.p' )
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
        (IF LOOKUP("qtype",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Question Type")
        ELSE htmlib-SideLabel("Question Type"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
       htmlib-Select("qtype",lc-global-sq-code ,lc-global-sq-desc,lc-qtype)
        '</TD>' skip.
    ELSE
    {&out} htmlib-TableField(html-encode(dynamic-function("com-DecodeLookup",lc-qType,
                                     lc-global-sq-Code,
                                     lc-global-sq-Desc
                                     )),'left')
           skip.
    {&out} '</TR>' skip.
    
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("description",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Question")
        ELSE htmlib-SideLabel("Question"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-TextArea("description",lc-description,4,80) 
    
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-description),'left')
           skip.
    {&out} '</TR>' skip.
    
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("mand",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Mandatory?")
        ELSE htmlib-SideLabel("Mandatory?"))
        '</TD>'.
        
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-checkBox("mand",lc-mand = "on")
    '</TD>' skip.
        else 
        {&out} htmlib-TableField(IF lc-mand = "on" THEN "Yes" ELSE 'No','left')
               skip.
    {&out} '</TR>' skip.
    
    

    
    {&out} htmlib-EndTable() skip.


    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.

    IF lc-submit-label <> "" THEN
    DO:
        {&out} '<br /><center>' htmlib-SubmitButton("submitform",lc-submit-label) 
        '</center>' skip.
    END.
         
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

