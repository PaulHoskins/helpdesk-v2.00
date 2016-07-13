/***********************************************************************

    Program:        cust/custassetmnt.p
    
    Purpose:        Customer Asset 
    
    Notes:
    
    
    When        Who         What
    27/04/2014  phoski      Initial
    
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


DEFINE BUFFER customer FOR customer.
DEFINE BUFFER b-valid  FOR CustAst.
DEFINE BUFFER b-table  FOR CustAst.


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

DEFINE VARIABLE lc-list-code    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-desc    AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-AssetID      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-aType        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-aManu        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Model        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-serial       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-location     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-aStatus      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Purchased    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-cost         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-descr        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-details      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Enc-Key      AS CHARACTER NO-UNDO.



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
 
    {&out} htmlib-JScript-Maintenance() skip.
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

    DEFINE VARIABLE lc-object       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lc-value        AS CHARACTER     NO-UNDO.
   
    DEFINE VARIABLE ld-date         AS DATE     NO-UNDO.
    DEFINE VARIABLE lf-number       AS DECIMAL      NO-UNDO.

    
    
    
    IF lc-AssetID = ""
        OR lc-AssetID = ?
        THEN RUN htmlib-AddErrorMessage(
            'assetid', 
            'You must enter the asset id',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF lc-mode = "ADD" 
        AND CAN-FIND( b-table 
        WHERE  b-table.accountnumber = customer.accountnumber
        AND b-table.CompanyCode   = customer.CompanyCode
        AND b-table.AssetID = lc-AssetID NO-LOCK ) 
        THEN RUN htmlib-AddErrorMessage(
            'assetid', 
            'You asset already exists',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
 
    IF lc-descr = ""
        OR lc-descr = ?
        THEN RUN htmlib-AddErrorMessage(
            'descr', 
            'You must enter the asset description',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

 
    IF lc-purchased <> "" THEN
    DO:
        ld-date = DATE(lc-purchased) NO-ERROR.
        IF ld-date = ? THEN
            RUN htmlib-AddErrorMessage(
                'purchased', 
                'The purchase date is invalid',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).

    END.
   
    IF lc-cost <> "" THEN
    DO:
        lf-number = Dec(lc-cost) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN
            RUN htmlib-AddErrorMessage(
                'cost', 
                'The cost is invalid',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).

    END.

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
        lc-mode = get-value("mode")
        lc-rowid = get-value("rowid")
        lc-search = get-value("search")
        lc-firstrow = get-value("firstrow")
        lc-lastrow  = get-value("lastrow")
        lc-navigation = get-value("navigation")
        lc-customer   = get-value("customer")
        lc-returnback = get-value("returnback").

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
                lc-submit-label = "Add Asset".
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
                lc-submit-label = 'Delete Asset'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Asset'.
    END CASE.


    FIND customer WHERE ROWID(customer) = to-rowid(lc-customer)
        NO-LOCK NO-ERROR.
     
   
       
    ASSIGN 
        lc-enc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"customer",STRING(ROWID(customer))).
                 
    ASSIGN 
        lc-title = lc-title + ' Customer Asset'
        lc-link-url = appurl + '/cust/custasset.p' + 
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
            set-user-field("nexturl",appurl + "/cust/custasset.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.
        
        ASSIGN 
            lc-AssetID = b-table.AssetID.

        IF request_method = "GET"
            OR lc-mode = "VIEW" THEN 
        DO:
            ASSIGN 
                lc-aType = b-table.aType
                lc-aManu = b-table.aManu
                lc-model = b-table.model
                lc-serial = b-table.serial
                lc-location = b-table.location
                lc-aStatus = b-table.aStatus
                lc-Purchased = IF b-table.Purchased = ? THEN ""
                    ELSE STRING(b-table.Purchased,"99/99/9999")
                lc-cost     =   STRING(b-table.cost,">>>>>>>>>9.99-")
                lc-descr    =   b-table.descr
                lc-details  =   b-table.details


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
                THEN ASSIGN lc-AssetID          = CAPS(get-value("assetid")).
        
            ASSIGN
                lc-aType    =   get-value("atype")
                lc-amanu    =   get-value("amanu")
                lc-model    =   get-value("model")
                lc-serial   =   GET-VALUE("serial")
                lc-location =   get-value("location")
                lc-aStatus  =   get-value("astatus")
                lc-purchased =  get-value("purchased")
                lc-cost     =   get-value("cost")
                lc-descr    =   get-value("descr")
                lc-details  =   get-value("details")

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
                        b-table.AssetID      = lc-AssetID
                        lc-firstrow           = STRING(ROWID(b-table)).
                    
                   
                END.
                
                /* Update here */
        
        
                ASSIGN
                    b-table.atype   = lc-atype
                    b-table.amanu   = lc-amanu
                    b-table.model   = lc-model
                    b-table.serial  = lc-serial
                    b-table.location = lc-location
                    b-table.astatus = lc-astatus
                    b-table.purchased = IF lc-purchased = "" THEN ? 
                                        ELSE DATE(lc-purchased)
                    b-table.cost       = DEC(lc-cost)
                    b-table.descr      = lc-descr
                    b-table.details     = lc-details


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
            IF lc-returnback = "customerview" THEN
            DO:
                set-user-field("source","menu").
                set-user-field("rowid",lc-enc-key).
                set-user-field("showtab","asset").
                RUN run-web-object IN web-utilities-hdl ("cust/custview.p").
                RETURN.
            END.
        
            set-user-field("navigation",'refresh').
            set-user-field("firstrow",lc-firstrow).
            set-user-field("search",lc-search).
            RUN run-web-object IN web-utilities-hdl ("cust/custasset.p").
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
                lc-AssetID      = b-table.AssetID
                .
            
        END.
       
    END.
    ELSE
    DO:
        
    END.


    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip.
    RUN ip-JavaScript.


    {&out}
    htmlib-StartForm("mainform","post", selfurl )
    htmlib-ProgramTitle(lc-title) skip.

    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    {&out} htmlib-StartInputTable() skip.

    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("assetid",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Asset ID")
        ELSE htmlib-SideLabel("Asset ID"))
    '</TD>' .
    
    IF CAN-DO("ADD",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("assetid",20,lc-AssetID) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-AssetID),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("descr",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Description")
        ELSE htmlib-SideLabel("Description"))
    '</TD>' .
    
    IF CAN-DO("add,update",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("descr",60,lc-descr) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-descr),'left')
           skip.
    {&out} '</TR>' skip.

    RUN com-GenTabSelect ( customer.CompanyCode, "Asset.Type", 
        OUTPUT lc-list-code,
        OUTPUT lc-list-desc ).

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("atype",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Type")
        ELSE htmlib-SideLabel("Type"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">' SKIP.

    
    IF CAN-DO("ADD,UPDATE",lc-mode)
        THEN {&out} htmlib-Select("atype",lc-list-code,lc-list-desc,
        lc-atype) skip.
    else {&out} html-encode(lc-atype) "&nbsp" 
        html-encode(
            DYNAMIC-FUNCTION("com-GenTabDesc",
                         customer.CompanyCode, "Asset.Type", 
                         lc-atype)

            ).

    {&out} '</TD></TR>' skip. 

    RUN com-GenTabSelect ( customer.CompanyCode, "Asset.Manu", 
        OUTPUT lc-list-code,
        OUTPUT lc-list-desc ).

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("amanu",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Manufacturer")
        ELSE htmlib-SideLabel("Manufacturer"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">' SKIP.


    IF CAN-DO("ADD,UPDATE",lc-mode)
        THEN {&out} htmlib-Select("amanu",lc-list-code,lc-list-desc,
        lc-amanu) skip.
    else {&out} html-encode(lc-amanu) "&nbsp" 
         html-encode(
             DYNAMIC-FUNCTION("com-GenTabDesc",
                          customer.CompanyCode, "Asset.Manu", 
                          lc-amanu)

             ).

    {&out} '</TD></TR>' skip. 

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("model",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Model")
        ELSE htmlib-SideLabel("Model"))
    '</TD>' .
    
    IF CAN-DO("add,update",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("model",20,lc-model) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-model),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("serial",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Serial")
        ELSE htmlib-SideLabel("Serial"))
    '</TD>' .
    
    IF CAN-DO("add,update",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("serial",20,lc-serial) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-serial),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("location",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Location")
        ELSE htmlib-SideLabel("Location"))
    '</TD>' .
    
    IF CAN-DO("add,update",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("location",20,lc-location) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-location),'left')
           skip.
    {&out} '</TR>' skip.

    RUN com-GenTabSelect ( customer.CompanyCode, "Asset.Status", 
        OUTPUT lc-list-code,
        OUTPUT lc-list-desc ).

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("astatus",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Status")
        ELSE htmlib-SideLabel("Status"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">' SKIP.

    
    IF CAN-DO("ADD,UPDATE",lc-mode)
        THEN {&out} htmlib-Select("astatus",lc-list-code,lc-list-desc,
        lc-astatus) skip.
    else {&out} html-encode(lc-astatus) "&nbsp" 
        html-encode(
            DYNAMIC-FUNCTION("com-GenTabDesc",
                         customer.CompanyCode, "Asset.Status", 
                         lc-astatus)

            ).

    {&out} '</TD></TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("purchased",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Purchase Date")
        ELSE htmlib-SideLabel("Purchase Date"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">'.
    
    IF CAN-DO("ADD,UPDATE",lc-mode)
        THEN {&out}
    /*
        htmlib-InputField("purchased",10,lc-purchased) 
     htmlib-CalendarLink("purchased") */
    htmlib-CalendarInputField("purchased",10,lc-purchased) 
    htmlib-CalendarLink("purchased")

    '</TD>' skip.
    ELSE
    {&out} htmlib-TableField(html-encode(lc-purchased),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("cost",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Cost")
        ELSE htmlib-SideLabel("Cost"))
    '</TD>' .
    
    IF CAN-DO("add,update",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("cost",15,lc-cost) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-cost),'left')
           skip.
    {&out} '</TR>' skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("longdescription",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Details")
        ELSE htmlib-SideLabel("Details"))
    '</TD>' SKIP.


    IF CAN-DO("add,update",lc-mode) THEN
        {&out} 
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-TextArea("details",lc-details,5,60)
    '</TD>' skip
           skip.
     ELSE
    {&out} htmlib-TableField(replace(html-encode(lc-details),"~n","<br>"),'left')
           skip.


  
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
    IF CAN-DO("ADD,UPDATE",lc-mode) THEN
    DO:     
        {&out} htmlib-CalendarScript("purchased") skip.
    END.
    
    {&out} skip
           htmlib-Hidden("customer",lc-customer) skip
           htmlib-Hidden("returnback",lc-returnback) skip
           htmlib-hidden("submitsource","") skip.
   
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

