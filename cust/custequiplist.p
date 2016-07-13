/***********************************************************************

    Program:        cust/custequip.p
    
    Purpose:        Customer Maintenance - Equipment Browse        
    
    Notes:
    
    
    When        Who         What
    22/04/2006  phoski      Initial
    
    03/09/2010  DJS         3704 - Customer Details Tab alteration
    20/02/2016  PHOSKI      Include manager/team/ref etc
    23/02/2016  phoski      isDecom flag  
    02/07/2016  phoski      Show ticket balance 
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-mess  AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-customer    AS CHARACTER NO-UNDO.


DEFINE BUFFER b-ivClass  FOR ivClass.
DEFINE BUFFER b-query    FOR CustIv.
DEFINE BUFFER b-search   FOR CustIv.

DEFINE BUFFER b-customer FOR customer.     /* 3704 */ 
DEFINE BUFFER b-custIv   FOR custIv.       /* 3704 */ 
DEFINE BUFFER b-ivSub    FOR ivSub.        /* 3704 */ 


DEFINE QUERY q FOR b-query SCROLLING.

DEFINE VARIABLE lc-object        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-subobject     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ajaxSubWindow AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-expand        AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-htmlreturn    AS CHARACTER NO-UNDO.                 /* 3704 */ 
DEFINE VARIABLE ll-htmltrue      AS LOG       NO-UNDO.                 /* 3704 */ 
DEFINE VARIABLE lc-temp          AS CHARACTER NO-UNDO.                 /* 3704 */ 
DEFINE VARIABLE rdpIP            AS CHARACTER NO-UNDO.                 /* 3704 */            
DEFINE VARIABLE rdpUser          AS CHARACTER NO-UNDO.                 /* 3704 */ 
DEFINE VARIABLE rdpPWord         AS CHARACTER NO-UNDO.                 /* 3704 */            
DEFINE VARIABLE rdpDomain        AS CHARACTER NO-UNDO.                 /* 3704 */ 
DEFINE VARIABLE first-RDP        AS LOG       INITIAL TRUE NO-UNDO.    /* 3704 */ 
DEFINE VARIABLE lc-tempAddress   AS CHARACTER NO-UNDO.                 /* 3704 */
DEFINE VARIABLE lc-Enc-Key       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-inv-key       AS CHARACTER NO-UNDO.



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

&IF DEFINED(EXCLUDE-ip-AccountHeader) = 0 &THEN

PROCEDURE ip-AccountHeader :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       New in 3704 
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER p-postcode AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER p-name     AS CHARACTER NO-UNDO.


    {&out}
    '<div class="toolbar"> <span style="margin-left:2px;">'
        '<a href="javascript:void(0)"onclick="goGMAP(~''
        + replace(p-postcode," ","+")                  
        + '~',~''                                               
        + replace(REPLACE(TRIM(p-name)," ","+"),"&","")
        + '~',~''                                               
        + replace(REPLACE(lc-tempAddress,"~n","+"),"&","")                                              
        + '~')">'
    '<img border="0" src="/images/toolbar3/Gmap.gif" alt="View map" class="tbarimg"></a>'
    '<a href="javascript:void(0)"onclick="goRDP()">'
    '<img border="0" src="/images/toolbar3/winrdp.gif" alt="Connect to customer" class="tbarimg"></a>'
    '</span></div>'
        .

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-AccountInformation) = 0 &THEN

PROCEDURE ip-AccountInformation :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-companycode      AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-AccountNumber    AS CHARACTER     NO-UNDO.
    
    DEFINE BUFFER b-query  FOR Customer.
    DEFINE BUFFER b-webu   FOR WebUser.
    

    DEFINE VARIABLE lc-address      AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lc-temp         AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lc-cam          AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lc-AMan         AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lc-def-cont     AS CHARACTER     NO-UNDO.
    
   


    FIND b-query
        WHERE b-query.CompanyCode   = pc-CompanyCode
        AND b-query.AccountNumber = pc-AccountNumber NO-LOCK NO-ERROR.
    IF NOT AVAILABLE b-query THEN RETURN.
   

    FIND FIRST WebissCont 
         WHERE WebissCont.CompanyCode = b-query.companyCode
           AND WebissCont.Customer  = b-query.AccountNumber
           AND WebissCont.defcon = TRUE
           NO-LOCK NO-ERROR.
    IF AVAILABLE WebissCont
    THEN lc-def-cont = WebissCont.ContractCode.
    ELSE lc-def-cont = "<b>** None **</b>".
    
    ASSIGN
        lc-address = ""
        lc-cam = ""
        lc-AMan = "".
        
    FIND b-webu WHERE b-webu.LoginID = b-query.AccountManager NO-LOCK NO-ERROR.
    IF AVAILABLE b-webu
    THEN lc-AMan = b-webu.Name.
        

    lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,b-query.Address1).
    lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,b-query.Address2).
    lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,b-query.City).
    lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,b-query.County).
    lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,b-query.Country).
    lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,b-query.PostCode).

    ASSIGN 
        lc-tempAddress = lc-address.                                     /* 3704 */ 
                                                                            
    RUN ip-AccountHeader(b-query.postcode, b-query.name).                   /* 3704 */ 

    {&out} skip
           replace(htmlib-StartMntTable(),'XXwidth="100%"','width="95%" align="center"').

    {&out}
    htmlib-TableHeading(
        "Account^left|Name^left|Address^left|Contact|Telephone|Support Team|Account<br>Manager|Account<br>Ref|Default<br>Contract|Notes")
            skip.
            

    {&out}
    '<tr>' skip
        htmlib-MntTableField(html-encode(b-query.AccountNumber),'left')
        htmlib-MntTableField(html-encode(b-query.name),'left').

    /*     if b-query.PostCode = "" then                                                                                       */
    {&out}
    htmlib-MntTableField(REPLACE(html-encode(lc-address),"~n","<br>"),'left').
 
    {&out}
    htmlib-MntTableField(html-encode(b-query.Contact),'left')
    htmlib-MntTableField(html-encode(b-query.Telephone),'left').
    FIND steam WHERE steam.companyCode = b-query.CompanyCode
    AND steam.st-num = b-query.st-num NO-LOCK NO-ERROR.
    {&out} htmlib-MntTableField(IF AVAILABLE steam THEN STRING(steam.st-num) + " - " + steam.descr ELSE 'None','left').

    {&out}
    htmlib-MntTableField(html-encode(lc-AMan),'left')
    htmlib-MntTableField(html-encode(b-query.accountRef),'left')
    htmlib-MntTableField(lc-def-cont,'left').
    
    IF b-query.notes = ""
        THEN {&out} htmlib-MntTableField("",'left').
    else {&out} replace(htmlib-TableField(replace(html-encode(b-query.notes),"~n",'<br>'),'left'),
                '<td','<th style="color: red;') skip.
    {&out}
     
    '</tr>' skip.

       



    {&out} skip 
           htmlib-EndTable()
           
           skip.

     IF  b-query.SupportTicket <> "none" THEN
     {&out}      
        '<div class="infobox" style="xxfont-size: 15px;">'
        "Ticketed Customer Balance: "
             DYNAMIC-FUNCTION("com-TimeToString",com-GetTicketBalance(lc-global-company,pc-accountnumber))
            '</div>' skip. 
    
    
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-AccountUsers) = 0 &THEN

PROCEDURE ip-AccountUsers :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-companycode      AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-AccountNumber    AS CHARACTER     NO-UNDO.
    
    DEFINE BUFFER b-query  FOR webUser.
    DEFINE VARIABLE lc-nopass   AS CHARACTER NO-UNDO.


    IF NOT CAN-FIND(FIRST b-query
        WHERE b-query.CompanyCode   = pc-CompanyCode
        AND b-query.AccountNumber = pc-AccountNumber NO-LOCK) 
        THEN RETURN.
   
    {&out} skip
           htmlib-StartFieldSet("Customer Users") 
           htmlib-StartMntTable().

    {&out}
    htmlib-TableHeading(
        "User Name^left|Name^left|Email^left|Telephone|Mobile|Track?|Disabled?"
        ) skip.


    FOR EACH b-query NO-LOCK
        WHERE b-query.CompanyCode   = pc-CompanyCode
        AND b-query.AccountNumber = pc-AccountNumber
        :
    
   
        ASSIGN 
            lc-nopass = IF b-query.passwd = ""
                           OR b-query.passwd = ?
                           THEN " (No password)"
                           ELSE "".
        
        {&out}
        '<tr>' skip
            htmlib-MntTableField(html-encode(b-query.loginid),'left')
            htmlib-MntTableField(html-encode(b-query.name),'left')
            htmlib-MntTableField(html-encode(b-query.email),'left')
            htmlib-MntTableField(html-encode(b-query.Telephone),'left')
            htmlib-MntTableField(html-encode(b-query.Mobile),'left')
            htmlib-MntTableField(html-encode(if b-query.CustomerTrack = true
                                          then 'Yes' else 'No'),'left')
            htmlib-MntTableField(html-encode((if b-query.disabled = true
                                          then 'Yes' else 'No') + lc-nopass),'left')

        .
            
        {&out}
            
        '</tr>' skip.

       
            
    END.


    {&out} skip 
           htmlib-EndTable()
           htmlib-EndFieldSet() 
           skip.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-SetRDP-M) = 0 &THEN

PROCEDURE ip-SetRDP-M :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       New in 3704 
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER p-recid AS RECID NO-UNDO.
    DEFINE OUTPUT PARAMETER p-html         AS CHARACTER INITIAL "~',~'~',~'"  NO-UNDO.
    DEFINE OUTPUT PARAMETER  p-ok          AS LOG  INITIAL FALSE NO-UNDO.
    DEFINE VARIABLE ou                      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE ip                      AS CHARACTER NO-UNDO.

    FIND b-custIv WHERE RECID(b-custIv) = p-recid NO-LOCK NO-ERROR.
    FIND FIRST b-ivSub OF b-custIv NO-LOCK NO-ERROR.
  
    FIND FIRST ivField OF b-ivSub
        WHERE ivField.ivFieldID = 73932 NO-LOCK NO-ERROR.

    FIND FIRST CustField
        WHERE CustField.CustIvID = b-custIv.CustIvId
        AND CustField.ivFieldId = ivField.ivFieldId
        NO-LOCK NO-ERROR.

    IF AVAILABLE CustField THEN 
    DO:
        ASSIGN
            ip = TRIM(CustField.FieldData)
            ou = substr(ip,1,INDEX(ip,"."))
            ip = substr(ip,INDEX(ip,".") + 1)
            ou = ou + substr(ip,1,INDEX(ip,"."))
            ip = substr(ip,INDEX(ip,".") + 1)
            ou = ou + substr(ip,1,INDEX(ip,"."))
            ip = substr(ip,INDEX(ip,".") + 1)
            ou =  ou + TRIM(substr(ip,1,3), "~/,.;:!? ~"~ '[]()abcdefghijklmnopqrstuvwxyz").
        
        IF NUM-ENTRIES(ou,".") <> 4 THEN RETURN.
        ELSE 
        DO:
            ASSIGN 
                rdpIP = TRIM(ou)
                p-ok  = TRUE.
      
            FIND FIRST ivField OF b-ivSub
                WHERE ivField.ivFieldID = 73934 NO-LOCK NO-ERROR.
  
            FIND FIRST CustField
                WHERE CustField.CustIvID = b-custIv.CustIvId
                AND CustField.ivFieldId = ivField.ivFieldId
                NO-LOCK NO-ERROR.
    
            IF AVAILABLE CustField THEN ASSIGN rdpUser = IF TRIM(CustField.FieldData) <> "" THEN TRIM(CustField.FieldData) ELSE " ".
                                     
            FIND FIRST ivField OF b-ivSub
                WHERE ivField.ivFieldID = 73935 NO-LOCK NO-ERROR.
  
            FIND FIRST CustField
                WHERE CustField.CustIvID = b-custIv.CustIvId
                AND CustField.ivFieldId = ivField.ivFieldId
                NO-LOCK NO-ERROR.
    
            IF AVAILABLE CustField THEN ASSIGN rdpPWord  = IF TRIM(CustField.FieldData) <> "" THEN TRIM(CustField.FieldData) ELSE " ".
                                     
            FIND FIRST ivField OF b-ivSub
                WHERE ivField.ivFieldID = 73933 NO-LOCK NO-ERROR.
  
            FIND FIRST CustField
                WHERE CustField.CustIvID = b-custIv.CustIvId
                AND CustField.ivFieldId = ivField.ivFieldId
                NO-LOCK NO-ERROR.
    
            IF AVAILABLE CustField THEN ASSIGN rdpDomain  = IF TRIM(CustField.FieldData) <> "" THEN TRIM(CustField.FieldData) ELSE " ".
  
            p-html =  rdpIP + '~',~'' + rdpUser + '~',~'' + rdpDomain.

        END.

    END.
 
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-SetRDP-O) = 0 &THEN

PROCEDURE ip-SetRDP-O :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       New in 3704 
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER p-recid AS RECID NO-UNDO.
    DEFINE OUTPUT PARAMETER p-html         AS CHARACTER INITIAL "~',~'~',~'"  NO-UNDO.
    DEFINE OUTPUT PARAMETER p-ok           AS LOG  INITIAL FALSE NO-UNDO.
    DEFINE VARIABLE ou                      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE ip                      AS CHARACTER NO-UNDO.


    FIND b-custIv WHERE RECID(b-custIv) = p-recid NO-LOCK NO-ERROR.
    FIND FIRST b-ivSub OF b-custIv NO-LOCK NO-ERROR.
  
    FIND FIRST ivField OF b-ivSub
        WHERE ivField.ivFieldID = 53 NO-LOCK NO-ERROR.
    /*   where ivField.ivFieldID = 74870 no-lock no-error.  */

    FIND FIRST CustField
        WHERE CustField.CustIvID = b-custIv.CustIvId
        AND CustField.ivFieldId = ivField.ivFieldId
        NO-LOCK NO-ERROR.

    IF AVAILABLE CustField THEN 
    DO:
        ASSIGN
            ip = TRIM(CustField.FieldData)
            ou = substr(ip,1,INDEX(ip,"."))
            ip = substr(ip,INDEX(ip,".") + 1)
            ou = ou + substr(ip,1,INDEX(ip,"."))
            ip = substr(ip,INDEX(ip,".") + 1)
            ou = ou + substr(ip,1,INDEX(ip,"."))
            ip = substr(ip,INDEX(ip,".") + 1)
            ou =  ou + TRIM(substr(ip,1,3), "~/,.;:!? ~"~ '[]()abcdefghijklmnopqrstuvwxyz").
        
        IF NUM-ENTRIES(ou,".") <> 4 THEN RETURN.
        ELSE 
        DO:
            ASSIGN 
                rdpIP = TRIM(ou)
                p-ok  = TRUE. 
      
            FIND FIRST ivField OF b-ivSub
                WHERE ivField.ivFieldID = 54 NO-LOCK NO-ERROR.
  
            FIND FIRST CustField
                WHERE CustField.CustIvID = b-custIv.CustIvId
                AND CustField.ivFieldId = ivField.ivFieldId
                NO-LOCK NO-ERROR.
    
            IF AVAILABLE CustField THEN ASSIGN rdpUser = IF TRIM(CustField.FieldData) <> "" THEN TRIM(CustField.FieldData) ELSE " ".
                                     
            FIND FIRST ivField OF b-ivSub
                WHERE ivField.ivFieldID = 55 NO-LOCK NO-ERROR.
  
            FIND FIRST CustField
                WHERE CustField.CustIvID = b-custIv.CustIvId
                AND CustField.ivFieldId = ivField.ivFieldId
                NO-LOCK NO-ERROR.
    
            IF AVAILABLE CustField THEN ASSIGN rdpPWord  = IF TRIM(CustField.FieldData) <> "" THEN TRIM(CustField.FieldData) ELSE " ".
                                     
            FIND FIRST ivField OF b-ivSub
                WHERE ivField.ivFieldID = 45619 NO-LOCK NO-ERROR.
  
            FIND FIRST CustField
                WHERE CustField.CustIvID = b-custIv.CustIvId
                AND CustField.ivFieldId = ivField.ivFieldId
                NO-LOCK NO-ERROR.
    
            IF AVAILABLE CustField THEN ASSIGN rdpDomain  = IF TRIM(CustField.FieldData) <> "" THEN TRIM(CustField.FieldData) ELSE " ".
  
            p-html =  rdpIP + '~',~'' + rdpUser + '~',~'' + rdpDomain.

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
   
    IF lc-AjaxSubWindow = "yes"
        THEN output-content-type("text/plain~; charset=iso-8859-1":U).
    ELSE output-content-type ("text/html":U).
  
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-process-web-request) = 0 &THEN

PROCEDURE process-web-request :
/*------------------------------------------------------------------------------
  Purpose:     Process the web request.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  
    {lib/checkloggedin.i}

   
    ASSIGN
        lc-customer = get-value("customer")
        lc-ajaxSubWindow = get-value("ajaxsubwindow")
        lc-expand = get-value("expand").
    /*
    ***
    *** 'customer' contains encrypted rowid so decode it
    ***
    */
    
    ASSIGN
        lc-customer = DYNAMIC-FUNCTION("sysec-DecodeValue",lc-user,TODAY,"Customer",lc-customer).
    
    FIND customer
        WHERE ROWID(customer) = to-rowid(lc-customer) NO-LOCK NO-ERROR.
        
    ASSIGN 
        lc-enc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"customer",STRING(ROWID(customer))).
                 

    RUN outputHeader.
    
    IF lc-AjaxSubWindow <> "yes" THEN
    DO:
    
        {&out} htmlib-Header("Customer Inventory List") skip.
    
        {&out} 
        '<script language="JavaScript" src="/scripts/js/tree.js"></script>' skip.
    
        {&out} htmlib-StartForm("mainform","post", appurl + '/cust/custequip.p' ) skip.
        
        {&out} htmlib-ProgramTitle("Customer Inventory List - " + 
            customer.name) skip.
    
        {&out} skip
           htmlib-StartMntTable().
    END.
    ELSE
    DO:
        RUN ip-AccountInformation ( customer.CompanyCode,
            customer.AccountNumber ).
        RUN ip-AccountUsers ( customer.CompanyCode,
            customer.AccountNumber ).
        FIND FIRST b-query OF Customer WHERE b-query.isDecom = FALSE NO-LOCK NO-ERROR.
        IF NOT AVAILABLE b-query THEN RETURN.
        {&out}
        REPLACE(htmlib-StartMntTable(),'width="100%"','width="95%" align="center"').

    END.
    
    {&out}
    htmlib-TableHeading(
        "Select Inventory|"
        ) skip.

    
    {&out}
    '<tr class="tabrow1">'
    '<td valign="top" nowrap class="tree">' skip
    .
    FOR EACH b-query NO-LOCK OF Customer
        WHERE b-query.isDecom = FALSE,
        FIRST ivSub NO-LOCK OF b-query,
        FIRST ivClass NO-LOCK OF ivSub
        BREAK BY ivClass.DisplayPriority DESCENDING
        BY ivClass.Name
        BY ivSub.DisplayPriority DESCENDING
        BY ivSub.name
        BY b-query.Ref:

        
        

        ASSIGN 
            lc-object = "CLASS" + string(ROWID(ivClass))
            lc-subobject = "SUB" + string(ROWID(ivSub)).
        IF FIRST-OF(ivClass.name) THEN
        DO:
            IF lc-expand = "yes" 
                THEN {&out} '<img src="/images/general/menuopen.gif" onClick="hdexpandcontent(this, ~''
            lc-object '~')">'
            '&nbsp;' '<span style="' ivClass.Style '">' html-encode(ivClass.name) '</span><br>'
            '<div id="' lc-object '" style="padding-left: 15px; display: block;">' skip.
            else {&out}
                '<img src="/images/general/menuclosed.gif" onClick="hdexpandcontent(this, ~''
                        lc-object '~')">'
                '&nbsp;' '<span style="' ivClass.Style '">' html-encode(ivClass.name) '</span><br>'
                '<div id="' lc-object '" style="padding-left: 15px; display: none;">' skip.
        END.

        IF FIRST-OF(ivSub.name) THEN
        DO:
            IF lc-expand = "yes"
                THEN {&out} 
            '<img src="/images/general/menuopen.gif" onClick="hdexpandcontent(this, ~''
            lc-subobject '~')">'
            '&nbsp;'
            '<span style="' ivSub.Style '">'
            html-encode(ivSub.name) '</span><br>' skip
                '<div id="' lc-subobject '" style="padding-left: 15px; display: block;">' skip.
                
            else {&out} 
                '<img src="/images/general/menuclosed.gif" onClick="hdexpandcontent(this, ~''
                        lc-subobject '~')">'
                '&nbsp;'
                '<span style="' ivSub.Style '">'
                html-encode(ivSub.name) '</span><br>' skip
                '<div id="' lc-subobject '" style="padding-left: 15px; display: none;">' skip.
        END.
       
        /* -------------------------------------------------------------------------- 3704 STARTS */ 
 

        ll-htmltrue = FALSE.
        
        {&out} '<a '.

        IF b-query.ivSubID = 52 THEN
        DO:
            RUN ip-SetRDP-O( RECID(b-query),
                OUTPUT lc-htmlreturn,
                OUTPUT ll-htmltrue).
        END.
        ELSE
            IF b-query.ivSubID = 73928 THEN
            DO:
                RUN ip-SetRDP-M( RECID(b-query),
                    OUTPUT lc-htmlreturn,
                    OUTPUT ll-htmltrue).
            END.
          
        IF ll-htmltrue THEN {&out} ' onclick="javascript:newRDP(~'' + lc-htmlreturn + '~')"  '.
          
        ASSIGN 
            lc-inv-key = DYNAMIC-FUNCTION("sysec-EncodeValue","Inventory",TODAY,"Inventory",STRING(ROWID(b-query))).
        
        
        {&out} 'href="'
        "javascript:ahah('" 
        appurl "/cust/custequiptable.p?rowid=" url-encode(lc-inv-key,"Query") "&customer=" url-encode(lc-enc-key,"Query")
        "&sec=" url-encode(lc-global-secure,"Query")
        "','inventory');".

        {&out}
        '">' html-encode(b-query.ref) '</a><br>' skip.

        IF first-RDP THEN
        DO:
            IF ll-htmltrue THEN
            DO:
                ASSIGN 
                    first-RDP = FALSE.
                {&out} '<div id="ScriptDiv" style="visibility:hidden; position:absolute; top:-1px; left:-1px " ></div>'.
                {&out} '<div id="ScriptSet" style="visibility:hidden; position:absolute; top:-1px; left:-1px " > ~n'
                '<script defer > ~n'
                '<!-- hide script from old browsers ~n'
                '   newRDP(~'' + lc-htmlreturn + '~'); ~n'
                ' --> ~n'
                '</script></div>~n'.
            END.
        END.


        /* -------------------------------------------------------------------------- 3704  end */ 

        IF LAST-OF(ivSub.name) THEN
        DO:
            {&out} '</div>' skip.
            
             
        END.


        IF LAST-OF(ivClass.name) THEN
        DO:
            {&out} '</div>' skip.
            
        END.

        
            
    END.

    {&out} '</td>' skip.
                
    {&out} '<td valign="top" rowspan="100" ><div id="inventory">&nbsp;</div></td>'.
    {&out} '</tr>' skip.


    {&out} skip 
           htmlib-EndTable()
           skip.
    /* -------------------------------------------------------------------------- 3704 */ 
    IF  first-RDP THEN
    DO:
        {&out} '<div id="ScriptSet" style="visibility:hidden; position:absolute; top:-1px; left:-1px " > ~n'
        '<script defer > ~n'
        '<!-- hide script from old browsers   ~n'
        '   function goRDP() ~{ ~n'
        '     alert("No connection information found"); ~n'
        '   ~}   ~n'
        ' --> ~n'
        '</script></div>~n'.
    END.    
    
    /* -------------------------------------------------------------------------- 3704 */ 
    IF lc-AjaxSubWindow <> "yes" THEN
    DO:
        {&out} skip
               htmlib-Hidden("customer",lc-customer) skip
               skip.
    
        {&out} htmlib-EndForm().
    


        {&OUT} htmlib-Footer() skip.

    
    END.

END PROCEDURE.


&ENDIF

