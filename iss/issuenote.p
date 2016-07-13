/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 

------------------------------------------------------------------------*/
/*           This .W file was created with the Progress AppBuilder.     */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE BUFFER b-issue  FOR Issue.
DEFINE BUFFER b-table  FOR IssNote.
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


    ASSIGN 
        lc-rowid = get-value("rowid")
        lc-mode  = get-value("mode").

    IF lc-rowid = "" 
        THEN ASSIGN lc-rowid = get-value("saverowid")
            lc-mode  = get-value("savemode").


    FIND b-issue WHERE ROWID(b-issue) = to-rowid(lc-rowid) NO-LOCK NO-ERROR.

    RUN outputHeader.

    {&out} htmlib-Header("Notes") skip.

    {&out} REPLACE(htmlib-ProgramTitle("Notes"),
        "programtitle","subprogramtitle").

 
    IF lc-mode = "update" THEN
    DO:
        ASSIGN 
            lc-url = appurl + '/iss/addnote.p?rowid=' + lc-rowid.
        {&out} skip
              '<BR><CENTER>' replace(replace(htmlib-Button("help",
                            "Add New Note",
                            lc-url),
                      "SubmitThePage",
                      "PopUpWindow"),"submitbutton","actionbutton")
              '</CENTER><BR>' skip.
    END.
    {&out} htmlib-Hidden("savemode",lc-mode)
    htmlib-Hidden("saverowid",lc-rowid).

    IF AVAILABLE b-issue THEN
    DO:
        {&out}
        htmlib-StartMntTable()
        htmlib-TableHeading(
            "Date^right|Time^right|Details|By"
            ) skip.

        FOR EACH b-table NO-LOCK
            WHERE b-table.CompanyCode = b-issue.CompanyCode
            AND b-table.IssueNumber = b-issue.IssueNumber:

            FIND b-status
                WHERE b-status.CompanyCode = b-table.CompanyCode
                AND b-status.NoteCode = b-table.NoteCode NO-LOCK NO-ERROR.

            ASSIGN 
                lc-status = IF AVAILABLE b-status THEN b-status.description ELSE "".

            ASSIGN 
                lc-status = lc-status + '<br>' + replace(b-table.Contents,'~n','<BR>').

            FIND b-user WHERE b-user.LoginID = b-table.LoginID NO-LOCK NO-ERROR.
            ASSIGN 
                lc-name = IF AVAILABLE b-user THEN b-user.name ELSE "".

            {&out} '<tr>' skip
               htmlib-TableField(string(b-table.CreateDate,'99/99/9999'),'right')
               htmlib-TableField(string(b-table.CreateTime,'hh:mm am'),'right')
               htmlib-TableField(lc-status,'left')
               htmlib-TableField(html-encode(lc-name),'left')
               '</tr>' skip.
        END.
        {&out} skip 
          htmlib-EndTable()
          skip.


    END.
    ELSE {&out} "missing row " lc-rowid.

    {&OUT} htmlib-Footer() skip.


END PROCEDURE.


&ENDIF

