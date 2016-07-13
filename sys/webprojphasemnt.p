/***********************************************************************

    Program:        sys/webprojphasemnt.p
    
    Purpose:        Project Template Phase Maintenance     
    
    Notes:
    
    
    When        Who         What
    27/03/2015  phoski      Initial
    
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


DEFINE BUFFER b-valid FOR ptp_phase.
DEFINE BUFFER b-table FOR ptp_phase.


DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-field        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-groupid      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-description  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-projcode     AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop         AS INTEGER   NO-UNDO.




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
            'You must enter the description',
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
    DEFINE BUFFER this-proj     FOR ptp_proj.
     
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
                lc-submit-label = "Add Phase".
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
                lc-submit-label = 'Delete Phase'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Phase'.
    END CASE.

    FIND this-proj WHERE this-proj.CompanyCode = lc-global-company
        AND this-proj.projCode = lc-projCode
        NO-LOCK NO-ERROR.
                     

    ASSIGN 
        lc-title = lc-title + ' Project Phase -<i> ' + lc-ProjCode + " " + this-proj.descr + '</i>'
        lc-link-url = appurl + '/sys/webprojphase.p' + 
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
            set-user-field("nexturl",appurl + "/sys/webprojphase.p").
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
                AND b-valid.projCode = b-table.ProjCode
                AND b-valid.DisplayOrder < b-table.displayOrder
                USE-INDEX displayOrder EXCLUSIVE-LOCK NO-ERROR.
                                     
        END.    
        ELSE
        DO:
            FIND FIRST b-valid 
                WHERE b-valid.companyCode = b-table.CompanyCode
                AND b-valid.projCode = b-table.ProjCode
                AND b-valid.DisplayOrder > b-table.displayOrder
                USE-INDEX displayOrder EXCLUSIVE-LOCK NO-ERROR.
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
        RUN run-web-object IN web-utilities-hdl ("sys/webprojphase.p").
        RETURN.
                
    END.
    

    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-description  = get-value("description")
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
                        AND b-valid.projcode = lc-projcode
                        USE-INDEX displayOrder
                        NO-LOCK NO-ERROR.
                    CREATE b-table.
                    ASSIGN 
                        b-table.ProjCode = lc-ProjCode
                        b-table.Phaseid =  NEXT-VALUE(projphase) 
                        b-table.companycode = lc-global-company
                        b-table.displayOrder = IF AVAILABLE b-valid THEN b-valid.displayOrder + 1 ELSE 1
                        lc-firstrow      = STRING(ROWID(b-table))
                        .
                    
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.Descr     = lc-description
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
                    AND b-valid.projcode = lc-projcode
                    USE-INDEX displayOrder
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
            RUN run-web-object IN web-utilities-hdl ("sys/webprojphase.p").
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
                lc-description   = b-table.descr.
                    
           
        END.
       
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/sys/webprojphasemnt.p' )
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
        (IF LOOKUP("description",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Description")
        ELSE htmlib-SideLabel("Description"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("description",40,lc-description) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-description),'left')
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
        {&out} '<center>' htmlib-SubmitButton("submitform",lc-submit-label) 
        '</center>' skip.
    END.
         
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

