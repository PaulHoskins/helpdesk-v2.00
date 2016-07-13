/***********************************************************************

    Program:        sys/kbview.p
    
    Purpose:        KB View
    
    Notes:
    
    
    When        Who         What
    01/08/2006  phoski      Initial   
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


DEFINE BUFFER b-valid    FOR knbText.
DEFINE BUFFER b-table    FOR knbText.

DEFINE BUFFER knbSection FOR knbSection.
DEFINE BUFFER knbItem    FOR knbItem.


DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-mode        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Search      AS CHARACTER NO-UNDO.




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

&IF DEFINED(EXCLUDE-ip-BuildPage) = 0 &THEN

PROCEDURE ip-BuildPage :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE VARIABLE lc-text     AS CHARACTER.
    DEFINE VARIABLE li-loop     AS INTEGER  NO-UNDO.
    DEFINE VARIABLE lc-char     AS CHARACTER NO-UNDO.

    DEFINE BUFFER knbText  FOR knbText.

    FIND knbItem WHERE knbItem.knbID = b-table.knbID NO-LOCK NO-ERROR.
    FIND knbSection OF knbItem NO-LOCK NO-ERROR.

    FIND knbText WHERE knbText.knbID = b-table.knbID
        AND knbText.dType = "I" NO-LOCK NO-ERROR.
    

    IF AVAILABLE knbText THEN
    DO:
        ASSIGN 
            lc-text = knbText.dData.

        /*
        ***
        *** Catch Size errors 
        ***
        */
        THISBLOCK:
        DO ON ERROR UNDO THISBLOCK , LEAVE THISBLOCK:
        
            ASSIGN
                lc-text = IF AVAILABLE knbText THEN REPLACE(html-encode(knbText.dData),
                                             '~n','<br>')
                         ELSE "".
            
    
            IF lc-text <> "" THEN
            DO li-loop = 1 TO NUM-ENTRIES(lc-search," "):
                ASSIGN
                    lc-char = TRIM(ENTRY(li-loop,lc-search," ")).
                IF lc-char = "" THEN NEXT.
        
                ASSIGN
                    lc-text = REPLACE(lc-text,lc-char,'<span class="hi">' + lc-char + "</span>").
            END.
        END.
        

    END.
    {&out} htmlib-StartInputTable() skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Section") '</TD>' skip
           htmlib-TableField(html-encode(knbSection.Description),'left') skip
           '</tr>' skip.    

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Title") '</TD>' skip
           htmlib-TableField(html-encode(knbItem.kTitle),'left') skip
           '</tr>' skip.

    /*
   {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
          htmlib-SideLabel("Text") '</TD>' skip
          htmlib-TableField(replace(html-encode(knbText.dData),
                                    '~n','<br/>'),'left') skip
          '</tr>' skip.
   */
    {&out} '<tr><td class="tablefield" colspan=2">' skip
                    '<div style="margin: 5px;">'
                htmlib-BeginCriteria("Details") '<br>'
                lc-text
        htmlib-EndCriteria()
                    '</div>'
        '</td></tr>'.
                

    
    {&out} htmlib-EndTable() skip.

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
        lc-search = get-value("search")
        .
    IF lc-rowid = ""
        THEN ASSIGN lc-rowid = get-value("saverowid").

    ASSIGN 
        lc-title = 'View'.

    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK NO-ERROR.

    ASSIGN 
        lc-title = lc-title + ' KB Item ' + string(b-table.knbID).
    

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           '<style>' skip
           '.hi ~{ font-weight: 900;color: red; ~}' skip
           '</style>' skip
           htmlib-StartForm("mainform","post", appurl + '/sys/kbview.p' )
           htmlib-ProgramTitle(lc-title).
    {&out} htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("search",lc-search) skip.

    {&out} '<a href="javascript:window.print()"><img src="/images/general/print.gif" border=0 style="padding: 5px;"></a>' skip.

    
    RUN ip-BuildPage.

    

    {&OUT} htmlib-EndForm() skip 
           htmlib-Footer() skip.
    
   
END PROCEDURE.


&ENDIF

