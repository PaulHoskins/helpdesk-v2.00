/***********************************************************************

    Program:        mail/mail.p
    
    Purpose:        Main Received
    
    Notes:
    
    
    When        Who         What
    16/07/2006  phoski      Initial 
    24/07/2014  phoski      Team
    21/03/2016  phoski      Document Link Encrypt
    
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-mess  AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-print  AS CHARACTER NO-UNDO.

DEFINE VARIABLE li-max-lines   AS INTEGER   INITIAL 12 NO-UNDO.
DEFINE VARIABLE lc-doc-key     AS CHARACTER NO-UNDO.



DEFINE BUFFER b-query  FOR EmailH.
DEFINE BUFFER b-search FOR EmailH.
DEFINE BUFFER doch     FOR Doch.


  
DEFINE QUERY q FOR b-query SCROLLING.


DEFINE VARIABLE lc-info         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-object       AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-tag-end      AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-dummy-return AS CHARACTER INITIAL "MYXXX111PPP2222" NO-UNDO.
DEFINE VARIABLE lc-Customer     AS CHARACTER NO-UNDO.

&GlOBAL-DEFINE object-class INTERNAL-ONLY




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

    {&out}
    '<script>' skip
        'function DeleteEmail(row) ~{' skip
            'if (!confirm("Delete this email?"))' skip 
            'return' skip
            'var FName = "submitsource"' skip
            'document.mainform.elements[FName].value = "DeleteEmail"' skip
            'FName = "deleterow"' skip
            'document.mainform.elements[FName].value = row' skip
            'document.mainform.submit()' skip
           '~}' skip
        '</script>' skip.

    
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

    DEFINE VARIABLE ll-steam AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE ll-show AS LOGICAL      NO-UNDO.
    
    
    {lib/checkloggedin.i}

    IF get-value("submitsource") = "DeleteEmail" THEN
    DO:
        FIND emailh WHERE ROWID(emailh) = to-rowid(get-value("deleterow")) EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE emailh THEN
        DO:
            FOR EACH doch EXCLUSIVE-LOCK
                WHERE doch.CompanyCode = lc-global-company
                AND doch.RelType     = "EMAIL"
                AND doch.RelKey      = string(emailh.EmailID):
                FOR EACH docl OF doch EXCLUSIVE-LOCK:
                    DELETE docl.
                END.
                DELETE doch.
            END.
            DELETE emailh.
        END.
    END.
    RUN outputHeader.
    
    
    {&out} htmlib-Header("HelpDesk Emails") skip.

    RUN ip-ExportJScript.

    {&out} htmlib-JScript-Maintenance() skip.

    {&out} htmlib-StartForm("mainform","post", appurl + '/mail/mail.p' ) skip.

    {&out} htmlib-ProgramTitle("HelpDesk Emails") 
    htmlib-hidden("submitsource","") skip
           htmlib-hidden("deleterow","") skip.
  
    {&out}
    tbar-Begin(
        ""
        )
    tbar-BeginOption()
    tbar-Link("emailissue",?,"off","")
    tbar-Link("emailsave",?,"off","")
    tbar-Link("emaildelete",?,"off","")
 
    tbar-EndOption()
    tbar-End().

    {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="97%"') skip
           htmlib-TableHeading(
            "Customer^left|Date^left|Subject|Attachments"
            ) skip.
 
    ll-Steam =
        DYNAMIC-FUNCTION("com-isTeamMember", lc-global-company,lc-global-user,?).
     
    OPEN QUERY q FOR EACH b-query NO-LOCK
        WHERE b-query.CompanyCode = lc-global-company
        AND b-query.Email > ""
        .
          

    GET FIRST q NO-LOCK.
    
    REPEAT WHILE AVAILABLE b-query:
        ASSIGN 
            lc-rowid = STRING(ROWID(b-query)).
        ASSIGN
            lc-message = b-query.Mtext.

        ASSIGN 
            lc-customer = ""
            ll-show = TRUE.

        IF b-query.AccountNumber <> "" THEN
        DO:
            FIND Customer WHERE Customer.CompanyCode = lc-global-company
                AND Customer.AccountNumber = b-query.AccountNumber
                NO-LOCK NO-ERROR.
            IF ll-steam THEN
            DO:
                IF Customer.st-num = 0 
                    THEN ASSIGN ll-show = FALSE.
                ELSE
                    IF NOT CAN-FIND(FIRST webUsteam WHERE webusteam.loginid = lc-global-user
                        AND webusteam.st-num = customer.st-num NO-LOCK) 
            
                        THEN ll-show = FALSE.
            
            END.    
            IF AVAILABLE Customer
                THEN ASSIGN lc-customer = customer.AccountNumber + " " +
                                      customer.name.
        END.
        
        IF ll-show THEN
        DO:
            
            {&out}
            skip
            tbar-tr(rowid(b-query))
            skip
            htmlib-MntTableField(html-encode(lc-customer),'left')
            htmlib-MntTableField(string(b-query.RcpDate,'99/99/9999') 
                                ,'left').

        
            IF lc-message <> ""
                AND lc-message <> b-query.subject THEN
            DO:
        
                ASSIGN 
                    lc-info = 
                REPLACE(htmlib-MntTableField(html-encode(b-query.subject),'left'),'</td>','')
                    lc-object = "hdobj" + string(b-query.emailid).
    
           
                ASSIGN 
                    li-tag-end = INDEX(lc-info,">").

                {&out} substr(lc-info,1,li-tag-end).

                ASSIGN 
                    substr(lc-info,1,li-tag-end) = "".
            
                {&out} 
                '<img class="expandboxi" src="/images/general/plus.gif" onClick="hdexpandcontent(this, ~''
                lc-object '~')">':U skip.
                {&out} lc-info.
    
                DEFINE VARIABLE lc-work AS CHARACTER NO-UNDO.

            
                lc-work = htmlib-ExpandBox(lc-object,lc-message).

                lc-work = REPLACE(lc-work,"Status : Error",
                    "<span style='color: red; font-size: 12px;'>" + 
                    "STATUS : ERROR</span>").
                {&out} lc-work.

                {&out} '</td>' skip.
            END.
            ELSE {&out} htmlib-MntTableField(html-encode(b-query.subject),"left").
 
        
            ASSIGN 
                li-Attach = 0.

            FIND FIRST doch 
                WHERE doch.CompanyCode = b-query.CompanyCode
                AND doch.RelType     = "EMAIL"
                AND doch.RelKey      = string(b-query.EmailID)
                NO-LOCK NO-ERROR.
            IF NOT AVAILABLE doch 
                THEN {&out} htmlib-MntTableField("&nbsp;","left").
            else
            do:
                {&out} SKIP(4)
                '<td nowrap>'.
        
                FOR EACH doch 
                    WHERE doch.CompanyCode = b-query.CompanyCode
                    AND doch.RelType     = "EMAIL"
                    AND doch.RelKey      = string(b-query.EmailID)
                    NO-LOCK:
        
                    ASSIGN 
                        li-Attach = li-Attach + 1.
        
                    ASSIGN 
                        lc-doc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"Document",STRING(ROWID(doch))).
            
                    {&out}
                    '<a class="tlink" style="border:none; width: 100%;" href="'
                        'javascript:OpenNewWindow('
                        + '~'' + appurl 
                        + '/sys/docview.p?docid=' + url-encode(lc-doc-key,"Query")
                        + '~'' 
                        + ');'
                    '">'
                    doch.descr 
                    '</a><br>'.
                END.
        
                {&out} '</td>' SKIP(4).
    
            END.
            {&out} skip
                    tbar-BeginHidden(rowid(b-query))
                    tbar-Link("emailissue",rowid(b-query),
                              appurl + '/' + "iss/addissue.p",
                              "emailid=" + string(b-query.EmailID) + "&issuesource=email"
                              )
                    tbar-Link("emailsave",rowid(b-query),
                              if li-Attach > 0 then
                              appurl + '/' + "mail/mailsave.p" else "off",
                              ""
                              )
                    tbar-Link("emaildelete",rowid(b-query),
                              'javascript:DeleteEmail('
                              + '~'' + string(rowid(b-query))
                              + '~'' 
                              + ');'
                              ,"")
        .
    
            
            {&out}
                    
                tbar-EndHidden()
                skip
               '</tr>' skip.
    
        END.
       

        GET NEXT q NO-LOCK.
                
    END.
    
    {&out} skip 
               htmlib-EndTable()
               skip.
    
       
    {&out} htmlib-EndForm().
    
        
    {&OUT} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

