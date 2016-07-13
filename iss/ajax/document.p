/***********************************************************************

    Program:        iss/ajax/document.p
    
    Purpose:        Issue Documents       
    
    Notes:
    
    
    When        Who         What
    03/05/2006  phoski      Initial
    21/03/2016  phoski      Document Link Encrypt
    

***********************************************************************/
CREATE WIDGET-POOL.


DEFINE VARIABLE lc-rowid     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-toolbarid AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-toggle    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-doc-key   AS CHARACTER NO-UNDO. 

DEFINE BUFFER b-table FOR issue.
DEFINE BUFFER b-query FOR doch.

DEFINE VARIABLE lc-type AS CHARACTER 
    INITIAL "ISSUE" NO-UNDO.




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
    output-content-type("text/plain~; charset=iso-8859-1":U).
  
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
        lc-rowid = get-value("rowid")
        lc-toolbarid = get-value("toolbarid").
    

    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.

   
    ASSIGN
        lc-toggle = get-value("toggle").

    IF lc-toggle <> "" THEN
    DO:
        FIND b-query
            WHERE b-query.DocID = int(lc-toggle) EXCLUSIVE-LOCK NO-ERROR.

        IF AVAILABLE b-query
            THEN ASSIGN b-query.CustomerView = NOT b-Query.CustomerView.
    END.
    
    RUN outputHeader.
    
    {&out} skip
          replace(htmlib-StartMntTable(),'width="100%"','width="95%" align="center"').

    IF DYNAMIC-FUNCTION("com-isCustomer",b-table.companycode,lc-user) = TRUE
        THEN {&out}
    htmlib-TableHeading(
        "Date|Time|By|Description|Type|Size (KB)^right"
        ) skip.
    else {&out}
           htmlib-TableHeading(
           "Date|Time|By|Description|Customer View?|Type|Size (KB)^right"
           ) skip.

    FOR EACH b-query NO-LOCK
        WHERE b-query.CompanyCode = b-table.CompanyCode
        AND b-query.RelType = "issue"
        AND b-query.RelKey  = string(b-table.IssueNumber):

        IF DYNAMIC-FUNCTION("com-isCustomer",b-table.companycode,lc-user)
            AND b-query.CustomerView = FALSE THEN NEXT.

        ASSIGN 
            lc-doc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"Document",STRING(ROWID(b-query))).
        
        {&out}
        SKIP(1)
        tbar-trID(lc-ToolBarID,ROWID(b-query))
        SKIP(1)
        htmlib-MntTableField(STRING(b-query.CreateDate,"99/99/9999"),'left')
        htmlib-MntTableField(STRING(b-query.CreateTime,"hh:mm am"),'left')
        htmlib-MntTableField(html-encode(DYNAMIC-FUNCTION("com-UserName",b-query.CreateBy)),'left')
        htmlib-MntTableField(b-query.descr,'left').

        IF DYNAMIC-FUNCTION("com-isCustomer",b-table.CompanyCode,lc-user) = FALSE
            THEN {&out} htmlib-MntTableField(IF b-query.CustomerView THEN 'Yes' ELSE 'No','left').

       
        {&out}
        htmlib-MntTableField(b-query.DocType,'left')
        htmlib-MntTableField(STRING(ROUND(b-query.InBytes / 1024,2)),'right')
        tbar-BeginHidden(ROWID(b-query))
      
        tbar-Link("delete",ROWID(b-query),
            'javascript:ConfirmDeleteAttachment(' +
            "ROW" + string(ROWID(b-query)) + ','
            + string(b-query.docid) + ');',
            "")
        tbar-Link("customerview",ROWID(b-query),
            'javascript:CustomerView(' +
            "ROW" + string(ROWID(b-query)) + ','
            + string(b-query.docid) + ');',
            "")
        tbar-Link("documentview",ROWID(b-query),
            'javascript:OpenNewWindow('
            + '~'' + appurl 
            + '/sys/docview.'
            + lc(b-query.DocType) + '?docid=' + url-encode(lc-doc-key,"Query")
            + '~'' 
            + ');'
            ,"")
                          
                         

        tbar-EndHidden()
        '</tr>' skip.

    END.

    {&out} skip 
           htmlib-EndTable()
           skip.

   
  
END PROCEDURE.


&ENDIF

