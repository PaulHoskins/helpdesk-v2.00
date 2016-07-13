/***********************************************************************

    Program:        sys/webmenumnt.p
    
    Purpose:        Menu Page Maintenance
    
    Notes:
    
    
    When        Who         What
    26/04/2014  phoski      40 Lines  
***********************************************************************/

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-mode        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title       AS CHARACTER NO-UNDO.


DEFINE BUFFER b-valid FOR webmhead.
DEFINE BUFFER b-table FOR webmhead.
DEFINE BUFFER b-line  FOR webmline.

DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.



DEFINE VARIABLE lc-pagename     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-pagedesc     AS CHARACTER NO-UNDO.

DEFINE VARIABLE li-max-lines    AS INTEGER   INITIAL 40 NO-UNDO.


DEFINE TEMP-TABLE tt NO-UNDO LIKE webmline 
    FIELD Extension   AS CHARACTER
    FIELD Description AS CHARACTER
    INDEX PageLine IS PRIMARY
    PageLine.




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

&IF DEFINED(EXCLUDE-ip-BuildDescription) = 0 &THEN

PROCEDURE ip-BuildDescription :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE BUFFER b-valobj FOR webobject.
    DEFINE BUFFER b-valmen FOR webmhead.

    FOR EACH tt EXCLUSIVE-LOCK:
        ASSIGN 
            tt.description = ''.

        IF tt.linktype = 'NA' THEN NEXT.

        
        CASE tt.linktype:
            WHEN 'Object' THEN
                DO:
                    FIND b-valobj
                        WHERE b-valobj.Objectid = tt.linkobject NO-LOCK NO-ERROR.
                    IF AVAILABLE b-valobj
                        THEN ASSIGN tt.description = b-valobj.description.
                END.
            WHEN 'Page' THEN
                DO:
                    FIND b-valmen
                        WHERE b-valmen.pagename = tt.linkobject NO-LOCK NO-ERROR.
                    IF AVAILABLE b-valmen
                        THEN ASSIGN tt.description = b-valmen.pagedesc.
                  
                END.

        END CASE.
    END.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-BuildLinePage) = 0 &THEN

PROCEDURE ip-BuildLinePage :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    RUN ip-BuildDescription.

    {&out} '<tr><td align=center colspan=2><table width=100%>' skip.
    IF CAN-DO("view,delete",lc-mode) = FALSE
        THEN {&out} htmlib-TableHeading("Line^right|Type|Link|Description") skip.
    else {&out} htmlib-TableHeading("Type|Link|Description") skip.

           

    FOR EACH tt NO-LOCK:
        IF CAN-DO('view,delete',lc-mode) THEN
        DO:
            IF tt.linktype = 'na' THEN NEXT.
            {&out} '<tr>'
            htmlib-TableField(html-encode(tt.linktype),'left')
            htmlib-TableField(html-encode(tt.linkobject),'left')
            htmlib-TableField(html-encode(tt.description),'left')
            '</tr>' skip.
            NEXT.
        END.

        {&out} '<TR>' skip.

        {&out} '<td align=right valign=top>' STRING(tt.pageline) '</td>' skip.

        {&out} '<TD align=left valign=top>'
        htmlib-Select("select" + tt.extension,
            "NA|Object|Page",
            "Not used|Object|Menu Page",
            tt.LinkType)
        '</td>' skip.
               
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-InputField("object" + tt.extension,20,tt.LinkObject) 
        '</TD>' skip.


        {&out} '<td valign=top align=left">' tt.Description '</td>' skip.


        {&out} '</TR>' skip.
    END.



    {&out} '</table></td><tr>' skip.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-CopyDBToTemp) = 0 &THEN

PROCEDURE ip-CopyDBToTemp :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    FOR EACH tt NO-LOCK:
        FIND b-line 
            WHERE b-line.pagename = lc-pagename
            AND b-line.pageline = tt.pageline
            NO-LOCK NO-ERROR.
        IF AVAILABLE b-line THEN
        DO:
            BUFFER-COPY b-line TO tt.
        END.

    END.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-CopyHTMToTemp) = 0 &THEN

PROCEDURE ip-CopyHTMToTemp :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-select AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-object AS CHARACTER NO-UNDO.

    FOR EACH tt:
        ASSIGN 
            lc-select = get-value("select" + tt.extension).

        ASSIGN 
            lc-object = get-value("object" + tt.extension).

        ASSIGN 
            tt.linktype = lc-select
            tt.linkobject = lc-object.
    END.
    
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-CreateBlankMenuLines) = 0 &THEN

PROCEDURE ip-CreateBlankMenuLines :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-loop AS INTEGER NO-UNDO.
    DO li-loop = 1 TO li-max-lines:
        CREATE tt.
        ASSIGN 
            tt.PageLine = li-loop
            tt.Extension = STRING(li-loop,"999")
            tt.LinkType = "NA".
    END.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-UpdateLines) = 0 &THEN

PROCEDURE ip-UpdateLines :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    
    DEFINE VARIABLE li-loop AS INTEGER NO-UNDO.

        
    FOR EACH b-line WHERE b-line.pagename = b-table.pagename EXCLUSIVE-LOCK:
        DELETE b-line.
    END. 
    
    FOR EACH tt EXCLUSIVE-LOCK:
        IF tt.linktype = 'NA' THEN
        DO:
            DELETE tt.
            NEXT.
        END.
        ASSIGN 
            tt.pagename = b-table.pagename
            li-loop     = li-loop + 1
            tt.pageline = li-loop.
        CREATE b-line.
        BUFFER-COPY tt TO b-line.

    END.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      objtargets:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-valobj FOR webobject.
    DEFINE BUFFER b-valmen FOR webmhead.


    IF lc-mode = "ADD":U THEN
    DO:
        IF lc-pagename = ""
            OR lc-pagename = ?
            THEN RUN htmlib-AddErrorMessage(
                'pagename', 
                'You must enter the name',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        

        IF CAN-FIND(FIRST b-valid
            WHERE b-valid.pagename = lc-pagename
            NO-LOCK)
            THEN RUN htmlib-AddErrorMessage(
                'pagename', 
                'This name already exists',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).

    END.

    IF lc-pagedesc = ""
        OR lc-pagedesc = ?
        THEN RUN htmlib-AddErrorMessage(
            'pagedesc', 
            'You must enter the description',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF pc-error-field <> "" THEN RETURN.

    FOR EACH tt EXCLUSIVE-LOCK:
        IF tt.linktype = 'NA' THEN NEXT.

        IF tt.linkobject = ""
            OR tt.linkobject = ? THEN
        DO:
            RUN htmlib-AddErrorMessage(
                'null', 
                'Line ' + string(tt.pageline) + 
                ' - You must enter the object or menu page',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
            
        END.
        ELSE
            CASE tt.linktype:
                WHEN 'Object' THEN
                    DO:
                        IF NOT CAN-FIND(b-valobj
                            WHERE b-valobj.Objectid = tt.linkobject NO-LOCK)
                            THEN RUN htmlib-AddErrorMessage(
                                'null', 
                                'Line ' + string(tt.pageline) + 
                                ' - This web object does not exist',
                                INPUT-OUTPUT pc-error-field,
                                INPUT-OUTPUT pc-error-msg ).
                    END.
                WHEN 'Page' THEN
                    DO:
                        IF NOT CAN-FIND(b-valmen
                            WHERE b-valmen.pagename = tt.linkobject NO-LOCK)
                            THEN RUN htmlib-AddErrorMessage(
                                'null', 
                                'Line ' + string(tt.pageline) + 
                                ' - This menu page does not exist',
                                INPUT-OUTPUT pc-error-field,
                                INPUT-OUTPUT pc-error-msg ).
                        IF tt.linkobject = lc-pagename THEN
                        DO:
                            RUN htmlib-AddErrorMessage(
                                'null', 
                                'Line ' + string(tt.pageline) + 
                                ' - A menu can not contain it self',
                                INPUT-OUTPUT pc-error-field,
                                INPUT-OUTPUT pc-error-msg ).
                        END.
                    END.

            END CASE.
    END.

END PROCEDURE.


&ENDIF

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
    output-content-type ("text/html":U).
  
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

    RUN ip-CreateBlankMenuLines.

    ASSIGN 
        lc-mode = get-value("mode")
        lc-rowid = get-value("rowid")
        lc-search = get-value("search")
        lc-firstrow = get-value("firstrow")
        lc-lastrow  = get-value("lastrow")
        lc-navigation = get-value("navigation").

    IF lc-mode = "" 
        THEN ASSIGN lc-mode = get-field("savemode")
            lc-rowid = get-field("saverowid")
            lc-search = get-value("savesearch")
            lc-firstrow = get-value("savefirstrow")
            lc-lastrow  = get-value("savelastrow")
            lc-navigation = get-value("savenavigation").

    ASSIGN 
        lc-parameters = "search=" + lc-search +
                           "&firstrow=" + lc-firstrow + 
                           "&lastrow=" + lc-lastrow.

    CASE lc-mode:
        WHEN 'add'
        THEN 
            ASSIGN 
                lc-title = 'Add'
                lc-link-label = "Cancel addition"
                lc-submit-label = "Add Menu Page".
        WHEN 'view'
        THEN 
            ASSIGN 
                lc-title = 'View'
                lc-link-label = "Back"
                lc-submit-label = "".
        WHEN 'delete'
        THEN 
            ASSIGN 
                lc-title = 'Delete'
                lc-link-label = 'Cancel deletion'
                lc-submit-label = 'Delete Menu Page'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Menu Page'.
    END CASE.


    ASSIGN 
        lc-title = lc-title + ' Menu Page'
        lc-link-url = appurl + '/sys/webmenu.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&time=' + string(TIME)
        .

    IF CAN-DO("view,update,delete",lc-mode) THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE b-table THEN
        DO:
            set-user-field("mode",lc-mode).
            set-user-field("title",lc-title).
            set-user-field("nexturl",appurl + "/sys/webmenu.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-pagename  = get-value("pagename")
                lc-pagedesc    = get-value("pagedesc")
                   
                .
            
            RUN ip-CopyHTMToTemp.

            RUN ip-Validate( OUTPUT lc-error-field,
                OUTPUT lc-error-msg ).

            IF lc-error-msg = "" THEN
            DO:
                
                IF lc-mode = 'update' THEN
                DO:
                    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
                        EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                    IF LOCKED b-table 
                        THEN  RUN htmlib-AddErrorMessage(
                            'none', 
                            'This record is locked by another user',
                            INPUT-OUTPUT lc-error-field,
                            INPUT-OUTPUT lc-error-msg ).
                END.
                ELSE
                DO:
                    CREATE b-table.
                    ASSIGN 
                        b-table.pagename = lc-pagename
                        lc-firstrow      = STRING(ROWID(b-table)).
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.pagedesc  = lc-pagedesc
                        .
                    RUN ip-UpdateLines.
                END.
            END.
        END.
        ELSE
        DO:
            FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
                EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            IF LOCKED b-table 
                THEN  RUN htmlib-AddErrorMessage(
                    'none', 
                    'This record is locked by another user',
                    INPUT-OUTPUT lc-error-field,
                    INPUT-OUTPUT lc-error-msg ).
            ELSE 
            DO:
                FOR EACH b-line OF b-table EXCLUSIVE-LOCK:
                    DELETE b-line.
                END.
                DELETE b-table.
            END.
        END.

        IF lc-error-field = "" THEN
        DO:
            RUN outputHeader.
            set-user-field("navigation",'refresh').
            set-user-field("firstrow",lc-firstrow).
            set-user-field("search",lc-search).
            RUN run-web-object IN web-utilities-hdl ("sys/webmenu.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        ASSIGN 
            lc-pagename = b-table.pagename.

        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post" THEN 
        DO:
            ASSIGN 
                lc-pagedesc   = b-table.pagedesc.
            RUN ip-CopyDBToTemp.
        END.
    /* if request_method = "post" 
    then RUN ip-CopyHTMToTemp.
    */
    END.



    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", selfurl )
           htmlib-ProgramTitle(lc-title) skip.

    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    {&out} htmlib-StartInputTable() skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("pagename",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Page Name")
        ELSE htmlib-SideLabel("Page Name"))
    '</TD>' skip
    .

    IF lc-mode = "ADD" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("pagename",20,lc-pagename) skip
           '</TD>'.
    else
    {&out} htmlib-TableField(html-encode(lc-pagename),'left')
           skip.


    {&out} '</TR>' skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("pagedesc",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Description")
        ELSE htmlib-SideLabel("Description"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("pagedesc",40,lc-pagedesc) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-pagedesc),'left')
           skip.
    {&out} '</TR>' skip.

    RUN ip-BuildLinePage.


    /*
    {&out} htmlib-Select("ASELECT","01|02|03|04","num1|num2|num3|num4","04").
    */
    {&out} htmlib-EndTable() skip.


    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.

    IF lc-submit-label <> "" THEN
    DO:
        {&out} '<center>' htmlib-SubmitButton("submitform",lc-submit-label) 
        '</center>' skip.
    END.
         
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

