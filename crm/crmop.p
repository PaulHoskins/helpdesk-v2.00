/***********************************************************************

    Program:        crm/crmop.p
    
    Purpose:        CRM Opportunity Maintanenace
    
    Notes:
    
    
    When        Who         What
    06/08/2016  phoski      Initial
   
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


DEFINE VARIABLE lc-error-field  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg    AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-mode         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-crmAccount   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lr-customer     AS ROWID     NO-UNDO.


DEFINE VARIABLE lc-title        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-Enc-Key      AS CHARACTER NO-UNDO.  

DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-descr        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-SalesManager AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sm-code      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sm-desc      AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-SalesContact AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-cu-code      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-cu-desc      AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-department   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-nextStep     AS CHARACTER NO-UNDO.


DEFINE BUFFER b-valid  FOR op_master.
DEFINE BUFFER b-table  FOR op_master.
DEFINE BUFFER Customer FOR Customer.


{src/web2/wrap-cgi.i}
{lib/htmlib.i}



RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

PROCEDURE ip-UpdatePage:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    {&out} htmlib-StartTable("mnt",
        100,
        0,
        0,
        0,
        "center").
        
    {&out} '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">' 
        ( IF LOOKUP("descr",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Description")
        ELSE htmlib-SideLabel("Descripion"))
    '</TD>' skip
            '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("descr",40,lc-descr) skip
           '</TD></tr>'.
           
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("SalesManager",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Sales Manager")
        ELSE htmlib-SideLabel("Sales Manager"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
    htmlib-Select("salesmanager",lc-sm-Code,lc-sm-desc,lc-SalesManager)
    '</TD></TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Sales Contact")
    '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="1">'
    htmlib-Select("salescontact",lc-cu-Code,lc-cu-desc,lc-salescontact)
    '</TD></TR>' skip.
    
    {&out} '<TR align="left"><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("department",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Department")
        ELSE htmlib-SideLabel("Department"))
    '</TD>' skip
            '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("department",40,lc-department) skip
           '</TD></tr>'.
                          
    {&out} '<TR align="left"><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("nextstep",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("nextstep")
        ELSE htmlib-SideLabel("nextstep"))
    '</TD>' skip
            '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("nextstep",40,lc-nextstep) skip
           '</TD></tr>'.
                                 
         
    {&out} htmlib-EndTable() skip.
  

END PROCEDURE.

PROCEDURE ip-Validate:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg    AS CHARACTER NO-UNDO.

    IF lc-descr = ""
        OR lc-descr = ?
        THEN RUN htmlib-AddErrorMessage(
            'name', 
            'You must enter the description',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
 

END PROCEDURE.

PROCEDURE outputHeader:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    output-content-type ("text/html":U).


END PROCEDURE.

PROCEDURE process-web-request:
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/
    {lib/checkloggedin.i}
    
    ASSIGN 
        lc-mode = get-value("mode")
        lc-rowid = get-value("rowid")
        lc-enc-key = get-value("crmaccount").
    .
    
    ASSIGN
        lc-CRMAccount = DYNAMIC-FUNCTION("sysec-DecodeValue",lc-user,TODAY,"Customer",lc-enc-key).
        
    ASSIGN 
        lr-customer = TO-ROWID(lc-crmAccount).
        
        
    FIND Customer WHERE ROWID(Customer) = lr-customer NO-LOCK.
    
    RUN com-GetUserListByClass ( lc-global-company, "INTERNAL", REPLACE(lc-global-SalType-Code,'|',",") ,OUTPUT lc-sm-code, OUTPUT lc-sm-desc).
    
    
    ASSIGN
        lc-sm-code = "|" + lc-sm-code
        lc-sm-desc = "None Selected|" + lc-sm-desc
        .
        
    RUN com-GetUserListForAccount (lc-global-company,customer.AccountNumber,OUTPUT lc-cu-code, OUTPUT lc-cu-desc).
    IF lc-cu-code = ""
        THEN ASSIGN lc-cu-code = lc-global-selcode
            lc-cu-desc = "None".
    
    ELSE 
        ASSIGN
            lc-cu-code = lc-global-selcode + "|" + lc-cu-code
            lc-cu-desc = "None|" + lc-cu-desc.
            
            
            
    CASE lc-mode:
        WHEN 'add'
        THEN 
            ASSIGN 
                lc-title = 'Add'
                lc-link-label = "Cancel addition"
                lc-submit-label = "Add Opportunity".
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
                lc-submit-label = 'Delete Opportunity'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Opportunity'.
    END CASE.
    
    ASSIGN 
        lc-enc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-user,TODAY,"customer",STRING(ROWID(customer))).
        
                 
    ASSIGN 
        lc-title = lc-title + ' Opportunity'
        lc-link-url = appurl + '/crm/customer.p' + 
                                  '?crmaccount=' + url-encode(lc-enc-key,"Query") +
                                  '&navigation=refresh&mode=CRM' +
                                  '&time=' + string(TIME).
                                  
              
    ASSIGN
        lc-title = "Account: " + Customer.Name + " - " + lc-title.
                                      
    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            IF lc-mode = 'update' THEN
            DO:
                FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
                    NO-LOCK NO-ERROR.
            END.
            
            ASSIGN
                lc-descr             = get-value("descr")
                lc-SalesManager      = get-value("salesmanager")
                lc-SalesContact      = get-value("salescontact")
                lc-department        = get-value("department")
                lc-nextstep          = get-value("nextstep")
                  
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
                        b-table.accountnumber = Customer.AccountNumber
                        b-table.CompanyCode   = lc-global-company
                        b-table.op_id         = NEXT-VALUE(op_master)
                        b-table.createDate    = NOW
                        b-table.createLoginid = lc-global-user
                        lc-firstrow      = STRING(ROWID(b-table)).
                   
                END.
                ASSIGN
                    b-table.descr           = lc-descr
                    b-table.SalesManager    = lc-SalesManager
                    b-table.salesContact    = lc-SalesContact
                    b-table.Department      = lc-department
                    b-table.NextStep        = lc-nextstep
                    .
                    
                IF b-table.salesContact = lc-global-selcode
                    THEN b-table.salesContact = "".
            
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
            /*RUN outputHeader.*/
            set-user-field("navigation",'refresh').
            set-user-field("firstrow",lc-firstrow).
            set-user-field("search",lc-search).
            set-user-field("mode","CRM").
            set-user-field("crmaccount" , get-value("crmaccount")).
            request_method = "GET".
            RUN run-web-object IN web-utilities-hdl ("crm/customer.p").
            RETURN.
        END.
        
    END.
    
    IF lc-mode <> 'add' AND request_method = "GET" THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        
        ASSIGN
            lc-descr = b-table.descr
            lc-SalesManager = b-table.SalesManager
            lc-SalesContact = b-table.Salescontact
            lc-department   = b-table.department
            lc-nextstep     = b-table.nextstep
            .
            
       
    END.  
                                        
    RUN outputHeader.
    
    
    {&out} htmlib-Header("Opportunity CRM") skip.
 
   
    
    {&out} htmlib-StartForm("mainform","post", appurl + '/crm/crmop.p' ) SKIP
           htmlib-ProgramTitle(lc-title) skip.
    
     
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.


    IF lc-mode = "ADD"
        OR lc-mode = "UPDATE" THEN
    DO:
        RUN ip-UpdatePage.
    END.
    
    {&out} htmlib-Hidden ("mode", lc-mode) skip
           htmlib-Hidden ("rowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) SKIP
           htmlib-hidden ("crmaccount", get-value("crmaccount"))
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip.
           
    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.

    IF lc-submit-label <> "" THEN
    DO:
        {&out} '<br><center>' htmlib-SubmitButton("submitform",lc-submit-label) 
        '</center>' skip.
    END.


    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
              
END PROCEDURE.
