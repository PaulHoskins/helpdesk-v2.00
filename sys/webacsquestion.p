/***********************************************************************

    Program:        sys/webacsquestion.p
    
    Purpose:        Account Survey Maintenance - Question
    
    Notes:
    
    
    When        Who         What
    18/06/2016  phoski      Initial
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-mess  AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.


DEFINE VARIABLE li-max-lines   AS INTEGER   INITIAL 12 NO-UNDO.
DEFINE VARIABLE lr-first-row   AS ROWID     NO-UNDO.
DEFINE VARIABLE lr-last-row    AS ROWID     NO-UNDO.
DEFINE VARIABLE li-count       AS INTEGER   NO-UNDO.
DEFINE VARIABLE ll-prev        AS LOGICAL   NO-UNDO.
DEFINE VARIABLE ll-next        AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lc-search      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-smessage    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-otherp AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-char        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-nopass      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ProjCode    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url    AS CHARACTER NO-UNDO.


DEFINE BUFFER b-query  FOR acs_line.
DEFINE BUFFER b-search FOR acs_line.


DEFINE QUERY q FOR b-query SCROLLING.




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
    
    DEFINE BUFFER this-surv     FOR acs_head.
    DEFINE VARIABLE lr-Rows     AS ROWID EXTENT 2 NO-UNDO.
    
    
  
    {lib/checkloggedin.i}

   
    ASSIGN 
        lc-ProjCode   = get-value("projectcode")
        lc-search     = get-value("search")
        lc-firstrow   = get-value("firstrow")
        lc-lastrow    = get-value("lastrow")
        lc-navigation = get-value("navigation").
    
    ASSIGN 
        lc-parameters = "search=" + lc-search +
                           "&firstrow=" + lc-firstrow + 
                           "&lastrow=" + lc-lastrow.

    
    
    ASSIGN 
        lc-char = htmlib-GetAttr('system','MNTNoLinesDown').
    
    ASSIGN 
        li-max-lines = int(lc-char) no-error.
    IF ERROR-STATUS:ERROR
        OR li-max-lines < 1
        OR li-max-lines = ? THEN li-max-lines = 12.


    RUN outputHeader.
    
    FIND this-surv WHERE this-surv.CompanyCode = lc-global-company
        AND this-surv.acs_code = lc-projCode
        NO-LOCK NO-ERROR.
                     
    {&out} htmlib-Header("Maintain Account Survey - Questions") skip.

    {&out} htmlib-JScript-Maintenance() skip.

    {&out} htmlib-StartForm("mainform","post", appurl + '/sys/webacsquestion.p' ) skip.

    {&out} htmlib-ProgramTitle("Maintain Account Survey - Questions -<i> " + lc-ProjCode + " " + this-surv.descr + '</i>') skip.
    
    ASSIGN 
        lc-link-url = appurl + '/sys/webacs.p' +
                                  '?navigation=refresh' +
                                  '&time=' + string(TIME).
    {&out} htmlib-TextLink("Back",lc-link-url) '<BR><BR>' skip.
                                  
    ASSIGN
        lc-link-otherp = "projectcode=" + lc-projcode.
        
    {&out}
    tbar-Begin(
                 "<br>Survey: <b>" + this-surv.descr + '</b>' /* no search option */
        )
    tbar-Link("add",?,appurl + "/sys/webacsquestionmnt.p",lc-link-otherp)
    tbar-BeginOption()
    tbar-Link("view",?,"off",lc-link-otherp)
    tbar-Link("update",?,"off",lc-link-otherp)
    tbar-Link("delete",?,"off",lc-link-otherp)
    
    tbar-Link("recdown",?,"off",lc-link-otherp)
    tbar-Link("recup",?,"off",lc-link-otherp)
       
    tbar-EndOption()
    tbar-End().
    {&out} skip
           htmlib-StartMntTable().


    {&out}
    htmlib-TableHeading(
        "Order^right|Question^left|Type"
        ) skip.


    /*
    ***
    *** First and last phases , no move up/down options unless it make sense later 
    ***
    */
    ASSIGN
        lr-rows = ?.
    FIND FIRST b-query
        WHERE b-query.companycode = lc-global-company
        AND b-query.acs_code = lc-projCode
         NO-LOCK NO-ERROR.
    ASSIGN lr-rows[1] = IF AVAILABLE b-query THEN ROWID(b-query) ELSE ?.
          
    FIND LAST b-query
        WHERE b-query.companycode = lc-global-company
         AND b-query.acs_code = lc-projCode
         NO-LOCK NO-ERROR.
    ASSIGN lr-rows[2] = IF AVAILABLE b-query THEN ROWID(b-query) ELSE ?.
            
    OPEN QUERY q FOR EACH b-query NO-LOCK
        WHERE b-query.companycode = lc-global-company
        AND b-query.acs_code = lc-projCode
       .

    GET FIRST q NO-LOCK.
    

    ASSIGN 
        li-count     = 0
        lr-first-row = ?
        lr-last-row  = ?.

    REPEAT WHILE AVAILABLE b-query:
   
        
        ASSIGN 
            lc-rowid = STRING(ROWID(b-query)).
        
        ASSIGN 
            li-count = li-count + 1.
        IF lr-first-row = ?
            THEN ASSIGN lr-first-row = ROWID(b-query).
        ASSIGN 
            lr-last-row = ROWID(b-query).
        
        ASSIGN 
            lc-link-otherp = 'search=' + lc-search +
                             '&firstrow=' + string(lr-first-row)  +
                             '&projectcode=' + lc-projcode /* + 
                             '&phaseid=' + string(b-query.acc_line_id)*/.

       
        {&out}
            skip
            tbar-tr(rowid(b-query))
            skip
            htmlib-MntTableField(string(b-query.DisplayOrder),'right')
            htmlib-MntTableField(html-encode(b-query.qText),'left')
            htmlib-mntTableField(
            dynamic-function("com-DecodeLookup",b-query.QType,
                                     lc-global-sq-Code,
                                     lc-global-sq-Desc
                                     )
            ,'left')
              tbar-BeginHidden(rowid(b-query))
                tbar-Link("view",rowid(b-query),appurl + "/sys/webacsquestionmnt.p",lc-link-otherp)
                tbar-Link("update",rowid(b-query),appurl + "/sys/webacsquestionmnt.p",lc-link-otherp)
                tbar-Link("delete",rowid(b-query),
                          if DYNAMIC-FUNCTION('com-CanDelete':U,lc-user,"webacsquestion",rowid(b-query))
                          then ( appurl + "/sys/webacsquestionmnt.p") else "off",
                          lc-link-otherp)
                tbar-Link("recdown",rowid(b-query),
                IF lr-rows[2] = rowid(b-query) THEN "off" 
                ELSE appurl + "/sys/webacsquestionmnt.p",lc-link-otherp)
                tbar-Link("recup",rowid(b-query),
                IF lr-rows[1] = rowid(b-query) THEN "off" 
                ELSE appurl + "/sys/webacsquestionmnt.p",lc-link-otherp)
               
                
               
            tbar-EndHidden()  
            
            '</tr>' skip.

       

        GET NEXT q NO-LOCK.
            
    END.

    IF li-count < li-max-lines THEN
    DO:
        {&out} skip htmlib-BlankTableLines(li-max-lines - li-count) skip.
    END.

    {&out} skip 
           htmlib-EndTable()
           skip.

    {lib/navpanel.i "sys/webacsquestion.p"}

    {&out} skip
           htmlib-Hidden("firstrow", string(lr-first-row)) skip
           htmlib-Hidden("lastrow", string(lr-last-row)) SKIP
           htmlib-Hidden("projectcode", lc-projcode) skip
           skip.

    
    {&out} htmlib-EndForm().

    
    {&OUT} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

