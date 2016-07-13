/***********************************************************************

    Program:        mail/mailsave.p
    
    Purpose:        Main Received - Save to Customer
    
    Notes:
    
    
    When        Who         What
    16/07/2006  phoski      Initial 
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-print  AS CHARACTER NO-UNDO.

DEFINE VARIABLE li-max-lines   AS INTEGER   INITIAL 12 NO-UNDO.


DEFINE BUFFER b-query  FOR doch.
DEFINE BUFFER b-search FOR doch.
DEFINE BUFFER doch     FOR Doch.


  
DEFINE QUERY q FOR b-query SCROLLING.

DEFINE VARIABLE lc-tog-name      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-desc-name     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-number   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-name     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-accountnumber AS CHARACTER NO-UNDO.




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

&IF DEFINED(EXCLUDE-ip-ExportJScript) = 0 &THEN

PROCEDURE ip-ExportJScript :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    {&out} skip
            '<script language="JavaScript" src="/scripts/js/hidedisplay.js"></script>' skip.

    
    
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-GetAccountNumbers) = 0 &THEN

PROCEDURE ip-GetAccountNumbers :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-AccountNumber AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name          AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-user FOR WebUser.
    DEFINE BUFFER b-cust FOR Customer.


    ASSIGN 
        pc-AccountNumber = htmlib-Null()
        pc-Name          = "Select Account".


    FOR EACH b-cust NO-LOCK
        WHERE b-cust.CompanyCode = lc-global-company
        BY b-cust.name:

        ASSIGN 
            pc-AccountNumber = pc-AccountNumber + '|' + b-cust.AccountNumber
            pc-Name          = pc-Name + '|' + b-cust.name.

    END.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Save) = 0 &THEN

PROCEDURE ip-Save :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    
    FIND emailh WHERE ROWID(emailh) = to-rowid(lc-rowid) EXCLUSIVE-LOCK.

    FOR EACH doch EXCLUSIVE-LOCK
        WHERE doch.CompanyCode = lc-global-company
        AND doch.RelType     = "EMAIL"
        AND doch.RelKey      = string(emailh.EmailID):

        ASSIGN 
            lc-tog-name = "tog" + string(ROWID(doch))
            lc-desc-name = "desc" + string(ROWID(doch)).

        IF get-value(lc-tog-name) <> "on" THEN 
        DO:
            FOR EACH docl OF doch EXCLUSIVE-LOCK:
                DELETE docl.
            END.
            DELETE doch.
            NEXT.
        END.
            

        ASSIGN
            doch.RelType = "CUSTOMER"
            doch.RelKey  = lc-accountnumber.
        ASSIGN
            doch.Descr   = get-value(lc-desc-name).
        ASSIGN
            doch.CreateBy = lc-global-user.
        
    END.

    DELETE emailh.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.

    DEFINE VARIABLE li-count        AS INTEGER      NO-UNDO.

    IF NOT CAN-FIND(customer WHERE customer.accountnumber 
        = lc-accountnumber 
        AND customer.companycode = lc-global-company
        NO-LOCK) 
        THEN RUN htmlib-AddErrorMessage(
            'accountnumber', 
            'You must select the account',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    FOR EACH doch NO-LOCK
        WHERE doch.CompanyCode = lc-global-company
        AND doch.RelType     = "EMAIL"
        AND doch.RelKey      = string(emailh.EmailID):

        ASSIGN 
            lc-tog-name = "tog" + string(ROWID(doch))
            lc-desc-name = "desc" + string(ROWID(doch)).

        IF get-value(lc-tog-name) <> "on" THEN NEXT.

        IF get-value(lc-desc-name) = "" THEN
        DO:
            RUN htmlib-AddErrorMessage(
                lc-desc-name, 
                'You must enter the description',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).

        END.
        ASSIGN
            li-count = li-count + 1.
    END.

    IF li-count = 0 
        THEN RUN htmlib-AddErrorMessage(
            'accountnumber', 
            'You must select one or more attachments to save',
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
      Notes:       In the event that this Web object is state-aware, this is
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
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE BUFFER Customer FOR Customer.

    DEFINE VARIABLE lc-message  AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE li-Attach   AS INTEGER      NO-UNDO.

    {lib/checkloggedin.i}

    ASSIGN
        lc-rowid = get-value("rowid").

    FIND emailh WHERE ROWID(emailh) = to-rowid(lc-rowid) NO-LOCK NO-ERROR.

    RUN ip-GetAccountNumbers ( OUTPUT lc-list-number,
        OUTPUT lc-list-name ).


    IF emailh.AccountNumber <> "" THEN
    DO:
        FIND customer
            WHERE customer.CompanyCode      = lc-global-company
            AND customer.AccountNumber    = emailh.AccountNumber
            NO-LOCK NO-ERROR.
        IF AVAILABLE customer THEN
        DO:
            ASSIGN
                lc-list-number = customer.AccountNumber
                lc-list-name   = customer.name
                lc-accountnumber = customer.AccountNumber.
        END.
    END.
    
    IF request_method = 'post' THEN
    DO:
        ASSIGN 
            lc-accountnumber = get-value("accountnumber")
            .
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).
        IF lc-error-field = "" THEN
        DO:
            RUN ip-Save.
            ASSIGN 
                request_method = "GET".
            RUN run-web-object IN web-utilities-hdl ("mail/mail.p").
            RETURN.
        END.
              
    
    END.

    RUN outputHeader.
    
    
    {&out} htmlib-Header("HelpDesk Emails - Save To Customer Documents") skip.

    RUN ip-ExportJScript.

    {&out} htmlib-JScript-Maintenance() skip.

    {&out} htmlib-StartForm("mainform","post", appurl + '/mail/mailsave.p' ) skip.

    {&out} htmlib-ProgramTitle("HelpDesk Emails - Save To Customer Documents") 
    htmlib-hidden("submitsource","") skip
    .
  
    {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="97%"') skip
           htmlib-TableHeading(
            "Customer^left|From^left|Subject^left|Date^left"
            ) skip.

    {&out}
    '<tr>'
    htmlib-MntTableField(
        htmlib-Select("accountnumber",lc-list-number,lc-list-name,
        lc-accountnumber)
        ,'left')
    htmlib-MntTableField(html-encode(emailh.Email),'left')
    htmlib-MntTableField(html-encode(emailh.Subject),'left')
    htmlib-MntTableField(STRING(emailh.RcpDate,'99/99/9999') + ' - ' + string(emailh.RcpTime,"hh:mm am"),'left')
        .

    {&out} skip 
           htmlib-EndTable()
           skip.


    {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="97%"') skip
           htmlib-TableHeading(
            "Save?^left|Attachment^left|Description^left"
            ) skip.
 
    OPEN QUERY q FOR EACH b-query NO-LOCK
        WHERE b-query.CompanyCode = lc-global-company
        AND b-query.RelType     = "EMAIL"
        AND b-query.RelKey      = string(emailh.EmailID)
          
        .
          

    GET FIRST q NO-LOCK.
    
    REPEAT WHILE AVAILABLE b-query:
        
        ASSIGN 
            lc-tog-name = "tog" + string(ROWID(b-query))
            lc-desc-name = "desc" + string(ROWID(b-query)).

        IF request_method = "GET"
            THEN set-user-field(lc-desc-name,
                b-query.descr).

        {&out}
            skip
            tbar-tr(rowid(b-query))
            skip
            htmlib-MntTableField(
                htmlib-CheckBox(lc-tog-name,
                    if request_method = "GET"
                    or get-value(lc-tog-name) = "on" then true
                    else false)
                ,'left')
            htmlib-MntTableField(html-encode(b-query.descr),'left')
            htmlib-MntTableField(
                htmlib-InputField
                    (lc-desc-name,60,get-value(lc-desc-name))
                ,'left').

        {&out}
           
        '</tr>' skip.

        GET NEXT q NO-LOCK.
            
    END.

    {&out} skip 
           htmlib-EndTable()
           skip.

    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.

    {&out} '<center>' htmlib-SubmitButton("submitform","Copy") 
    '</center>' skip.

    {&out}
    htmlib-Hidden("rowid",lc-rowid).
   
    {&out} htmlib-EndForm().

    
    {&OUT} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

