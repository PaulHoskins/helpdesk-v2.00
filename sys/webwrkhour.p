/***********************************************************************

    Program:        sys/webwrkhour.p
    
    Purpose:        User Maintenance - Working Hours
    
    Notes:
    
    
    When        Who         What
    29/11/2014  phoski      Initial
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.

DEFINE VARIABLE li-curr-year   AS INTEGER   FORMAT "9999" NO-UNDO.

DEFINE VARIABLE lc-day         AS CHARACTER INITIAL "Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday" NO-UNDO.

DEFINE VARIABLE lc-mode        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title       AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-warn        AS LOGICAL   NO-UNDO.

                          
DEFINE BUFFER b-valid FOR webuser.
DEFINE BUFFER b-table FOR webuser.


DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.
                          
DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-loginid      AS CHARACTER NO-UNDO.

DEFINE VARIABLE li-loop         AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-name         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-dname        AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-int          AS INTEGER   EXTENT 4 NO-UNDO.







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

&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

PROCEDURE ip-Validate:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DO li-loop = 1 TO 7:
        ASSIGN
            li-int = 0
            lc-dname = ENTRY(li-loop,lc-day) + ":-".
        ASSIGN 
            lc-name = "ams" + string(li-loop).
        li-int[1] = int(get-value(lc-name)).
        ASSIGN 
            lc-name = "ame" + string(li-loop).
        li-int[2] = int(get-value(lc-name)).
        ASSIGN 
            lc-name = "pms" + string(li-loop).
        li-int[3] = int(get-value(lc-name)).
        ASSIGN 
            lc-name = "pme" + string(li-loop).
        li-int[4] = int(get-value(lc-name)).
            
        IF li-int[1] <> 0 OR li-int[2] <> 0 THEN
        DO:
            IF li-int[2] <= li-int[1]  THEN
            DO:
                ASSIGN 
                    lc-error-msg = lc-error-msg + "," + lc-dname + " AM End before/on AM Start".
                NEXT.
            END.
            IF li-int[2] > 0 AND li-int[1] = 0 THEN
            DO:
                ASSIGN 
                    lc-error-msg = lc-error-msg + "," + lc-dname + " AM End without AM Start".
                NEXT.
                
            END.
        END.
            
        IF li-int[4] <> 0 OR li-int[3] <> 0 THEN
        DO:
            
            IF li-int[4] <= li-int[3] THEN
            DO:
                ASSIGN 
                    lc-error-msg = lc-error-msg + "," + lc-dname + " PM End before PM Start".
                NEXT.
                
            END.
            IF li-int[4] > 0 AND li-int[3] = 0 THEN
            DO:
                ASSIGN 
                    lc-error-msg = lc-error-msg + "," + lc-dname + " PM End without PM Start".
                NEXT.
                
            END.
            
            IF li-int[3] <= li-int[2] AND li-int[2] <> 0 THEN
            DO:
                ASSIGN 
                    lc-error-msg = lc-error-msg + "," + lc-dname + " AM/PM Overlap".
                NEXT.
            END.
            
        END.
            
                
    END.
END PROCEDURE.

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
    
    

    DEFINE VARIABLE lc-selacc AS CHARACTER NO-UNDO.
    

    {lib/checkloggedin.i} 

    ASSIGN 
        lc-selacc     = get-value("selacc")
        lc-mode       = get-value("mode")
        lc-rowid      = get-value("rowid")
        lc-search     = get-value("search")
        lc-firstrow   = get-value("firstrow")
        lc-lastrow    = get-value("lastrow")
        lc-navigation = get-value("navigation")
        li-curr-year  = INTEGER(get-value("submityear"))
        .
    
  
   

    ASSIGN 
        lc-parameters = "search=" + lc-search +
                        "&firstrow=" + lc-firstrow + 
                        "&lastrow=" + lc-lastrow.
  

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
    ASSIGN 
        lc-loginid = b-table.loginid.
    ASSIGN 
        lc-title        = 'Working Hours - <b>' + 
           html-encode(b-table.forename + " " + b-table.surname)
           + " - " + string(li-curr-year) + '</b>'
        lc-link-label   = "Back"
        lc-submit-label = "Update Times".
      
    ASSIGN 
        lc-link-url = appurl + '/sys/webuser.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&submityear=' + string(li-curr-year) +
                                  '&selacc=' + lc-selacc +
                                  '&time=' + string(TIME).
   

    IF request_method = "POST" THEN
    DO:
        ASSIGN 
            lc-error-msg = "".
        
        RUN ip-validate.
        
        IF lc-error-msg = "" THEN
        DO:
            FIND WebStdTime
                WHERE WebStdTime.CompanyCode = lc-global-company
                AND WebStdTime.LoginID = lc-loginid
                AND WebStdTime.StdWkYear = li-curr-year EXCLUSIVE-LOCK NO-ERROR.
            IF NOT AVAILABLE WebStdTime THEN
            DO:
                CREATE WebStdTime.
                ASSIGN 
                    WebStdTime.CompanyCode = lc-global-company
                    WebStdTime.LoginID = lc-loginid
                    WebStdTime.StdWkYear = li-curr-year.
            END.
            
            DO li-loop = 1 TO 7:
                ASSIGN
                    li-int = 0
                    lc-dname = ENTRY(li-loop,lc-day) + ":-".
                ASSIGN 
                    lc-name = "ams" + string(li-loop).
                WebStdTime.StdAMStTime[li-loop] = int(get-value(lc-name)).
                ASSIGN 
                    lc-name = "ame" + string(li-loop).
                WebStdTime.StdAMEndTime[li-loop] = int(get-value(lc-name)).
                ASSIGN 
                    lc-name = "pms" + string(li-loop).
                WebStdTime.StdPMStTime[li-loop] = int(get-value(lc-name)).
                ASSIGN 
                    lc-name = "pme" + string(li-loop).
                WebStdTime.StdPMEndTime[li-loop] = int(get-value(lc-name)).
            END.
            RUN outputHeader.
            set-user-field("navigation",'refresh').
            set-user-field("firstrow",lc-firstrow).
            set-user-field("search",lc-search).
            set-user-field("selacc",lc-selacc).
            set-user-field("submityear",STRING(li-curr-year)).
            RUN run-web-object IN web-utilities-hdl ("sys/webuser.p").
            RETURN.
            
        END.
        
   
    END.
    ELSE
    DO:
        FIND WebStdTime
            WHERE WebStdTime.CompanyCode = lc-global-company
            AND WebStdTime.LoginID = lc-loginid
            AND WebStdTime.StdWkYear = li-curr-year NO-LOCK NO-ERROR.
              
        IF NOT AVAILABLE WebStdTime THEN
        DO:
            FIND WebStdTime
                WHERE WebStdTime.CompanyCode = lc-global-company
                AND WebStdTime.LoginID = lc-loginid
                AND WebStdTime.StdWkYear = li-curr-year - 1 NO-LOCK NO-ERROR.
                  
            ASSIGN 
                ll-warn = AVAILABLE WebStdTime.
                
        END.
             
              
        IF AVAILABLE WebStdTime THEN
        DO li-loop = 1 TO 7:
            ASSIGN 
                lc-name = "ams" + string(li-loop).
            set-user-field(lc-name,STRING(WebStdTime.StdAMStTime[li-loop],"9999")).
            ASSIGN 
                lc-name = "ame" + string(li-loop).
            set-user-field(lc-name,STRING(WebStdTime.StdAMEndTime[li-loop],"9999")).
            ASSIGN 
                lc-name = "pms" + string(li-loop).
            set-user-field(lc-name,STRING(WebStdTime.StdPMStTime[li-loop],"9999")).
            ASSIGN 
                lc-name = "pme" + string(li-loop).
            set-user-field(lc-name,STRING(WebStdTime.StdPMEndTime[li-loop],"9999")).
            
        END.
                
              
    END.



    RUN outputHeader.
    
    {&out} htmlib-OpenHeader(lc-title) skip
           htmlib-CloseHeader("") skip
           htmlib-StartForm("mainform","post", selfurl ) skip
           htmlib-ProgramTitle(lc-title) skip.

    {&out} htmlib-Hidden ("mode", lc-mode) SKIP
           htmlib-Hidden ("selacc", lc-selacc) skip
           htmlib-Hidden ("rowid", lc-rowid) skip
           htmlib-Hidden ("search", lc-search) skip
           htmlib-Hidden ("firstrow", lc-firstrow) skip
           htmlib-Hidden ("lastrow", lc-lastrow) skip
           htmlib-Hidden ("navigation", lc-navigation) skip
           htmlib-Hidden ("nullfield", lc-navigation) skip
           htmlib-Hidden ("submityear", string(li-curr-year)) skip
    .
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.


    IF ll-warn THEN
    DO:
        {&out} '<div class="infobox" style="font-size: 10px;">' 
        '<center>There are no details available for ' STRING(li-curr-year)
        '. Defaulting details from ' STRING(li-curr-year - 1) '.'
        '</center></div>'skip.
                    
                       
    END.
    
    {&out} skip
          htmlib-StartMntTable().

    {&out}
         skip
    htmlib-TableHeading(
        "Day^right|AM Start^right|AM End^right|PM Start^right|PM End^right"
        ) skip.
   
    
    DO li-loop = 1 TO 7:
    
        {&out}
        '<tr>' SKIP
              htmlib-MntTableField(html-encode(entry(li-loop,lc-day)),'right') SKIP.
        ASSIGN 
            lc-name = "ams" + string(li-loop).
        {&out}
        htmlib-MntTableField(
            htmlib-SelectTime(lc-name,get-value(lc-name))
            ,'right') SKIP.
                     
        ASSIGN 
            lc-name = "ame" + string(li-loop).
        {&out}
        htmlib-MntTableField(
            htmlib-SelectTime(lc-name,get-value(lc-name))
            ,'right') SKIP.
            
        ASSIGN 
            lc-name = "pms" + string(li-loop).
        {&out}
        htmlib-MntTableField(
            htmlib-SelectTime(lc-name,get-value(lc-name))
            ,'right') SKIP.
        ASSIGN 
            lc-name = "pme" + string(li-loop).
        {&out}
        htmlib-MntTableField(
            htmlib-SelectTime(lc-name,get-value(lc-name))
            ,'right') SKIP.
                
                  
        {&out} '</tr>' SKIP.
                  
    END.
    
    
    {&out} skip 
           htmlib-EndTable()
           SKIP.
           
    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.
    
    {&out} '<center>' htmlib-SubmitButton("submitform","Update") 
    '</center>' skip.
    
    
             
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.




    
  
END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */







