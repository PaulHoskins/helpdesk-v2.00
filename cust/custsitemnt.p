/***********************************************************************

    Program:        cust/custsitemnt.p
    
    Purpose:        Customer Asset 
    
    Notes:
    
    
    When        Who         What
    27/04/2014  phoski      Initial
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg    AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-mode         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-customer     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-returnback   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submitsource AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-site         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-address1     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-address2     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-city         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-county       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-country      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Postcode     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-contact      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-telephone    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-notes        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Enc-Key      AS CHARACTER NO-UNDO.


DEFINE BUFFER customer FOR customer.
DEFINE BUFFER b-valid  FOR CustSite.
DEFINE BUFFER b-table  FOR CustSite.


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

&IF DEFINED(EXCLUDE-ip-HeaderInclude-Calendar) = 0 &THEN

PROCEDURE ip-HeaderInclude-Calendar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-JavaScript) = 0 &THEN

PROCEDURE ip-JavaScript :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
 
    {&out} htmlib-JScript-Maintenance() SKIP.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      objtargets:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.

    DEFINE VARIABLE lc-object AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-value  AS CHARACTER NO-UNDO.
   
    DEFINE VARIABLE ld-date   AS DATE      NO-UNDO.
    DEFINE VARIABLE lf-number AS DECIMAL   NO-UNDO.

    
    
    
    IF lc-site = ""
        OR lc-site = ?
        THEN RUN htmlib-AddErrorMessage(
            'site', 
            'You must enter the site code',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF lc-mode = "ADD" 
        AND CAN-FIND( b-table 
        WHERE  b-table.accountnumber = customer.accountnumber
        AND b-table.CompanyCode   = customer.CompanyCode
        AND b-table.site = lc-site NO-LOCK ) 
        THEN RUN htmlib-AddErrorMessage(
            'site', 
            'This site already exists',
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
        lc-mode       = get-value("mode")
        lc-rowid      = get-value("rowid")
        lc-search     = get-value("search")
        lc-firstrow   = get-value("firstrow")
        lc-lastrow    = get-value("lastrow")
        lc-navigation = get-value("navigation")
        lc-customer   = get-value("customer")
        lc-returnback = get-value("returnback").

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
        WHEN 'add'
        THEN 
            ASSIGN 
                lc-title        = 'Add'
                lc-link-label   = "Cancel addition"
                lc-submit-label = "Add Site".
        WHEN 'view'
        THEN 
            ASSIGN 
                lc-title        = 'View'
                lc-link-label   = "Back"
                lc-submit-label = "".
        WHEN 'delete'
        THEN 
            ASSIGN 
                lc-title        = 'Delete'
                lc-link-label   = 'Cancel deletion'
                lc-submit-label = 'Delete Site'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title        = 'Update'
                lc-link-label   = 'Cancel update'
                lc-submit-label = 'Update Site'.
    END CASE.


    FIND customer WHERE ROWID(customer) = to-rowid(lc-customer)
        NO-LOCK NO-ERROR.
     
   
       
    ASSIGN 
        lc-enc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"customer",STRING(ROWID(customer))).
                 
    ASSIGN 
        lc-title    = lc-title + ' Customer Site'
        lc-link-url = appurl + '/cust/custsite.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&customer=' + lc-customer +
                                  '&returnback=' + lc-returnback +
                                  '&' + htmlib-RandomURL()
        .

    IF lc-returnback = "renewal"
        THEN ASSIGN lc-link-url = appurl + "/cust/ivrenewal.p".
    ELSE 
        IF lc-returnback = "customerview" 
            THEN ASSIGN lc-link-url = appurl + "/cust/custview.p?source=menu&rowid=" + 
        url-encode(lc-enc-key,"Query") + "&showtab=ASSET".
 

    IF CAN-DO("view,update,delete",lc-mode) THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE b-table THEN
        DO:
            set-user-field("mode",lc-mode).
            set-user-field("title",lc-title).
            set-user-field("nexturl",appurl + "/cust/custsite.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.
        
        ASSIGN 
            lc-site = b-table.site.

        IF request_method = "GET"
            OR lc-mode = "VIEW" THEN 
        DO:
            ASSIGN 
                lc-address1  = b-table.address1
                lc-address2  = b-table.address2
                lc-city      = b-table.city
                lc-county    = b-table.county
                lc-country   = b-table.country
                lc-postcode  = b-table.postcode
                lc-contact   = b-table.contact
                lc-telephone = b-table.telephone
                lc-notes     = b-table.notes


                .
        END.
    END.


    IF request_method = "POST" THEN
    DO:
        ASSIGN
            lc-submitsource = get-value("submitsource").
       
        
        IF lc-mode <> "delete" THEN
        DO:
            IF lc-mode = "ADD"
                THEN ASSIGN lc-site = CAPS(get-value("site")).
        
            ASSIGN
                lc-address1  = get-value("address1")
                lc-address2  = get-value("address2")
                lc-city      = get-value("city")
                lc-county    = GET-VALUE("county")
                lc-country   = get-value("country")
                lc-postcode  = get-value("postcode")
                lc-contact   = get-value("contact")
                lc-telephone = get-value("telephone")
                lc-notes     = get-value("notes")

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
                    CREATE b-table.
                    ASSIGN 
                        b-table.accountnumber = customer.accountnumber
                        b-table.CompanyCode   = customer.CompanyCode
                        b-table.site          = lc-site
                        lc-firstrow           = STRING(ROWID(b-table)).
                    
                   
                END.
                       
                ASSIGN
                    b-table.address1  = lc-address1
                    b-table.address2  = lc-address2
                    b-table.city      = lc-city
                    b-table.county    = lc-county
                    b-table.country   = lc-country
                    b-table.postcode  = CAPS(lc-postcode)
                    b-table.contact   = lc-contact 
                    b-table.telephone = lc-telephone
                    b-table.notes     = lc-notes
                    .
                
                 
        
                
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
            END.
        END.
        
        IF lc-error-field = "" THEN
        DO:
                  
            set-user-field("navigation",'refresh').
            set-user-field("firstrow",lc-firstrow).
            set-user-field("search",lc-search).
            RUN run-web-object IN web-utilities-hdl ("cust/custsite.p").
            RETURN.
        END.
        
      

        
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        
        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post" THEN 
        DO:
            ASSIGN 
                lc-site = b-table.site
                .
            
        END.
       
    END.
    ELSE
    DO:
        
    END.


    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) SKIP.
    RUN ip-JavaScript.


    {&out}
        htmlib-StartForm("mainform","post", selfurl )
        htmlib-ProgramTitle(lc-title) SKIP.

    {&out} htmlib-Hidden ("savemode", lc-mode) SKIP
        htmlib-Hidden ("saverowid", lc-rowid) SKIP
        htmlib-Hidden ("savesearch", lc-search) SKIP
        htmlib-Hidden ("savefirstrow", lc-firstrow) SKIP
        htmlib-Hidden ("savelastrow", lc-lastrow) SKIP
        htmlib-Hidden ("savenavigation", lc-navigation) SKIP.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' SKIP.

    {&out} htmlib-StartInputTable() SKIP.

    
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("site",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Site Code")
        ELSE htmlib-SideLabel("Site Code"))
        '</TD>' .
    
    IF CAN-DO("ADD",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-InputField("site",10,lc-site) 
            '</TD>' SKIP.
    ELSE 
        {&out} htmlib-TableField(html-encode(lc-site),'left')
            SKIP.
    {&out} 
        '</TR>' SKIP.

    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("address1",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Address 1")
        ELSE htmlib-SideLabel("Address 1"))
        '</TD>'
        '<TD VALIGN="TOP" ALIGN="left">' SKIP.

    
    IF CAN-DO("ADD,UPDATE",lc-mode)
        THEN {&out}  htmlib-InputField("address1",80,lc-Address1) 
            SKIP.
    ELSE {&out} html-encode(lc-address1) .

    {&out} 
        '</TD></TR>' SKIP. 

    
    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("address2",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Address 2")
        ELSE htmlib-SideLabel("Address 2"))
        '</TD>'
        '<TD VALIGN="TOP" ALIGN="left">' SKIP.



    IF CAN-DO("ADD,UPDATE",lc-mode)
        THEN {&out}  htmlib-InputField("address2",80,lc-Address2) 
            SKIP.
    ELSE {&out} html-encode(lc-address2) .

    {&out} 
        '</TD></TR>' SKIP. 

    {&out} 
        '</TD></TR>' SKIP. 

    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("city",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("City")
        ELSE htmlib-SideLabel("City"))
        '</TD>' .
    
    IF CAN-DO("add,update",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-InputField("city",80,lc-city) 
            '</TD>' SKIP.
    ELSE 
        {&out} htmlib-TableField(html-encode(lc-city),'left')
            SKIP.
    {&out} 
        '</TR>' SKIP.

    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("county",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("County")
        ELSE htmlib-SideLabel("County"))
        '</TD>' .
    
    IF CAN-DO("add,update",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-InputField("county",80,lc-county) 
            '</TD>' SKIP.
    ELSE 
        {&out} htmlib-TableField(html-encode(lc-county),'left')
            SKIP.
    {&out} 
        '</TR>' SKIP.

    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("country",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Country")
        ELSE htmlib-SideLabel("Country"))
        '</TD>' .
    
    IF CAN-DO("add,update",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-InputField("country",80,lc-country) 
            '</TD>' SKIP.
    ELSE 
        {&out} htmlib-TableField(html-encode(lc-country),'left')
            SKIP.
    {&out} 
        '</TR>' SKIP.

    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("postcode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("PostCode")
        ELSE htmlib-SideLabel("Postcode"))
        '</TD>'
        SKIP.

    
    IF CAN-DO("add,update",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-InputField("postcode",10,lc-postcode) 
            '</TD>' SKIP.
    ELSE 
        {&out} htmlib-TableField(html-encode(lc-postcode),'left')
            SKIP.

    {&out} 
        '</TD></TR>' SKIP.

    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("contact",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Contact")
        ELSE htmlib-SideLabel("Contact"))
        '</TD>'
        .
    
    IF CAN-DO("add,update",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-InputField("contact",40,lc-contact) 
            '</TD>' SKIP.
    ELSE 
        {&out} htmlib-TableField(html-encode(lc-contact),'left')
            SKIP.
            
    {&out} 
        '</TR>' SKIP.

    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("telephone",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Telephone")
        ELSE htmlib-SideLabel("Telephone"))
        '</TD>' .
    
    IF CAN-DO("add,update",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-InputField("telephone",15,lc-telephone) 
            '</TD>' SKIP.
    ELSE 
        {&out} htmlib-TableField(html-encode(lc-telephone),'left')
            SKIP.
    {&out} 
        '</TR>' SKIP.


    {&out} 
        '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("longdescription",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Notes")
        ELSE htmlib-SideLabel("Notes"))
        '</TD>' SKIP.


    IF CAN-DO("add,update",lc-mode) THEN
        {&out} 
            '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-TextArea("notes",lc-notes,5,60)
            '</TD>' SKIP
            SKIP.
    ELSE
        {&out} htmlib-TableField(REPLACE(html-encode(lc-notes),"~n","<br>"),'left')
            SKIP.


  
    {&out} htmlib-EndTable() SKIP.

    IF lc-error-msg <> "" THEN
    DO:
        {&out} 
            '<BR><BR><CENTER>' 
            htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' SKIP.
    END.

    IF lc-submit-label <> "" THEN
    DO:
        {&out} 
            '<center>' htmlib-SubmitButton("submitform",lc-submit-label) 
            '</center>' SKIP.
    END.
    
    
    {&out} SKIP
        htmlib-Hidden("customer",lc-customer) SKIP
        htmlib-Hidden("returnback",lc-returnback) SKIP
        htmlib-hidden("submitsource","") SKIP.
   
    {&out} htmlib-EndForm() SKIP
        htmlib-Footer() SKIP.
    
  
END PROCEDURE.


&ENDIF

