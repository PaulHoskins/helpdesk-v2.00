/***********************************************************************

    Program:        crm/crmloadedit.p
    
    Purpose:        CRM Data Set Account Edit     
    
    Notes:
    
    
    When        Who         What
    06/09/2016  phoski      Initial      
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mode          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-search        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parent        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-label    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-note          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-status        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-AccountNumber AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-CustRowID     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Enc-Key       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-loginid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop          AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-next          AS CHARACTER NO-UNDO.


DEFINE BUFFER b-valid   FOR crm_data_acc.
DEFINE BUFFER b-table   FOR crm_data_acc.
DEFINE BUFFER b-webuser FOR WebUser.




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


    IF lc-status = lc-global-CRMRS-ACC-CRT THEN
    DO:
        IF lc-accountNumber = "" THEN
        DO:
            RUN htmlib-AddErrorMessage(
                'accountnumber', 
                'You must enter the new account number',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
            RETURN.
        END.
        IF CAN-FIND(Customer WHERE Customer.CompanyCode = lc-global-company
            AND Customer.AccountNumber = lc-AccountNumber NO-LOCK) THEN
        DO:
            RUN htmlib-AddErrorMessage(
                'accountnumber', 
                'This account number aleady exists',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
            RETURN.
            
        END.
                                 
             
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
    
    {lib/checkloggedin.i} 


    
    ASSIGN 
        lc-mode       = get-value("mode")
        lc-rowid      = get-value("rowid")
        lc-parent     = get-value("parent")
        lc-search     = get-value("search")
        lc-firstrow   = get-value("firstrow")
        lc-lastrow    = get-value("lastrow")
        lc-navigation = get-value("navigation").

    IF lc-mode = "" 
        THEN ASSIGN lc-mode       = get-field("savemode")
            lc-rowid      = get-field("saverowid")
            lc-search     = get-value("savesearch")
            lc-firstrow   = get-value("savefirstrow")
            lc-lastrow    = get-value("savelastrow")
            lc-navigation = get-value("savenavigation").

    ASSIGN 
        lc-parameters = "search=" + lc-search +
                           "&firstrow=" + lc-firstrow + 
                           "&lastrow=" + lc-lastrow.

    CASE lc-mode:
       
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title        = 'Update'
                lc-link-label   = 'Cancel update'
                lc-submit-label = 'Update Data'.
    END CASE.


    ASSIGN 
        lc-title    = lc-title + ' Data'
        lc-link-url = appurl + '/crm/crmloadmnt.p' + 
                                  '?search=' + lc-search + 
                                  '&mode=view&rowid=' + lc-parent +
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&time=' + string(TIME)
        .

    IF CAN-DO("view,update,delete",lc-mode) THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE b-table THEN
        DO:
            set-user-field("mode",lc-mode).
            set-user-field("title",lc-title).
            set-user-field("nexturl",appurl + "/crm/crmload.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN                  
                lc-note          = get-value("note")
                lc-status        = get-value("status")
                lc-AccountNumber = get-value("accountnumber").
               
            
             
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
                
                ASSIGN 
                    lc-AccountNumber      = CAPS(lc-accountNumber)
                    b-table.note          = lc-note
                    b-table.record_status = lc-status
                    b-table.AccountNumber = lc-accountNumber
                    .
                    
                IF lc-status = lc-global-CRMRS-ACC-CRT THEN
                DO:
                                 
                    CREATE Customer.
                    ASSIGN 
                        Customer.CompanyCode   = lc-global-company
                        Customer.AccountNumber = lc-AccountNumber
                        Customer.accStatus     = "CRM"
                        Customer.Name          = b-table.name
                        Customer.Address1      = b-table.Address1
                        Customer.Address2      = b-table.Address2
                        Customer.City          = b-table.city
                        Customer.County        = b-table.county
                        Customer.Country       = "UK"
                        Customer.Postcode      = b-table.Postcode
                        Customer.Telephone     = b-table.Telephone
                        Customer.SalesNote     = b-table.note
                        Customer.SalesManager  = IF lc-global-engType BEGINS "SAL" THEN lc-global-user ELSE ""
                        Customer.Contact       = TRIM(b-table.contact_title + " " + b-table.contact_forename + " " + b-table.contact_surname)
                        .
                    ASSIGN 
                        lc-enc-key =
                        DYNAMIC-FUNCTION("sysec-EncodeValue",lc-user,TODAY,"customer",STRING(ROWID(customer))).
                  
                    IF Customer.Contact <> "" THEN
                    DO:
                        ASSIGN 
                            lc-loginid = TRIM(REPLACE(b-table.contact_forename + "." + b-table.contact_surname," ","")).
                        IF CAN-FIND(FIRST b-webuser WHERE b-webuser.loginid = lc-loginid NO-LOCK) THEN
                        REPEAT:
                            li-loop = li-loop + 1.
                            lc-next = lc-loginid + "_" + string(li-loop).
                            IF CAN-FIND(FIRST b-webuser WHERE b-webuser.loginid = lc-next NO-LOCK) THEN NEXT.
                            lc-loginid = lc-next.
                            LEAVE.
                        
                        END.
                    

                        CREATE b-webuser.
                        ASSIGN 
                            b-webuser.loginid = lc-loginid
                            b-webuser.CompanyCode = lc-global-company
                            b-webuser.UserClass = "CUSTOMER"
                            b-webuser.engType  = "custSal"
                           
                            .
                        
                        ASSIGN 
                            b-webuser.forename         = b-table.contact_forename
                            b-webuser.surname          = b-table.contact_surname
                            b-webuser.DefaultUser      = TRUE
                            b-webuser.usertitle        = b-table.contact_title
                            b-webuser.accountnumber    = Customer.AccountNumber
                            b-webuser.jobtitle         = b-table.contact_position
                            b-webuser.telephone        = b-table.Telephone
                            .
                        ASSIGN 
                            b-webuser.name = b-webuser.forename + ' ' + 
                                             b-webuser.surname
                            Customer.SalesContact = b-WebUser.LoginID
                            .
                                          
                                          
                    END.
                    
                    
                END.    
                
            
            END.
        END.
        

        IF lc-error-field = "" THEN
        DO:
            /*RUN outputHeader.*/
            
            IF lc-status = lc-global-CRMRS-ACC-CRT THEN
            DO:
                set-user-field("crmaccount",lc-enc-key).
                set-user-field("mode","CRM").
                set-user-field("source","dataset").
                set-user-field("parent", lc-parent).
                request_method =  "GET".
                RUN run-web-object IN web-utilities-hdl ("crm/customer.p").
                RETURN.
            END.
            
            set-user-field("navigation",'refresh').
            set-user-field("firstrow",lc-firstrow).
            set-user-field("search",lc-search).
            set-user-field("mode","view").
            set-user-field("rowid",lc-parent).
            request_method =  "GET".
            RUN run-web-object IN web-utilities-hdl ("crm/crmloadmnt.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK NO-ERROR.


        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post"
            THEN ASSIGN lc-note          = b-table.note
                lc-status        = b-table.record_status
                lc-accountNumber = b-table.accountnumber.
            .
       
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/crm/crmloadedit.p' )
           htmlib-ProgramTitle(lc-title) skip.

    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) SKIP
           htmlib-hidden ("parent", lc-parent)
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip
           htmlib-Hidden ("nullfield", lc-navigation) skip.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    {&out} htmlib-StartInputTable() skip.


   

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("description",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Note")
        ELSE htmlib-SideLabel("Note"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-TextArea("note",lc-note,10,60)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-note),'left')
           skip.
    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("status",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Status")
        ELSE htmlib-SideLabel("Status"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("status",lc-global-CRMRS-Code,lc-global-CRMRS-desc,
        lc-status)
    '</TD></TR>' skip. 
            
    {&out} '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">' 
        ( IF LOOKUP("accountnumber",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Account Number")
        ELSE htmlib-SideLabel("Account Number"))
    '</TD>' skip
     '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("accountnumber",8,lc-accountnumber) skip
           '</TD></tr>' SKIP.

    {&out} htmlib-EndTable() skip.


    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.

    IF lc-submit-label <> "" THEN
    DO:
        {&out} '<br/><center>' htmlib-SubmitButton("submitform",lc-submit-label) 
        '</center>' skip.
    END.
         
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

