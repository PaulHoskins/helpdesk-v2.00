/***********************************************************************

    Program:        sys/slamnt.p
    
    Purpose:        SLA Maintenance      
    
    Notes:
    
    
    When        Who         What
    28/04/2006  phoski      Initial      
    15/05/2014  phoski      Amber Warning period
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


DEFINE BUFFER b-valid  FOR slahead.
DEFINE BUFFER b-table  FOR slahead.
DEFINE BUFFER Customer FOR Customer.


DEFINE VARIABLE lc-search        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters    AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url      AS CHARACTER NO-UNDO.


DEFINE VARIABLE lf-Audit         AS DECIMAL   NO-UNDO.
DEFINE VARIABLE lc-slacode       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-description   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-AccountNumber AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Notes         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-TimeBase      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-AlertBase     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-incSat        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-incSun        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-AmberWarning  AS CHARACTER NO-UNDO.


DEFINE VARIABLE li-loop          AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-respunit      LIKE slahead.respunit NO-UNDO.
DEFINE VARIABLE lc-respdesc      LIKE lc-respunit NO-UNDO.
DEFINE VARIABLE lc-resptime      LIKE lc-respunit NO-UNDO.
DEFINE VARIABLE lc-respaction    LIKE lc-respunit NO-UNDO.
DEFINE VARIABLE lc-respdest      LIKE lc-respunit NO-UNDO.




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

&IF DEFINED(EXCLUDE-ip-AlertTable) = 0 &THEN

PROCEDURE ip-AlertTable :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-loop         AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lc-object       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lc-value        AS CHARACTER     NO-UNDO.

    {&out}
    '<tr><td colspan=2>'.


    {&out} skip
           htmlib-StartFieldSet("SLA Alerts") 
           htmlib-StartMntTable().

    {&out}
    htmlib-TableHeading(
        "Level^right|Description^left|Unit^left|Time^left|Action^left|Alert To^left"
        ) skip.

    DO li-loop = 1 TO 10:
        {&out} '<tr class="tabrow1">'.

        {&out} '<th style="text-align: right; vertical-align: text-top;">'
        li-loop ":" '</th>'.

        IF CAN-DO("view,delete",lc-mode) THEN
        DO:
            {&out} 
            '<td>' html-encode(b-table.respdesc[li-loop]) '</td>'
            '<td>' html-encode(
                DYNAMIC-FUNCTION("com-DecodeLookup",b-table.respunit[li-loop],
                lc-global-respunit-code,
                lc-global-respunit-display)
                ) '</td>'
            '<td>' 
            IF b-table.resptime[li-loop] = 0
                THEN "&nbsp;" 
            ELSE html-encode(STRING(b-table.resptime[li-loop])) '</td>'
            '<td>' html-encode(
                DYNAMIC-FUNCTION("com-DecodeLookup",b-table.respaction[li-loop],
                lc-global-respaction-code,
                lc-global-respaction-display)
                ) '</td>'
            '<td>' html-encode(b-table.respdest[li-loop]) '</td>'
                .

        END.
        ELSE
        DO:
            ASSIGN 
                lc-object = "respdesc" + string(li-loop)
                lc-value  = get-value(lc-object).
            {&out} '<td>' htmlib-InputField(lc-object,20,lc-value) '</td>'.

            ASSIGN 
                lc-object = "respunit" + string(li-loop)
                lc-value  = get-value(lc-object).
            {&out} '<td>' htmlib-Select(lc-object,lc-global-respunit-code,lc-global-respunit-display,lc-value) '</td>'.

            ASSIGN 
                lc-object = "resptime" + string(li-loop)
                lc-value  = get-value(lc-object).
            {&out} '<td>' htmlib-InputField(lc-object,4,lc-value) '</td>'.

            ASSIGN 
                lc-object = "respaction" + string(li-loop)
                lc-value  = get-value(lc-object).
            {&out} '<td>' htmlib-Select(lc-object,lc-global-respaction-code,lc-global-respaction-display,lc-value) '</td>'.

            ASSIGN 
                lc-object = "respdest" + string(li-loop)
                lc-value  = get-value(lc-object).
            {&out} '<td>' htmlib-InputField(lc-object,30,lc-value) '</td>'.



        END.

        {&out} '</tr>'.
    END.
    {&out} skip 
           htmlib-EndTable()
           htmlib-EndFieldSet() 
           skip.

    {&out} '</td></tr>'.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      emails:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.

    DEFINE VARIABLE lf-dec      AS DECIMAL          NO-UNDO.
    DEFINE VARIABLE li-index    AS INTEGER          NO-UNDO.
    DEFINE VARIABLE lc-char     AS CHARACTER         NO-UNDO.
    DEFINE VARIABLE li-int      AS INTEGER          NO-UNDO.

    DEFINE BUFFER webuser  FOR webuser.

    IF lc-mode = "ADD":U THEN
    DO:
        IF lc-slacode = ""
            OR lc-slacode = ?
            THEN RUN htmlib-AddErrorMessage(
                'slacode', 
                'You must enter the SLA code',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        

        IF CAN-FIND(FIRST b-valid
            WHERE b-valid.slacode = lc-slacode
            AND b-valid.companycode = lc-global-company
            AND b-valid.AccountNumber = lc-accountnumber
            NO-LOCK)
            THEN RUN htmlib-AddErrorMessage(
                'slacode', 
                'This SLA code already exists',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        IF lc-accountnumber <> "" THEN
        DO:
            IF NOT CAN-FIND(customer WHERE customer.companycode = lc-global-company
                AND customer.AccountNumber = lc-accountNumber NO-LOCK)
                THEN RUN htmlib-AddErrorMessage(
                    'accountnumber', 
                    'This customer does not exist',
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).
            ELSE
                IF NOT CAN-FIND(FIRST b-valid
                    WHERE b-valid.slacode = lc-slacode
                    AND b-valid.companycode = lc-global-company
                    AND b-valid.AccountNumber = ""
                    NO-LOCK)
                    THEN RUN htmlib-AddErrorMessage(
                        'slacode', 
                        'This SLA code does not exist, a default must exist before creating a customer SLA',
                        INPUT-OUTPUT pc-error-field,
                        INPUT-OUTPUT pc-error-msg ).
        END.
    END.

    IF lc-description = ""
        OR lc-description = ?
        THEN RUN htmlib-AddErrorMessage(
            'description', 
            'You must enter the description',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    ASSIGN
        li-int = INT(lc-amberWarning) NO-ERROR.

    IF ERROR-STATUS:ERROR 
        OR li-int < 0 
        OR li-int = ? 
        THEN RUN htmlib-AddErrorMessage(
            'amberwarning', 
            'Amber warning period is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    DO li-loop = 1 TO 10:
        /*
        ***
        *** if description is blank then all other resp stuff
        *** should be as well
        ***
        */
        IF lc-respdesc[li-loop] = "" THEN
        DO:
            IF lc-respunit[li-loop] <> "none"
                OR lc-resptime[li-loop] <> ""
                OR lc-respaction[li-loop] <> "none" 
                OR lc-respdest[li-loop] <> "" 
                THEN RUN htmlib-AddErrorMessage(
                    'null', 
                    'Alert ' + string(li-loop) + 
                    ': All fields should be blank or set to none if the level is not used',
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).
        END.
        ELSE
        DO:
            IF li-loop > 1 THEN
            DO: 
                IF lc-respdesc[li-loop - 1] = "" 
                    THEN RUN htmlib-AddErrorMessage(
                        'null', 
                        'Alert ' + string(li-loop) + 
                        ': The previous level is blank, you can not have unused levels between used levels',
                        INPUT-OUTPUT pc-error-field,
                        INPUT-OUTPUT pc-error-msg ).
                NEXT.
            END.
            IF lc-respunit[li-loop] = "none" 
                THEN RUN htmlib-AddErrorMessage(
                    'null', 
                    'Alert ' + string(li-loop) + 
                    ': If this level is used you must select a unit',
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).

            ASSIGN
                lf-dec = dec(lc-resptime[li-loop]) no-error.
            IF ERROR-STATUS:ERROR 
                OR lf-dec < 1
                OR TRUNCATE(lf-dec,0) <> lf-dec 
                THEN RUN htmlib-AddErrorMessage(
                    'null', 
                    'Alert ' + string(li-loop) + 
                    ': If this level is used you must enter an integer time above zero',
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).
            IF lc-respaction[li-loop] = "none" 
                THEN RUN htmlib-AddErrorMessage(
                    'null', 
                    'Alert ' + string(li-loop) + 
                    ': If this level is used you must select an action',
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).
            /*if lc-respdest[li-loop] = "" 
            then run htmlib-AddErrorMessage(
                    'null', 
                    'Alert ' + string(li-loop) + 
                    ': If this level is used you must select one or more users to alert',
                    input-output pc-error-field,
                    input-output pc-error-msg ).
            else
            */
            IF lc-respdest[li-loop] <> "" THEN
            DO li-index = 1 TO NUM-ENTRIES(lc-respdest[li-loop]):

                ASSIGN 
                    lc-char = TRIM(ENTRY(li-index,lc-respdest[li-loop])).
                IF lc-char = "" THEN
                DO:
                    RUN htmlib-AddErrorMessage(
                        'null', 
                        'Alert ' + string(li-loop) + 
                        ': You can not have blank entries in the alert destination entry',
                        INPUT-OUTPUT pc-error-field,
                        INPUT-OUTPUT pc-error-msg ).
                END.

                FIND webuser
                    WHERE webuser.loginid = lc-char NO-LOCK NO-ERROR.
                IF NOT AVAILABLE webuser 
                    OR webuser.CompanyCode <> lc-global-company
                    THEN RUN htmlib-AddErrorMessage(
                        'null', 
                        'Alert ' + string(li-loop) + 
                        ': The user ' + lc-char + ' does not exist',
                        INPUT-OUTPUT pc-error-field,
                        INPUT-OUTPUT pc-error-msg ).
                ELSE 
                    IF webuser.UserClass = "CUSTOMER" 
                        THEN RUN htmlib-AddErrorMessage(
                            'null', 
                            'Alert ' + string(li-loop) + 
                            ': The user ' + lc-char + ' is a customer, you can not send SLA alerts to them',
                            INPUT-OUTPUT pc-error-field,
                            INPUT-OUTPUT pc-error-msg ).

            END.


        END.
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
                lc-submit-label = "Add SLA".
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
                lc-submit-label = 'Delete SLA'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update SLA'.
    END CASE.


    ASSIGN 
        lc-title = lc-title + ' SLA'
        lc-link-url = appurl + '/sys/sla.p' + 
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
            set-user-field("nexturl",appurl + "/sys/sla.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-slacode       = get-value("slacode")
                lc-description   = get-value("description")
                lc-notes         = get-value("notes")
                lc-accountnumber = get-value("accountnumber")
                lc-TimeBase      = get-value("timebase")
                lc-incSat        = get-value("incsat")
                lc-incSun        = get-value("incsun")
                lc-AlertBase     = get-value("alertbase")
                lc-amberWarning  = get-value("amberwarning")
                .
  
            DO li-loop = 1 TO 10:
                ASSIGN 
                    lc-respdesc[li-loop] = get-value("respdesc" + string(li-loop))
                    lc-respunit[li-loop] = get-value("respunit" + string(li-loop))
                    lc-resptime[li-loop] = get-value("resptime" + string(li-loop))
                    lc-respaction[li-loop] = get-value("respaction" + string(li-loop))
                    lc-respdest[li-loop] = get-value("respdest" + string(li-loop))
                    .
            END.
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
                        b-table.slacode = CAPS(lc-slacode)
                        b-table.companycode = lc-global-company
                        b-table.AccountNumber = CAPS(lc-accountNumber)
                        lc-firstrow      = STRING(ROWID(b-table))
                        .
                    DO WHILE TRUE:
                        RUN lib/makeaudit.p (
                            "",
                            OUTPUT lf-audit
                            ).
                        IF CAN-FIND(FIRST slaHead
                            WHERE slaHead.SLAID = lf-audit NO-LOCK)
                            THEN NEXT.
                        ASSIGN
                            b-table.SLAID = lf-audit.
                        LEAVE.
                    END.
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.description     = lc-description
                        b-table.notes           = lc-notes  
                        b-table.TimeBase        = lc-TimeBase
                        b-table.AlertBase       = lc-AlertBase
                        b-table.incSat          = lc-incsat = "on"
                        b-table.incSun          = lc-incSun = "on"
                        b-table.AmberWarning    = INT(lc-amberWarning)
                        .
                   
                    DO li-loop = 1 TO 10:
                        IF lc-respdesc[li-loop] = "" 
                            THEN ASSIGN
                                b-table.respdesc[li-loop] = ""
                                b-table.respunit[li-loop] = ""
                                b-table.resptime[li-loop] = 0
                                b-table.respaction[li-loop] = ""
                                b-table.respdest[li-loop] = "".
                        ELSE ASSIGN
                                b-table.respdesc[li-loop] = lc-respdesc[li-loop]
                                b-table.respunit[li-loop] = lc-respunit[li-loop]
                                b-table.resptime[li-loop] = int(lc-resptime[li-loop])
                                b-table.respaction[li-loop] = lc-respaction[li-loop]
                                b-table.respdest[li-loop] = lc-respdest[li-loop].


                    END.
                    RELEASE b-table.    
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
            ELSE DELETE b-table.
        END.

        IF lc-error-field = "" THEN
        DO:
            RUN outputHeader.
            set-user-field("navigation",'refresh').
            set-user-field("firstrow",lc-firstrow).
            set-user-field("search",lc-search).
            RUN run-web-object IN web-utilities-hdl ("sys/sla.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        ASSIGN 
            lc-slacode = b-table.slacode
            lc-AccountNumber = b-table.AccountNumber.

        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post" THEN 
        DO:
            ASSIGN 
                lc-description   = b-table.description
                lc-notes         = b-table.notes
                lc-accountnumber = b-table.AccountNumber
                lc-timeBase      = b-table.TimeBase
                lc-AlertBase     = b-table.AlertBase
                lc-incSun        = IF b-table.incsun THEN "on" ELSE ""
                lc-incSat        = IF b-table.incsat THEN "on" ELSE ""
                lc-AmberWarning  = STRING(b-table.AmberWarning)
                .
            DO li-loop = 1 TO 10:
                IF b-table.respdesc[li-loop] = "" THEN NEXT.
                ASSIGN
                    lc-respdesc[li-loop] = b-table.respdesc[li-loop] 
                    lc-respunit[li-loop] = b-table.respunit[li-loop] 
                    lc-resptime[li-loop] = STRING(b-table.resptime[li-loop]) 
                    lc-respaction[li-loop] = b-table.respaction[li-loop]
                    lc-respdest[li-loop] = b-table.respdest[li-loop].
                set-user-field("respdesc" + string(li-loop),lc-respdesc[li-loop]).
                set-user-field("respunit" + string(li-loop),lc-respunit[li-loop]).
                set-user-field("resptime" + string(li-loop),lc-resptime[li-loop]).
                set-user-field("respaction" + string(li-loop),lc-respaction[li-loop]).
                set-user-field("respdest" + string(li-loop),lc-respdest[li-loop]).


            END.
        END.
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", appurl + '/sys/slamnt.p' )
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
        ( IF LOOKUP("slacode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("SLA Code")
        ELSE htmlib-SideLabel("SLA Code"))
    '</TD>' skip
    .

    IF lc-mode = "ADD" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("slacode",20,lc-slacode) skip
           '</TD>'.
    else
    {&out} htmlib-TableField(html-encode(lc-slacode),'left')
           skip.


    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("description",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Description")
        ELSE htmlib-SideLabel("Description"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("description",40,lc-description) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-description),'left')
           skip.
    {&out} '</TR>' skip.
    
    IF lc-mode = "ADD" THEN
    DO:
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            ( IF LOOKUP("accountnumber",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Account Number")
            ELSE htmlib-SideLabel("Account Number"))
        '</TD>' skip
        .

        {&out} 
        '<TD VALIGN="TOP" ALIGN="left">'
        '<input class="inputfield" name="accountnumber" size="8" value="' get-value("accountnumber") '"' skip
                'onBlur="javascript:AjaxSimpleDescription(this,~'' appurl '~',~'' lc-global-company '~',~'accountnumber~',~'customername~');"'
                '>'
                
                skip(2)
                htmlib-ALookup("accountnumber","nullfield",appurl + '/lookup/customer.p')
                skip(2)
                '<span id="customername" class="reffield">&nbsp;</span>'
            '</TD>'.
        {&out} '</TR>' skip.
    END.
    ELSE
        IF lc-accountNumber <> "" 
            AND CAN-FIND(customer WHERE customer.companycode = lc-global-company
            AND customer.AccountNumber = lc-AccountNumber
            NO-LOCK) THEN
        DO:
            FIND customer 
                WHERE customer.CompanyCode = lc-global-company
                AND customer.AccountNumber = lc-AccountNumber
                NO-LOCK NO-ERROR.
            {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
                ( IF LOOKUP("accountnumber",lc-error-field,'|') > 0 
                THEN htmlib-SideLabelError("Account Number")
                ELSE htmlib-SideLabel("Account Number"))
            '</TD>'
            htmlib-TableField(html-encode(lc-accountnumber + " " + customer.name),'left')
            '</tr>'
               skip.
        END.

   

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("timebase",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("SLA Covers")
        ELSE htmlib-SideLabel("SLA Covers"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("timebase",lc-global-tbase-code,lc-global-tbase-display,lc-timebase)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(dynamic-function("com-DecodeLookup",lc-timebase,
                                     lc-global-tbase-code,
                                     lc-global-tbase-display
                                     ),'left')
           skip.
    {&out} '</TR>' skip.

    


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("incsat",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("SLA Covers Saturdays?")
        ELSE htmlib-SideLabel("SLA Covers Saturdays?"))
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("incsat", IF lc-incsat = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-incsat = 'on'
                                       then 'yes' else 'no'),'left')
         skip.

    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("incsun",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("SLA Covers Sundays?")
        ELSE htmlib-SideLabel("SLA Covers Sundays?"))
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("incsun", IF lc-incsun = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-incsun = 'on'
                                       then 'yes' else 'no'),'left')
         skip.

    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("alertbase",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("SLA Alerts Time Based On")
        ELSE htmlib-SideLabel("SLA Alerts Time Based On"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("alertbase",lc-global-abase-code,lc-global-abase-display,lc-alertbase)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(dynamic-function("com-DecodeLookup",lc-alertbase,
                                     lc-global-abase-code,
                                     lc-global-abase-display
                                     ),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("amberwarning",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Amber Warning (Minutes)")
        ELSE htmlib-SideLabel("Amber Warning (Minutes)"))
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("amberwarning",4,lc-amberwarning) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-amberwarning),'left')
           skip.
    {&out} '</TR>' skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("notes",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Note")
        ELSE htmlib-SideLabel("Note"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-TextArea("notes",lc-notes,5,60)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(replace(html-encode(lc-notes),"~n",'<br>'),'left')
           skip.
    {&out} '</TR>' skip.


    RUN ip-AlertTable.

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

