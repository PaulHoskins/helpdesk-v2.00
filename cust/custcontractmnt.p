/***********************************************************************

    Program:        cust/custcontractmnt.p
    
    Purpose:        Customer Asset 
    
    Notes:
    
    
    When        Who         What
    27/04/2014  phoski      Initial
    06/11/2015  phoski      Show contracts on view
    10/11/2015  phoski      Conract Number
    
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

DEFINE VARIABLE lc-contractCode AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-conno        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-descr        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-default      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-active       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-billable     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-add-Date     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-add-value    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-field-name   AS CHARACTER EXTENT 2 NO-UNDO.
DEFINE VARIABLE lc-temp         AS CHARACTER EXTENT 2 NO-UNDO.
DEFINE VARIABLE lc-Enc-Key      AS CHARACTER NO-UNDO.


DEFINE BUFFER customer     FOR customer.
DEFINE BUFFER ContractType FOR ContractType.
DEFINE BUFFER ContractRate FOR ContractRate.
DEFINE BUFFER b-valid      FOR webIssCont.
DEFINE BUFFER b-table      FOR WebIssCont.




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

PROCEDURE ip-HTM-Header:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-return       AS CHARACTER NO-UNDO.
    
    
    pc-return = '~n<script language="JavaScript" src="/asset/page/custcontractmnt.js?v=1.0.0"></script>~n'.
    

END PROCEDURE.

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

PROCEDURE ip-Page:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
 
    
    IF lc-mode = "ADD" THEN
    DO:
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("contractcode",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Contract Code")
            ELSE htmlib-SideLabel("Contract Code"))
        '</TD>'
        '<TD VALIGN="TOP" ALIGN="left">' SKIP
         '<select id="contractcode" name="contractcode" class="inputfield"  onchange=~"javascript:changeSelectType();~">' SKIP
         '<option value="" selected>Select Code</option>' SKIP.
         
        FOR EACH ContractType NO-LOCK
            WHERE  ContractType.CompanyCode = lc-global-company:
            {&out}
            '<option value="'  ContractType.ContractNumber '">'  ContractType.Description '</option>' SKIP.
            
        END.
         
        {&out} '</select></td></tr>' skip.
          
         
        
    END.
    ELSE
    DO:
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        htmlib-SideLabel("Contract Code")
        '</td><TD VALIGN="TOP" ALIGN="left">' lc-ContractCode  ' - '  DYNAMIC-FUNCTION("com-ContractDescription",b-table.CompanyCode,b-table.ContractCode)'</TD>' SKIP
                 '</TR>' skip.
    
    END.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("descr",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Notes")
        ELSE htmlib-SideLabel("Notes"))
    '</TD>' .
    
    IF CAN-DO("add,update",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("descr",60,lc-descr) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-descr),'left')
           skip.
    {&out} '</TR>' skip.
     {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("descr",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Contract Number")
        ELSE htmlib-SideLabel("Contract Number"))
    '</TD>' .
    
    IF CAN-DO("add,update",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("conno",15,lc-conno) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-conno),'left')
           skip.
    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("default",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Default?")
        ELSE htmlib-SideLabel("Default?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN 
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("default", IF lc-default = 'on' THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else                                                      
    {&out} htmlib-TableField(IF lc-default = "on" THEN "Yes" else "No",'left') 
                skip.                                              
    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("active",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Active?")
        ELSE htmlib-SideLabel("Active?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN 
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("active", IF lc-active = 'on' THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else                                                      
    {&out} htmlib-TableField(IF lc-active = "on" THEN "Yes" else "No",'left') 
                skip.                                              
    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("billable",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Billable?")
        ELSE htmlib-SideLabel("Billable?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN 
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("billable", IF lc-billable = 'on' THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else                                                      
    {&out} htmlib-TableField(IF lc-billable = "on" THEN "Yes" else "No",'left') 
                skip.                                              
    {&out} '</TR>' skip.
    
    
    {&out} '<tr><td colspan=2>' SKIP.
    
    {&out} skip
           htmlib-StartMntTable().

    IF CAN-DO("view,delete",lc-mode) THEN
       
    {&out}
    htmlib-TableHeading(
        "Start Date|Contract Value (PA)"
        ) skip.
    else
    {&out}
    htmlib-TableHeading(
        "Delete?|Start Date|Contract Value (PA)"
        ) skip.
        
        
    IF NOT CAN-DO("view,delete",lc-mode) THEN 
    DO:
        {&out} '<tr><td>Add</td>' SKIP
               '<td>'
                htmlib-CalendarInputField("add-date",10,lc-add-date) 
                htmlib-CalendarLink("add-date")
                '</td><td>'
                htmlib-InputField("add-value",15,lc-add-value) 
                '</td></tr>' SKIP
        .
    END.
    
    IF CAN-DO("view,delete,update",lc-mode) THEN
    DO:
        FOR EACH ContractRate NO-LOCK
            WHERE ContractRate.CompanyCode = b-table.CompanyCode
            AND ContractRate.Customer = b-table.Customer
            AND ContractRate.ContractCode = b-table.ContractCode:
            
            IF CAN-DO("view,delete",lc-mode) THEN
            DO:
                {&out} '<tr>' 
                htmlib-MntTableField(STRING(ContractRate.cBegin,'99/99/9999'),'left') 
                htmlib-MntTableField(STRING(ContractRate.cValue,'zzz,zzz,zz9.99-'),'right')
                '</tr>' SKIP. 
                 
            END.    
            ELSE
            DO:
                ASSIGN 
                    lc-field-name[1] = "DEL" + STRING(ROWID(ContractRate))
                    lc-field-name[2] = "VAL" + STRING(ROWID(ContractRate))
                    lc-temp[1] = get-value(lc-field-name[1]).
                
                IF request_method = "GET" 
                THEN ASSIGN lc-temp[2] = TRIM(STRING(ContractRate.cValue,'zzz,zzz,zz9.99-')).
                ELSE ASSIGN lc-temp[2] = get-value(lc-field-name[2]).   
                
                {&out} '<tr><td>'
                htmlib-CheckBox(lc-field-name[1], IF lc-temp[1] = 'on' THEN TRUE ELSE FALSE) 
                '</td>' 
                htmlib-MntTableField(STRING(ContractRate.cBegin,'99/99/9999'),'left') 
               '</td><td>'
                htmlib-InputField(lc-field-name[2],15,lc-temp[2]) 
                '</td>'
                '</tr>' SKIP. 
                
            END.
        
        END.
    END.
    
    
    
    
      
    {&out} skip 
           htmlib-EndTable()
           skip.
               
    
    {&out} '</tr>' SKIP.
    
     
    
    

END PROCEDURE.

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

    IF lc-contractCode = ""
        OR lc-contractCode = ?
        THEN RUN htmlib-AddErrorMessage(
            'ContractCode', 
            'You must select the contract code',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF lc-mode = "ADD" 
        AND CAN-FIND( FIRST b-table 
        WHERE  b-table.Customer = customer.accountnumber
        AND b-table.CompanyCode   = customer.CompanyCode
        AND b-table.ContractCode = lc-contractCode NO-LOCK ) 
        THEN RUN htmlib-AddErrorMessage(
            'ContractCode', 
            'This contract already exists',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    /**
    IF lc-descr = ""
        OR lc-descr = ?
        THEN RUN htmlib-AddErrorMessage(
            'descr', 
            'You must enter the contract notes',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    **/
            
    IF lc-add-date <> ""
        OR lc-add-value <> "" THEN
    DO:
        ld-date = DATE(lc-add-date) NO-ERROR.
        IF ld-date  = ?
            OR ERROR-STATUS:ERROR THEN
            RUN htmlib-AddErrorMessage(
                'add-date', 
                'You must enter the start date',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        IF ld-date <> ?
            AND lc-mode <> "ADD"
            AND CAN-FIND(FIRST ContractRate 
            WHERE ContractRate.CompanyCode = b-table.CompanyCode
            AND ContractRate.Customer = b-table.Customer
            AND ContractRate.ContractCode = b-table.ContractCode 
            AND ContractRate.cBegin = ld-date NO-LOCK)
            THEN RUN htmlib-AddErrorMessage(
                'add-date', 
                'This start date already exists',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
               
        ASSIGN 
            lf-number = dec(lc-add-value) NO-ERROR.
        IF ERROR-STATUS:ERROR 
            OR lf-number < 0
            OR lf-number = ?
            OR lc-add-value = "" 
            THEN RUN htmlib-AddErrorMessage(
                'add-value', 
                'The contract value must be zero or greater',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
                   
             
    END.
           
    IF lc-mode = "UPDATE" THEN
        FOR EACH ContractRate NO-LOCK
            WHERE ContractRate.CompanyCode = b-table.CompanyCode
            AND ContractRate.Customer = b-table.Customer
            AND ContractRate.ContractCode = b-table.ContractCode:
        
            ASSIGN 
                lc-field-name[1] = "DEL" + STRING(ROWID(ContractRate))
                lc-field-name[2] = "VAL" + STRING(ROWID(ContractRate))
                lc-temp[1] = get-value(lc-field-name[1])
                lc-temp[2] = get-value(lc-field-name[2]).   
            
            IF lc-temp[1] = "on" THEN NEXT. /* Going to delete */
            ASSIGN 
                lf-number = dec(lc-temp[2]) NO-ERROR.
            IF ERROR-STATUS:ERROR 
                OR lf-number < 0
                OR lf-number = ?
                OR lc-temp[2] = "" 
                THEN RUN htmlib-AddErrorMessage(
                    'add-value-other', 
                    'The contract value must be zero or greater for date ' + string(ContractRate.cbegin,"99/99/9999"),
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
                lc-submit-label = "Add Contract".
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
                lc-submit-label = 'Delete Contract'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Contract'.
       
                         
    END CASE.


    FIND customer WHERE ROWID(customer) = to-rowid(lc-customer)
        NO-LOCK NO-ERROR.
     
   
       
    ASSIGN 
        lc-enc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"customer",STRING(ROWID(customer))).
                 
    ASSIGN 
        lc-title = lc-title + ' Customer Contract'
        lc-link-url = appurl + '/cust/custcontract.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=initial' + /* Dont reposition!! */
                                  '&customer=' + lc-customer +
                                  '&returnback=' + lc-returnback +
                                  '&' + htmlib-RandomURL()
        .

   

    IF CAN-DO("view,update,delete",lc-mode) THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE b-table THEN
        DO:
            set-user-field("mode",lc-mode).
            set-user-field("title",lc-title).
            set-user-field("nexturl",appurl + "/cust/custcontract.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.
        
        ASSIGN 
            lc-contractCode = b-table.ContractCode.

        IF request_method = "GET"
            OR lc-mode = "VIEW" THEN 
        DO:
            ASSIGN 
                lc-descr    =  b-table.notes
                lc-default  =  IF b-table.DefCon THEN "on" ELSE ""
                lc-active   =  IF b-table.ConActive THEN "on" ELSE ""
                lc-billable  =  IF b-table.Billable THEN "on" ELSE ""
                lc-conno    = b-table.contract_no
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
                THEN ASSIGN lc-contractCode          = CAPS(get-value("ContractCode")).
        
            ASSIGN
                lc-descr        = get-value("descr")
                lc-default      = get-value("default")
                lc-active       = get-value("active")
                lc-billable     = get-value("billable")
                lc-add-date     = get-value("add-date")
                lc-add-value    = get-value("add-value")
                lc-conno        = get-value("conno")
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
                        b-table.customer    = customer.accountnumber
                        b-table.CompanyCode   = customer.CompanyCode
                        b-table.ContractCode  = lc-contractCode
                        lc-firstrow           = STRING(ROWID(b-table)).
                END.
                              
                ASSIGN
                    b-table.notes     = lc-descr
                    b-table.defCon    = lc-default = "on"
                    b-table.ConActive = lc-active = "on"
                    b-table.Billable  = lc-billable = "on"
                    b-table.contract_no = lc-conno
                    lc-contractCode   = b-table.ContractCode
                    
                    .
                IF lc-mode = "UPDATE" THEN
                FOR EACH ContractRate EXCLUSIVE-LOCK
                    WHERE ContractRate.CompanyCode = b-table.CompanyCode
                    AND ContractRate.Customer = b-table.Customer
                    AND ContractRate.ContractCode = b-table.ContractCode:
    
                    ASSIGN 
                        lc-field-name[1] = "DEL" + STRING(ROWID(ContractRate))
                        lc-field-name[2] = "VAL" + STRING(ROWID(ContractRate))
                        lc-temp[1] = get-value(lc-field-name[1])
                        lc-temp[2] = get-value(lc-field-name[2])
                        .   
        
                    IF lc-temp[1] = "on" THEN DO:
                        DELETE ContractRate.
                        NEXT. 
                    END.
                    ASSIGN
                     ContractRate.cValue = DECIMAL(lc-temp[2]).
                END.
            
                IF lc-add-date <> "" THEN
                DO:
                    CREATE ContractRate.
                    BUFFER-COPY b-table TO ContractRate
                        ASSIGN 
                        ContractRate.cBegin = DATE(lc-add-date)
                        ContractRate.cValue = DECIMAL(lc-add-value).
                END.
                    
                
                IF b-table.DefCon THEN
                    FOR EACH b-table EXCLUSIVE-LOCK
                        WHERE b-table.companyCode = Customer.CompanyCode
                        AND b-table.Customer = Customer.AccountNumber
                        AND b-table.ContractCode <> lc-ContractCode:
                        ASSIGN 
                            b-table.defCon = FALSE.
                        
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
                FOR EACH ContractRate EXCLUSIVE-LOCK
                    WHERE ContractRate.CompanyCode = b-table.CompanyCode
                    AND ContractRate.Customer = b-table.Customer
                    AND ContractRate.ContractCode = b-table.ContractCode:
                    DELETE ContractRate.
                END.
                DELETE b-table.    
            END.
        END.
        
        IF lc-error-field = "" THEN
        DO:
                 
            set-user-field("navigation",'refresh').
            set-user-field("firstrow",lc-firstrow).
            set-user-field("search",lc-search).
            RUN run-web-object IN web-utilities-hdl ("cust/custcontract.p").
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
                lc-contractCode      = b-table.ContractCode
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

    
    RUN ip-Page.
    
    

  
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
        {&out} htmlib-CalendarScript("add-date") skip.
    END.
    
    {&out} SKIP
           htmlib-Hidden("customer",lc-customer) skip
           htmlib-Hidden("returnback",lc-returnback) skip
           htmlib-hidden("submitsource","") skip.
   
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

