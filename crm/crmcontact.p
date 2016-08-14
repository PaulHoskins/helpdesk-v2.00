/***********************************************************************

    Program:        crm/crmcontact.p
    
    Purpose:        CRM Contact
    
    Notes:
    
    
    When        Who         What
    14/08/2016  phoski      Initial 
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg       AS CHARACTER NO-UNDO.

DEFINE VARIABLE li-curr-year       AS INTEGER   FORMAT "9999" NO-UNDO.
DEFINE VARIABLE li-end-week        AS INTEGER   FORMAT "99" NO-UNDO.
DEFINE VARIABLE ld-curr-hours      AS DECIMAL   FORMAT "99.99" EXTENT 7 NO-UNDO.
DEFINE VARIABLE lc-day             AS CHARACTER INITIAL "Mon,Tue,Wed,Thu,Fri,Sat,Sun" NO-UNDO.

DEFINE VARIABLE lc-mode            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-crmAccount      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lr-customer        AS ROWID     NO-UNDO.
DEFINE VARIABLE lc-enc-key         AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-search          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-label      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-loginid         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-forename        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-surname         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-email           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-usertitle       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-accountnumber   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-jobtitle        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-telephone       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mobile          AS CHARACTER NO-UNDO.




DEFINE VARIABLE lc-html            AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-check           AS LOG       NO-UNDO.
DEFINE VARIABLE li-Count           AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-row             AS INTEGER   INITIAL 3 NO-UNDO.


DEFINE VARIABLE lc-usertitleCode   AS CHARACTER
    INITIAL '' NO-UNDO.
DEFINE VARIABLE lc-usertitleDesc   AS CHARACTER
    INITIAL '' NO-UNDO.



DEFINE BUFFER b-valid   FOR webuser.
DEFINE BUFFER b-table   FOR webuser.
DEFINE BUFFER webuSteam FOR webuSteam.
DEFINE BUFFER steam     FOR steam.

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */



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
{lib/maillib.i}

/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-Page) = 0 &THEN

PROCEDURE ip-Page :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("usertitle",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Title")
        ELSE htmlib-SideLabel("Title"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("usertitle",lc-usertitleCode,lc-usertitleDesc,lc-usertitle) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(
        entry(lookup(lc-usertitle,lc-usertitleCode,'|'),lc-usertitleDesc,'|')
        ),'left')
           skip.
    {&out} '</TR>' skip.



    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("forename",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Forename")
        ELSE htmlib-SideLabel("Forename"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("forename",40,lc-forename) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-forename),'left')
           skip.
    {&out} '</TR>' skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("surname",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Surname")
        ELSE htmlib-SideLabel("Surname"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("surname",40,lc-surname) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-surname),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("jobtitle",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Job Title/Position")
        ELSE htmlib-SideLabel("Job Title/Position"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("jobtitle",20,lc-jobtitle) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-jobtitle),'left')
           skip.
    {&out} '</TR>' skip.
 

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("email",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Email")
        ELSE htmlib-SideLabel("Email"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("email",40,lc-email) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-email),'left')
           skip.
    {&out} '</TR>' skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("telephone",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Telephone")
        ELSE htmlib-SideLabel("Telephone"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("telephone",20,lc-telephone) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-telephone),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("mobile",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Mobile")
        ELSE htmlib-SideLabel("Mobile"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("mobile",20,lc-mobile) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-mobile),'left')
           skip.
    {&out} '</TR>' skip.
       


END PROCEDURE.


&ENDIF


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



    IF lc-forename = ""
        OR lc-forename = ?
        THEN RUN htmlib-AddErrorMessage(
            'forename', 
            'You must enter the forename',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF lc-surname = ""
        OR lc-surname = ?
        THEN RUN htmlib-AddErrorMessage(
            'surname', 
            'You must enter the surname',
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
    
    DEFINE VARIABLE li-loop  AS INTEGER  NO-UNDO.
    DEFINE VARIABLE lc-next  AS CHARACTER NO-UNDO.

    {lib/checkloggedin.i} 


    ASSIGN 
        lc-usertitleCode = htmlib-GetAttr("USER","Titles").

    IF lc-usertitleCode =  "" 
        THEN ASSIGN lc-usertitleCode = 'Mr|Mrs'.

    ASSIGN 
        lc-usertitleDesc = lc-usertitleCode.


    ASSIGN 
        lc-mode = get-value("mode")
        lc-rowid = get-value("rowid")
        lc-search = get-value("search")
        lc-firstrow = get-value("firstrow")
        lc-lastrow  = get-value("lastrow")
        lc-navigation = get-value("navigation")
        li-curr-year  = INTEGER(get-value("submityear"))
        lc-enc-key = get-value("crmaccount").
    .
    
    ASSIGN
        lc-CRMAccount = DYNAMIC-FUNCTION("sysec-DecodeValue",lc-user,TODAY,"Customer",lc-enc-key).
        
    ASSIGN 
        lr-customer = TO-ROWID(lc-crmAccount).
        
        
    FIND Customer WHERE ROWID(Customer) = lr-customer NO-LOCK.
    

    IF li-curr-year = ? OR li-curr-year = 0 THEN li-curr-year = YEAR(TODAY).

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
                           "&lastrow=" + lc-lastrow +
                           "&submityear=" + string(li-curr-year) +
                           "&fstatus=" + get-value("fstatus").

    CASE lc-mode:
        WHEN 'add'
        THEN 
            ASSIGN 
                lc-title = 'Add'
                lc-link-label = "Cancel addition"
                lc-submit-label = "Add Contact".
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
                lc-submit-label = 'Delete Contact'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Contact'.
    END CASE.
 ASSIGN 
        lc-enc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-user,TODAY,"customer",STRING(ROWID(customer))).

    ASSIGN 
        lc-title = lc-title + ' Contact'
        lc-link-url = appurl + '/crm/customer.p' + 
                                  '?crmaccount=' + url-encode(lc-enc-key,"Query") +
                                  '&navigation=refresh&mode=CRM&showtab=contact' +
                                  '&time=' + string(TIME).
        
   
        
    IF CAN-DO("view,update,delete",lc-mode) THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE b-table THEN
        DO:
            set-user-field("mode",lc-mode).
            set-user-field("title",lc-title).
            set-user-field("nexturl",appurl + "/sys/webuser.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:
        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                
                lc-forename        = get-value("forename")
                lc-surname         = get-value("surname")
                lc-email           = get-value("email")
                lc-usertitle       = get-value("usertitle")
                lc-accountnumber   = Customer.accountNumber
                lc-Jobtitle        = get-value("jobtitle")
                lc-telephone       = get-value("telephone")
                lc-mobile          = get-value("mobile")
               
                               
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
                    ASSIGN lc-loginid = TRIM(REPLACE(lc-forename + "." + lc-surname," ","")).
                    IF CAN-FIND(FIRST b-table WHERE b-table.loginid = lc-loginid NO-LOCK) THEN
                    REPEAT:
                        li-loop = li-loop + 1.
                        lc-next = lc-loginid + "_" + string(li-loop).
                        IF CAN-FIND(FIRST b-table WHERE b-table.loginid = lc-next NO-LOCK) THEN NEXT.
                        lc-loginid = lc-next.
                        LEAVE.
                        
                    END.
                        
                    
                    CREATE b-table.
                    ASSIGN 
                        b-table.loginid = lc-loginid
                        b-table.CompanyCode = lc-global-company
                        b-table.UserClass = "CUSTOMER"
                        b-table.engType  = "custSal"
                        lc-firstrow      = STRING(ROWID(b-table))
                        
                        .
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    
                    ASSIGN 
                        b-table.forename         = lc-forename
                        b-table.surname          = lc-surname
                        b-table.email            = lc-email
                        b-table.usertitle        = lc-usertitle
                        b-table.accountnumber    = lc-accountnumber
                        b-table.jobtitle         = lc-jobtitle
                        b-table.telephone        = lc-telephone
                        b-table.mobile           = lc-mobile
                       
                    
                        .
                    ASSIGN 
                        b-table.name = b-table.forename + ' ' + 
                                          b-table.surname.
                                 
                 END.
            END.
        END.
        ELSE
        DO:
            FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
                EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            IF LOCKED b-table 
                THEN RUN htmlib-AddErrorMessage(
                    'none', 
                    'This record is locked by another user',
                    INPUT-OUTPUT lc-error-field,
                    INPUT-OUTPUT lc-error-msg ).
            ELSE 
            DO:
                FOR EACH webusteam OF b-table  EXCLUSIVE-LOCK:
                    
                    DELETE webusteam.
                END.
                DELETE b-table.
            END.
        END.

        IF lc-error-field = "" THEN
        DO:
            /* RUN outputHeader. */
            set-user-field("navigation",'refresh').
            set-user-field("firstrow",lc-firstrow).
            set-user-field("mode","CRM").
            set-user-field("crmaccount" , get-value("crmaccount")).
            set-user-field("showtab" , "contact").
            request_method = "GET".
            RUN run-web-object IN web-utilities-hdl ("crm/customer.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        ASSIGN 
            lc-loginid = b-table.loginid.
        IF request_method = "GET" THEN
        DO:
            FOR EACH dashb NO-LOCK WHERE dashb.CompanyCode = b-table.companyCode:
                lc-html = "dash" + string(ROWID(dashb)). 
                
                IF LOOKUP(dashb.dashCode,b-table.dashbList) > 0
                    THEN set-user-field(lc-html,"on").
            END.
            FOR EACH webUsteam OF b-table NO-LOCK:
                
                lc-html = "steam" + STRING(webusteam.st-num).
                set-user-field(lc-html,"on").

            END.
        END.

        IF CAN-DO("view,delete",lc-mode) 
            OR request_method <> "post" THEN 
        DO:
            ASSIGN 
                lc-surname        = b-table.surname
                lc-email          = b-table.email
                lc-forename       = b-table.forename
                lc-usertitle      = b-table.usertitle
                lc-jobtitle       = b-table.jobtitle
                lc-telephone      = b-table.telephone
                lc-mobile         = b-table.mobile
                            
                .
            
        END.

       
    END.
    

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", selfurl )
           htmlib-ProgramTitle(lc-title) skip.
    

    {&out} '<script language="JavaScript"> var debugThis         = true; </script>' skip.
    {&out} '<script language="JavaScript" src="/scripts/js/validate.js"></script>' skip.


    {&out} htmlib-Hidden ("savemode", lc-mode) SKIP
           htmlib-Hidden ("submityear", string(li-curr-year)) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip
           htmlib-Hidden ("nullfield", lc-navigation) SKIP
           .
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    
    {&out} REPLACE(htmlib-StartInputTable(),"mnt","MainTable") skip.

    

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
         
    {&out}  htmlib-hidden ("crmaccount", get-value("crmaccount")) SKIP.
    
    
    {&out} htmlib-EndForm() skip
          htmlib-Footer() skip.


END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */



