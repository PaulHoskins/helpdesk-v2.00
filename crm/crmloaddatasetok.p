/***********************************************************************

    Program:        crm/crmloaddatasetok.p
    
    Purpose:        CRM Data Set Upload 
    
    Notes:
    
    
    When        Who         What
    03/09/2016  phoski      Initial
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


DEFINE VARIABLE lc-type    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-relkey  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-thefile AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-DataLoad AS CHARACTER NO-UNDO.





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
  
    {lib/checkloggedin.i} 

    DEFINE VARIABLE li-docid    LIKE doch.docid NO-UNDO.
    DEFINE VARIABLE lr-raw      AS RAW          NO-UNDO.
    DEFINE VARIABLE li-line     AS INTEGER          NO-UNDO.
    DEFINE VARIABLE lc-problem  AS CHARACTER         NO-UNDO.
    DEFINE VARIABLE li-size     AS INTEGER          NO-UNDO.
    DEFINE VARIABLE lc-command  AS CHARACTER         NO-UNDO.
    DEFINE VARIABLE lc-source   AS CHARACTER         NO-UNDO.
    DEFINE VARIABLE lc-dest     AS CHARACTER         NO-UNDO.
    

    DEFINE VARIABLE lc-ext   AS CHARACTER NO-UNDO.
    
    ASSIGN 
        lc-type = get-value("type")
        lc-rowid = get-value("rowid")
        lc-thefile = get-value("thefile")
        .
    ASSIGN 
        lc-thefile = REPLACE(lc-thefile," ","").
    
    ASSIGN
        lc-dest   = "c:/helpdeskupload"
        
        lc-source = HostURL + "/hdupload/" + lc-thefile
        .


    OS-CREATE-DIR value(lc-dest).

    IF HostURL MATCHES "*LocalHost*" THEN
    DO:
        ASSIGN 
            lc-source =  "c:/hdupload/" + lc-thefile
            lc-thefile = lc-dest + "/" + lc-thefile.
               
        OS-COPY value(lc-source) value(lc-thefile).
        
    END.
    ELSE
    DO:
        ASSIGN 
            lc-command = "c:/wget/wget --directory-prefix=" + lc-dest +
                        " " + lc-source + " --no-check-certificate".

    
        OS-COMMAND SILENT VALUE(lc-command).
    
     
        ASSIGN 
            lc-thefile = lc-dest + "/" + lc-thefile.
    END.
       
       
    FIND crm_data_load WHERE ROWID(crm_data_load) = to-rowid(lc-rowid) NO-LOCK NO-ERROR.
    
    ASSIGN 
         lc-relkey = STRING(crm_data_load.load_id).
        
    
        
    IF SEARCH(lc-thefile) = ? THEN
    DO:
        ASSIGN 
            lc-problem = "The data could not be transferred".
    END.
        
    ASSIGN 
        lc-ext = substr(lc-thefile,INDEX(lc-thefile,".") + 1) no-error.
    
    IF ERROR-STATUS:ERROR THEN
    DO:
        ASSIGN 
            lc-problem = "The document type is unknown, the data was not uploaded".
    END.
    ELSE
        IF lc-ext <> "txt" THEN
        DO:
            ASSIGN 
                lc-problem = "The data file must be a text file".    
        END.
    
    IF lc-problem = "" THEN
    DO:
        FILE-INFO:FILE-NAME = lc-thefile.
        li-size = FILE-INFO:FILE-SIZE.
        IF li-size = 0 
            THEN ASSIGN lc-problem = "The document is empty, the document was not uploaded".
    
    END.
        
    IF lc-problem = "" THEN
    REPEAT:
        RUN crm/proc/crmloaddataset.p (
            lc-global-company,
            lc-global-user,
            lc-thefile,
            ROWID(crm_data_load)
                   ).        
        LEAVE.
    END.
    ELSE set-user-field("problem",lc-problem).
    
    
    set-user-field("mode","refresh").
    set-user-field("rowid",lc-rowid).
       
    IF lc-problem <> "" THEN
    DO:
        ASSIGN 
            request_method = "GET".
        RUN run-web-object IN web-utilities-hdl ("crm/crmloaddataset.p").
        RETURN.
    END.
    
    ASSIGN 
        lc-DataLoad = "Data Loaded From " + get-value("thefile") + '<br />Details of the load have been sent to your email address (' +  lc-global-email + ')'.
    set-user-field("dataload",lc-dataload).
    ASSIGN 
            request_method = "GET".
    RUN run-web-object IN web-utilities-hdl ("crm/crmload.p").
    RETURN.
        


   
END PROCEDURE.


&ENDIF

