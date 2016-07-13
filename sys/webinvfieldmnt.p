/***********************************************************************

    Program:        sys/webinvfieldmnt.p
    
    Purpose:        Equipment Subclass Maintenance - Field Def             
    
    Notes:
    
    
    When        Who         What
    12/04/2006  phoski      Initial
    30/07/2006  phoski      Warning field on numbers

***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg  AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-mode AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title AS CHARACTER NO-UNDO.


DEFINE BUFFER ivClass  FOR ivClass.
DEFINE BUFFER ivSub    FOR ivSub.
DEFINE BUFFER b-valid  FOR ivField.
DEFINE BUFFER b-table  FOR ivField.


DEFINE VARIABLE lc-search    AS CHARACTER  NO-UNDO.
DEFINE VARIABLE lc-firstrow  AS CHARACTER  NO-UNDO.
DEFINE VARIABLE lc-lastrow   AS CHARACTER  NO-UNDO.
DEFINE VARIABLE lc-navigation AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.




DEFINE VARIABLE lc-ClassCode    AS CHARACTER  NO-UNDO.
DEFINE VARIABLE lc-subcode      AS CHARACTER  NO-UNDO.
DEFINE VARIABLE lc-firstback    AS CHARACTER  NO-UNDO.
DEFINE VARIABLE lf-Audit        AS DECIMAL   NO-UNDO.

DEFINE VARIABLE lc-dlabel       AS CHARACTER  NO-UNDO.
DEFINE VARIABLE lc-dorder       AS CHARACTER  NO-UNDO.
DEFINE VARIABLE lc-dtype        AS CHARACTER  NO-UNDO.
DEFINE VARIABLE lc-dMandatory   AS CHARACTER  NO-UNDO.
DEFINE VARIABLE lc-dprompt      AS CHARACTER  NO-UNDO.
DEFINE VARIABLE lc-dWarning     AS CHARACTER  NO-UNDO.




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

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  emails:       
------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.


    DEFINE VARIABLE li-int      AS INTEGER      NO-UNDO.
    
    IF lc-dorder = ""
    OR lc-dorder = ?
    THEN 
    DO:
        RUN htmlib-AddErrorMessage(
                'dorder', 
                'You must enter the display order',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        RETURN.
    END.

    ASSIGN li-int = int(lc-dorder) no-error.
    IF ERROR-STATUS:ERROR OR li-int <= 0 THEN
    DO:
        RUN htmlib-AddErrorMessage(
                'dorder', 
                'You must enter a numeric display order',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        RETURN.
        
    END.
        
    IF lc-dlabel = ""
    OR lc-dlabel = ?
    THEN RUN htmlib-AddErrorMessage(
                    'dlabel', 
                    'You must enter the label',
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).

    IF lc-dtype = "date" THEN
    DO:
        ASSIGN li-int = int(lc-dwarning) no-error.
        IF ERROR-STATUS:ERROR OR li-int < 0 THEN
        DO:
            RUN htmlib-AddErrorMessage(
                'dwarning', 
                'You must enter a numeric warning period',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        RETURN.

        END.
    END.
    ELSE 
    IF lc-dwarning <> "" THEN
    DO:
        RUN htmlib-AddErrorMessage(
                'dwarning', 
                'The warning period is only applicable to dates',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        RETURN.
    END.

   

    

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

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
    
    {lib/checkloggedin.i} 


     ASSIGN
        lc-classcode = get-value("classcode")
        lc-subcode   = get-value("subcode").

    FIND ivClass WHERE ROWID(ivClass) = to-rowid(lc-classcode) NO-LOCK NO-ERROR.
    FIND ivSub   WHERE ROWID(ivSub)   = to-rowid(lc-subcode)   NO-LOCK NO-ERROR.

    ASSIGN lc-mode = get-value("mode")
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

    ASSIGN lc-parameters = "search=" + lc-search +
                           "&firstrow=" + lc-firstrow + 
                           "&lastrow=" + lc-lastrow + 
                           "&classcode=" + lc-classcode + 
                           "&subcode=" + lc-subcode.
    ASSIGN
        lc-firstback = get-value("firstback").

    CASE lc-mode:
        WHEN 'add'
        THEN ASSIGN lc-title = 'Add'
                    lc-link-label = "Cancel addition"
                    lc-submit-label = "Add Custom Field".
        WHEN 'view'
        THEN ASSIGN lc-title = 'View'
                    lc-link-label = "Back"
                    lc-submit-label = "".
        WHEN 'delete'
        THEN ASSIGN lc-title = 'Delete'
                    lc-link-label = 'Cancel deletion'
                    lc-submit-label = 'Delete Custom Field'.
        WHEN 'Update'
        THEN ASSIGN lc-title = 'Update'
                    lc-link-label = 'Cancel update'
                    lc-submit-label = 'Update Custom Field'.
    END CASE.


    ASSIGN lc-title = lc-title + ' Custom Field - '
                + html-encode(ivClass.name) + " - " + 
                html-encode(ivSub.name)
           lc-link-url = appurl + '/sys/webinvfield.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&time=' + string(TIME) + 
                                  '&classcode=' + lc-classcode +
                                  '&subcode=' + lc-subcode +
                                  '&firstback=' + lc-firstback 
                           .

    IF CAN-DO("view,update,delete",lc-mode) THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
             NO-LOCK NO-ERROR.
        IF NOT AVAILABLE b-table THEN
        DO:
            set-user-field("mode",lc-mode).
            set-user-field("title",lc-title).
            set-user-field("nexturl",appurl + "/sys/webinvfield.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN
                lc-dlabel = get-value("dlabel")
                lc-dorder = get-value("dorder")
                lc-dtype  = get-value("dtype")
                lc-dMandatory = get-value("dmandatory")
                lc-dprompt = get-value("dprompt")
                lc-dWarning = get-value("dwarning").
            
               
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
                        b-table.ivSubId     = ivSub.ivSubId
                        lc-firstrow         = STRING(ROWID(b-table))
                           .
                    DO WHILE TRUE:
                        RUN lib/makeaudit.p (
                            "",
                            OUTPUT lf-audit
                            ).
                        IF CAN-FIND(FIRST ivField
                                    WHERE ivField.ivFieldID = lf-audit NO-LOCK)
                                    THEN NEXT.
                        ASSIGN
                            b-table.ivFieldID = lf-audit.
                        LEAVE.
                    END.
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.dOrder = int(lc-dorder)
                        b-table.dLabel = lc-dlabel
                        b-table.dType  = lc-dType
                        b-table.dPrompt = lc-dprompt
                        b-table.dMandatory = lc-dMandatory = "on"
                        b-table.dWarning   = int(lc-dwarning)
                    .
                   
                    
                END.
            END.
        END.
        ELSE
        DO:
            FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
                 EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            IF LOCKED b-table 
            THEN RUN htmlib-AddErrorMessage(
                                   'none', 
                                   'This record is locked by another user',
                                   INPUT-OUTPUT lc-error-field,
                                   INPUT-OUTPUT lc-error-msg ).
            ELSE DELETE b-table.
        END.

        IF lc-error-field = "" THEN
        DO:
            RUN outputHeader.
            set-user-field("navigation",'refresh').
            set-user-field("firstrow",lc-firstrow).
            set-user-field("search",lc-search).
            set-user-field("classcode",lc-classcode).
            set-user-field("subcode",lc-subcode).
            set-user-field("firstback",lc-firstback).
            RUN run-web-object IN web-utilities-hdl ("sys/webinvfield.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        

        IF CAN-DO("view,delete",lc-mode)
        OR request_method <> "post"
        THEN ASSIGN 
                lc-dorder = STRING(b-table.dorder)
                lc-dlabel = b-table.dlabel
                lc-dtype  = b-table.dtype
                lc-dmandatory = IF b-table.dmandatory THEN 'on' ELSE ''
                lc-dprompt    = b-table.dprompt
                lc-dwarning   = IF b-table.dType = "date"
                                THEN STRING(b-table.dWarning)
                                ELSE ""
                .
     
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/sys/webinvfieldmnt.p' )
           htmlib-ProgramTitle(lc-title) skip.

    {&out} htmlib-Hidden ("savemode", lc-mode) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip
           htmlib-Hidden ("nullfield", lc-navigation) skip.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    {&out} htmlib-StartInputTable() skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
           ( IF LOOKUP("dorder",lc-error-field,'|') > 0 
           THEN htmlib-SideLabelError("Order")
           ELSE htmlib-SideLabel("Order"))
           '</TD>' skip
           .

    {&out} '<TD VALIGN="TOP" ALIGN="left">'
           htmlib-InputField("dorder",10,lc-dorder) skip
           '</TD>'.
    

    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("dlabel",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Label")
            ELSE htmlib-SideLabel("Label"))
            '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-InputField("dlabel",40,lc-dlabel) 
            '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-dlabel),'left')
           skip.
    {&out} '</TR>' skip.

  
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("dtype",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Type")
            ELSE htmlib-SideLabel("Type"))
            '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-Select("dtype",lc-global-dtype,lc-global-dtype,lc-dtype) 
            '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(
        lc-dtype
        ),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
           ( IF LOOKUP("dwarning",lc-error-field,'|') > 0 
           THEN htmlib-SideLabelError("Warning Period")
           ELSE htmlib-SideLabel("Warning Period"))
           '</TD>' skip
           .

    IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-InputField("dwarning",3,lc-dwarning) 
            '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(
        lc-dwarning
        ),'left')
           skip.
    {&out} '</TR>' skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("dmandatory",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Mandatory?")
            ELSE htmlib-SideLabel("Mandatory?"))
            '</TD>'.
    
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-CheckBox("dmandatory", IF lc-dmandatory = 'on'
                                        THEN TRUE ELSE FALSE) 
            '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-dmandatory = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
           ( IF LOOKUP("dprompt",lc-error-field,'|') > 0 
           THEN htmlib-SideLabelError("Prompt")
           ELSE htmlib-SideLabel("Prompt"))
           '</TD>' skip
           .

    {&out} '<TD VALIGN="TOP" ALIGN="left">'
           htmlib-InputField("dprompt",60,lc-dprompt) skip
           '</TD>'.
    

    {&out} '</TR>' skip.

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
          
    {&out}
        htmlib-Hidden("classcode", lc-classcode) skip
        htmlib-Hidden("subcode", lc-subcode) skip
        htmlib-Hidden("firstback",lc-firstback) skip.

    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

