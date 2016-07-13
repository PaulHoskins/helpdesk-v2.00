/***********************************************************************

    Program:        iss/addnote.p
    
    Purpose:        Add Note To Issue    
    
    Notes:
    
    
    When        Who         What
    10/04/2006  phoski      CompanyCode      
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.

DEFINE BUFFER b-issue  FOR Issue.
DEFINE BUFFER b-table  FOR IssNote.
DEFINE BUFFER b-status FOR WebNote.
DEFINE BUFFER b-user   FOR WebUser.
DEFINE VARIABLE lc-rowid     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mode      AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-type      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-note      AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-list-note AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-desc AS CHARACTER NO-UNDO.




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

&IF DEFINED(EXCLUDE-ip-GetNoteTypes) = 0 &THEN

PROCEDURE ip-GetNoteTypes :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-note   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-desc            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-notetype FOR WebNote.

    ASSIGN 
        pc-note = htmlib-Null()
        pc-desc = "Select Note Type".


    FOR EACH b-notetype NO-LOCK 
        WHERE b-notetype.companycode = lc-global-company 
        BY b-notetype.description:
       
        ASSIGN 
            pc-note = pc-note + '|' + 
               b-notetype.NoteCode
            pc-desc = pc-desc + '|' + 
               b-notetype.description.
    END.
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


    IF lc-type = htmlib-Null() 
        THEN RUN htmlib-AddErrorMessage(
            'type', 
            'You select the note type',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF lc-note = ""
        THEN RUN htmlib-AddErrorMessage(
            'note', 
            'You must enter the note',
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
    
    {lib/checkloggedin.i}


    ASSIGN 
        lc-rowid = get-value("rowid")
        lc-mode  = get-value("mode").

    IF lc-rowid = "" 
        THEN ASSIGN lc-rowid = get-value("saverowid")
            lc-mode  = get-value("savemode").

    FIND b-issue WHERE ROWID(b-issue) = to-rowid(lc-rowid) NO-LOCK NO-ERROR.
    IF request_method = "post" THEN
    DO:
        ASSIGN 
            lc-note = get-value("note")
            lc-type = get-value("type").
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).

        IF lc-error-msg = "" THEN
        DO:
            CREATE b-table.
            ASSIGN 
                b-table.IssueNumber = b-issue.IssueNumber
                b-table.CompanyCode = b-issue.CompanyCode
                b-table.CreateDate  = TODAY
                b-table.CreateTime = TIME
                b-table.LoginID    = lc-user
                b-table.NoteCode   = lc-type
                b-table.Contents   = lc-note.
            RUN outputHeader.
            {&out} '<html><head></head>' skip.

            {&out} '<script language="javascript">' skip
                    'var ParentWindow = opener' skip
                    'ParentWindow.noteCreated()' skip
                    'self.close()' skip
                    '</script>' skip.

            {&out} '</html>'.
            RETURN.


        END.

    END.

    RUN ip-GetNoteTypes ( OUTPUT lc-list-note,
        OUTPUT lc-list-desc ).
   
    
    RUN outputHeader.

    {&out} REPLACE(htmlib-Header("Add Note"),
        "ClosePage",
        "ClosePage") skip.

    {&out} htmlib-StartForm("mainform","post", appurl + '/iss/addnote.p' ) skip.

    {&out} htmlib-ProgramTitle("Add Note").

  
    {&out} htmlib-Hidden("savemode",lc-mode)
    htmlib-Hidden("saverowid",lc-rowid).

  
    {&out} htmlib-StartInputTable() skip.



    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("type",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Note Type")
        ELSE htmlib-SideLabel("Note Type"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("type",lc-list-note,lc-list-desc,
        lc-type)
    '</TD></TR>' skip. 


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("note",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Note")
        ELSE htmlib-SideLabel("Note"))
    '</TD>' skip
           '<TD VALIGN="TOP" ALIGN="left">'
           htmlib-TextArea("note",lc-note,10,60)
          '</TD>' skip
           skip.


    {&out} htmlib-EndTable() skip.
    
    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.

    {&out} '<center>' htmlib-SubmitButton("submitform","Add Note") 
    '</center>' skip.
    


    {&out} htmlib-Hidden("submitsource","null").


    {&OUT} htmlib-EndForm() skip 
           htmlib-Footer() skip.


END PROCEDURE.


&ENDIF

