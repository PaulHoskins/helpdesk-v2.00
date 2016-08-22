/***********************************************************************

    Program:        crm/ajax/note.p
    
    Purpose:        CRM Maintenance - Ajax Table    
    
    Notes:
    
    
    When        Who         What
    22/08/2016  phoski      Initial
        
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE BUFFER b-op_master  FOR op_master.
DEFINE BUFFER b-table  FOR op_Note.
DEFINE BUFFER b-status FOR WebNote.
DEFINE BUFFER b-user   FOR WebUser.
DEFINE VARIABLE lc-rowid  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mode   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-status AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-name   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-url    AS CHARACTER NO-UNDO.




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
    output-content-type("text/plain~; charset=iso-8859-1":U).
  
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-process-web-request) = 0 &THEN

PROCEDURE process-web-request :
    /*------------------------------------------------------------------------------
      Purpose:     Process the web request.
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
  
    ASSIGN 
        lc-rowid = get-value("rowid").
   
    
    RUN outputHeader.
    
    FIND b-op_master
        WHERE ROWID(b-op_master) = to-rowid(lc-rowid) NO-LOCK NO-ERROR.

    IF AVAILABLE b-op_master THEN
    DO:

        {&out}
        REPLACE(htmlib-StartMntTable(),'width="100%"','width="100%" align="center"')
        htmlib-TableHeading(
            "Date & Time^right|Details|By"
            ) skip.

        FOR EACH b-table NO-LOCK
            WHERE b-table.CompanyCode = b-op_master.CompanyCode
            AND b-table.op_id = b-op_master.op_id:

            FIND b-status WHERE b-status.CompanyCode = b-table.CompanyCode
                AND b-status.NoteCode = b-table.NoteCode NO-LOCK NO-ERROR.

            ASSIGN 
                lc-status = IF AVAILABLE b-status THEN b-status.description ELSE "".

            ASSIGN 
                lc-status = lc-status + '<br>' + replace(b-table.Contents,'~n','<BR>').

            {&out} 
            htmlib-trmouse()
            htmlib-TableField(STRING(b-table.CreateDate,'99/99/9999') + " " + STRING(b-table.CreateTime,'hh:mm am') ,'right')
           
            htmlib-TableField(lc-status,'left')
            htmlib-TableField(html-encode(com-UserName(b-table.LoginID)),'left')
            '</tr>' skip.
        END.
        {&out} skip 
              htmlib-EndTable()
             skip.
    END.

END PROCEDURE.


&ENDIF

