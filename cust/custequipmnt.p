/***********************************************************************

    Program:        cust/custequipmnt.p
    
    Purpose:        Customer Inventory   
    
    Notes:
    
    
    When        Who         What
    30/07/2006  phoski      Initial
    23/10/2015  phoski      create and update audits
    23/02/2016  phoski      isDecom flag    
    
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


DEFINE BUFFER customer  FOR customer.
DEFINE BUFFER CustField FOR CustField.
DEFINE BUFFER b-valid   FOR CustIV.
DEFINE BUFFER b-table   FOR CustIV.


DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-customer     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-returnback   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submitsource AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-class   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-Name    AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-ref          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ivClass      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-decom        AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop         AS INTEGER   NO-UNDO.

DEFINE TEMP-TABLE tu NO-UNDO
    FIELD upd-by AS CHARACTER
    FIELD upd-datetime AS DATETIME
    INDEX prim upd-datetime.
    
DEFINE TEMP-TABLE tt NO-UNDO
    FIELD ivFieldID LIKE ivField.ivFieldID
    FIELD FieldData LIKE custField.FieldData
    INDEX ivFieldID 
    ivFieldId.
DEFINE VARIABLE lf-CustIVID LIKE custField.CustIVID NO-UNDO.
DEFINE VARIABLE lc-Enc-Key  AS CHARACTER NO-UNDO.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-fnSelectClass) = 0 &THEN

FUNCTION fnSelectClass RETURNS CHARACTER
    ( pc-htm AS CHARACTER )  FORWARD.


&ENDIF


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

&IF DEFINED(EXCLUDE-ip-GetClass) = 0 &THEN

PROCEDURE ip-GetClass :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-Code AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name AS CHARACTER NO-UNDO.

    
    DEFINE BUFFER ivClass  FOR IvClass.
    DEFINE BUFFER ivSub    FOR ivSub.


    ASSIGN 
        pc-Code = htmlib-Null()
        pc-Name          = "Select Inventory".


    FOR EACH ivClass NO-LOCK
        WHERE ivClass.CompanyCode = lc-global-company
        ,
        EACH IvSub OF ivClass NO-LOCK
        BY ivClass.name:

        ASSIGN 
            pc-Code = pc-Code + '|' + "C" + string(ivSub.ivSubid)
            pc-Name          = pc-Name + '|' + 
                                  ivClass.name + " - " + ivSub.name.

    END.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-GetCurrent) = 0 &THEN

PROCEDURE ip-GetCurrent :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER ivField      FOR ivField.
    DEFINE BUFFER CustField    FOR CustField.
    DEFINE VARIABLE lc-object       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lc-value        AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lf-ivSubID      AS DECIMAL      NO-UNDO.

    
    FOR EACH ivField OF ivSub NO-LOCK
        BY ivField.dOrder
        BY ivField.dLabel:
    
        
        ASSIGN 
            lc-object = "FLD" + string(ivField.ivFieldID).
        ASSIGN 
            lc-value = "".

        FIND CustField
            WHERE CustField.CustIVID = b-table.CustIvID
            AND CustField.ivFieldId = ivField.ivFieldID
            NO-LOCK NO-ERROR.

        set-user-field(lc-object,IF AVAILABLE CustField THEN CustField.FieldData ELSE "").
  
    
    END.
              

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-InventoryTable) = 0 &THEN

PROCEDURE ip-InventoryTable :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER ivClass      FOR ivClass.
    DEFINE BUFFER ivSub        FOR ivSub.
    DEFINE BUFFER ivField      FOR ivField.
    DEFINE VARIABLE lc-object       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lc-value        AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lf-ivSubID      AS DECIMAL      NO-UNDO.

    {&out}
    '<tr><td colspan=2>'.


    {&out} skip
           htmlib-StartFieldSet("Inventory Details") 
           htmlib-StartMntTable().

    {&out}
    htmlib-TableHeading(
        "^right|Details^left|Notes^left"
        ) skip.

    IF lc-ivClass BEGINS "C" THEN
    DO:
        ASSIGN
            lf-ivSubId = dec(substr(lc-ivClass,2)).

        FIND ivSub WHERE ivSub.ivSubID = lf-ivSubId NO-LOCK NO-ERROR.

        IF AVAILABLE ivSub AND CAN-FIND(ivClass OF ivSub NO-LOCK) THEN
        DO:
            FIND ivClass OF ivSub NO-LOCK NO-ERROR.
            FOR EACH ivField OF ivSub NO-LOCK
                BY ivField.dOrder
                BY ivField.dLabel:

                {&out} '<tr class="tabrow1">'.

                {&out} '<th style="text-align: right; vertical-align: text-top;">'
                html-encode(ivField.dLabel + ":").

                IF ivField.dMandatory AND can-do("add,update",lc-mode)
                    THEN {&out} '<br><span style="font-size: 8px;">Mandatory</span>'.
                {&out}
                '</th>'.

                ASSIGN 
                    lc-object = "FLD" + string(ivField.ivFieldID).
                ASSIGN 
                    lc-value = get-value(lc-object).

                IF CAN-DO("view,delete",lc-mode) THEN 
                DO:
                    {&out} htmlib-MntTableField(REPLACE(html-encode(lc-value),"~n","<br>"),'left') skip.
                END.
                ELSE
                DO:
                    {&out} '<td>' skip.

                    CASE ivField.dType:
                        WHEN "TEXT" THEN
                            DO:
                                {&out} htmlib-InputField(lc-object,40,lc-value).
                            END.
                        WHEN "DATE" THEN
                            DO:
                                {&out} htmlib-InputField(lc-object,10,lc-value).
                            END.
                        WHEN "NUMBER" THEN
                            DO:
                                {&out} htmlib-InputField(lc-object,10,lc-value).
                            END.
                        WHEN "YES/NO" THEN
                            DO:
                                {&out} htmlib-Select(lc-object,"Yes|No","Yes|No",IF lc-value = "" THEN "Yes" ELSE lc-value).
                            END.
                        WHEN "NOTE" THEN
                            DO:
                                {&out} htmlib-TextArea(lc-object,lc-value,5,40).
                            END.
                        OTHERWISE
                        DO:
                            {&out} html-encode('Error - type ' + ivField.dType + ' unknown').
                        END.

                    END CASE.
                    {&out} '</td>' skip.

                END.
                {&out} htmlib-MntTableField(html-encode(ivField.dPrompt),'left') skip.





                {&out} '</tr>' skip.
            END.
        END.

    END.

    {&out} skip 
           htmlib-EndTable()
           htmlib-EndFieldSet() 
           skip.

    {&out} '</td></tr>'.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-JavaScript) = 0 &THEN

PROCEDURE ip-JavaScript :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    {&out} skip 
          '<script language="JavaScript">' skip.

    {&out} skip
        'function ChangeClass() ~{' skip
        '   SubmitThePage("ClassChange")' skip
        '~}' skip.

      
    {&out} skip
           '</script>' skip.
    {&out} htmlib-JScript-Maintenance() skip.
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

    DEFINE BUFFER ivClass      FOR ivClass.
    DEFINE BUFFER ivSub        FOR ivSub.
    DEFINE BUFFER ivField      FOR ivField.
    DEFINE VARIABLE lc-object       AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lc-value        AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lf-ivSubID      AS DECIMAL      NO-UNDO.
    DEFINE VARIABLE ld-date         AS DATE     NO-UNDO.
    DEFINE VARIABLE lf-number       AS DECIMAL      NO-UNDO.

    
    IF lc-ivClass = htmlib-Null() 
        THEN RUN htmlib-AddErrorMessage(
            'ivclass', 
            'You must select the inventory type',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    
    IF lc-ref = ""
        OR lc-ref = ?
        THEN RUN htmlib-AddErrorMessage(
            'ref', 
            'You must enter the reference',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
 
    EMPTY TEMP-TABLE tt.

    IF lc-ivClass <> htmlib-Null() THEN
    DO:
        ASSIGN
            lf-ivSubId = dec(substr(lc-ivClass,2)).

        FIND ivSub WHERE ivSub.ivSubID = lf-ivSubId NO-LOCK NO-ERROR.

        IF AVAILABLE ivSub AND CAN-FIND(ivClass OF ivSub NO-LOCK) THEN
        DO:
            FIND ivClass OF ivSub NO-LOCK NO-ERROR.
            FOR EACH ivField OF ivSub NO-LOCK
                BY ivField.dOrder
                BY ivField.dLabel:

                
                
                ASSIGN 
                    lc-object = "FLD" + string(ivField.ivFieldID).
                ASSIGN 
                    lc-value = get-value(lc-object).

                CREATE tt.
                ASSIGN 
                    tt.ivFieldID = ivField.ivFieldID
                    tt.FieldData = lc-value.

                IF lc-value = "" AND ivField.dMandatory 
                    THEN RUN htmlib-AddErrorMessage(
                        lc-object, 
                        'The inventory field ' + html-encode(ivField.dLabel) + ' is mandatory',
                        INPUT-OUTPUT pc-error-field,
                        INPUT-OUTPUT pc-error-msg ).
                ELSE
                    IF lc-value <> "" THEN
                        CASE ivField.dType:
                            WHEN "DATE" THEN
                                DO:
                                    ASSIGN
                                        ld-date = DATE(lc-value) no-error.
                                    IF ERROR-STATUS:ERROR 
                                        THEN RUN htmlib-AddErrorMessage(
                                            lc-object, 
                                            'The inventory field ' + html-encode(ivField.dLabel) + ' is not a valid date',
                                            INPUT-OUTPUT pc-error-field,
                                            INPUT-OUTPUT pc-error-msg ).
                                    ELSE ASSIGN tt.FieldData = STRING(ld-date,"99/99/9999").
                        
                                END.
                            WHEN "NUMBER" THEN
                                DO:
                                    ASSIGN
                                        lf-number = dec(lc-value) no-error.
                                    IF ERROR-STATUS:ERROR 
                                        THEN RUN htmlib-AddErrorMessage(
                                            lc-object, 
                                            'The inventory field ' + html-encode(ivField.dLabel) + ' is not a valid number',
                                            INPUT-OUTPUT pc-error-field,
                                            INPUT-OUTPUT pc-error-msg ).
                                    ELSE ASSIGN tt.FieldData = STRING(lf-number).
                        
                                END.
                    

                        END CASE.
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

    ASSIGN 
        lc-mode = get-value("mode")
        lc-rowid = get-value("rowid")
        lc-search = get-value("search")
        lc-firstrow = get-value("firstrow")
        lc-lastrow  = get-value("lastrow")
        lc-navigation = get-value("navigation")
        lc-customer   = get-value("customer")
        lc-returnback = get-value("returnback").

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
                lc-submit-label = "Add Inventory".
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
                lc-submit-label = 'Delete Inventory'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Inventory'.
    END CASE.


    FIND customer WHERE ROWID(customer) = to-rowid(lc-customer)
        NO-LOCK NO-ERROR.
    ASSIGN 
        lc-enc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"customer",STRING(ROWID(customer))).
                 

    RUN ip-GetClass ( OUTPUT lc-list-class, OUTPUT lc-list-Name ).

    ASSIGN 
        lc-title = lc-title + ' Customer Inventory'
        lc-link-url = appurl + '/cust/custequip.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&customer=' + lc-customer +
                                  '&returnback=' + lc-returnback +
                                  '&' + htmlib-RandomURL()
        .

    IF lc-returnback = "renewal"
        THEN ASSIGN lc-link-url = appurl + "/cust/ivrenewal.p".
    ELSE 
        IF lc-returnback = "customerview" 
            THEN ASSIGN lc-link-url = appurl + "/cust/custview.p?source=menu&rowid=" + url-encode(lc-enc-key,"Query").

    IF CAN-DO("view,update,delete",lc-mode) THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE b-table THEN
        DO:
            set-user-field("mode",lc-mode).
            set-user-field("title",lc-title).
            set-user-field("nexturl",appurl + "/cust/custequip.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.
        
        FIND ivSub OF b-table NO-LOCK NO-ERROR.
        FIND ivClass OF ivSub NO-LOCK NO-ERROR.

        set-user-field("inventory",
            ivClass.name + " - " + ivSub.name).
        ASSIGN 
            lc-ivClass = "C" + string(b-table.ivSubID).

        set-user-field("ivclass",lc-ivClass).
        IF request_method = "GET"
            OR lc-mode = "VIEW"
            THEN RUN ip-GetCurrent.
    END.


    IF request_method = "POST" THEN
    DO:
        ASSIGN
            lc-submitsource = get-value("submitsource").
        IF lc-submitsource <> "ClassChange" THEN
        DO:
        
            IF lc-mode <> "delete" THEN
            DO:
                ASSIGN 
                    lc-ref          = get-value("ref")
                    lc-ivclass      = get-value("ivclass")
                    lc-decom        = get-value("decom")
                    .
                
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
                            b-table.accountnumber = customer.accountnumber
                            b-table.CompanyCode   = customer.CompanyCode
                            b-table.CustIvID      = ?
                            b-table.ivSubID       = dec(substr(lc-ivclass,2))
                            b-table.crt-by        = lc-global-user
                            b-table.crt-datetime  = NOW
                            lc-firstrow           = STRING(ROWID(b-table)).
                        DO WHILE TRUE:
                            RUN lib/makeaudit.p (
                                "",
                                OUTPUT lf-custIVID
                                ).
                            IF CAN-FIND(FIRST CustIV
                                WHERE CustIV.CustIvID = lf-custIVID NO-LOCK)
                                THEN NEXT.
                            ASSIGN
                                b-table.CustIvID = lf-CustIvID.
                            LEAVE.
                        END.
                       
                    END.
                    
                    ASSIGN 
                        b-table.ref = lc-ref
                        b-table.isDecom = lc-decom = "on"
                        .
                    /* 
                    ***
                    *** Last 10 inventory updates
                    ***
                    */
                    IF lc-mode = "update" THEN
                    DO:
                        EMPTY TEMP-TABLE tu.
                        DO li-loop = 1 TO EXTENT(b-table.upd-by):
                            IF b-table.upd-by[li-loop] = "" THEN NEXT.
                            CREATE tu.
                            ASSIGN 
                                tu.upd-by = b-table.upd-by[li-loop]
                                tu.upd-datetime = b-table.upd-datetime[li-loop].
                                
                        END. 
                        CREATE tu.
                        ASSIGN 
                            tu.upd-by = lc-global-user
                            tu.upd-datetime = NOW.
                        ASSIGN li-loop = 0.
                        FOR EACH tu BY tu.upd-datetime DESCENDING:
                            ASSIGN li-loop = li-loop + 1.
                            IF li-loop > EXTENT(b-table.upd-by) THEN LEAVE.
                            ASSIGN 
                                b-table.upd-by[li-loop] = tu.upd-by 
                                b-table.upd-datetime[li-loop] = tu.upd-datetime.
                                
                        END.
                                     
                            
                    END.
                    
                    FOR EACH CustField OF b-table EXCLUSIVE-LOCK:
                        DELETE CustField.
                    END.
                    FOR EACH tt:
                        CREATE CustField.
                        BUFFER-COPY tt TO CustField
                            ASSIGN 
                            CustField.CustIvID = b-table.CustIvID.
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
                    FOR EACH CustField OF b-table EXCLUSIVE-LOCK:
                        DELETE CustField.
                    END.
                    DELETE b-table.
                END.
            END.

            IF lc-error-field = "" THEN
            DO:
                IF lc-returnback = "renewal" THEN
                DO:
                    RUN run-web-object IN web-utilities-hdl ("cust/ivrenewal.p").
                    RETURN.
                END.
                ELSE
                    IF lc-returnback = "customerview" THEN
                    DO:
                        set-user-field("source","menu").
                        set-user-field("rowid",lc-enc-key).
                        RUN run-web-object IN web-utilities-hdl ("cust/custview.p").
                        RETURN.
                    END.
                set-user-field("navigation",'refresh').
                set-user-field("firstrow",lc-firstrow).
                set-user-field("search",lc-search).
                RUN run-web-object IN web-utilities-hdl ("cust/custequip.p").
                RETURN.
            END.
        
        END.

        
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        
        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post" THEN 
        DO:
            ASSIGN 
                lc-ref      = b-table.ref
                lc-decom    = IF b-table.isDecom THEN "on" ELSE ""
                .
            
        END.
        ELSE ASSIGN lc-ivClass = "C" + string(b-table.ivSubID).
       
    END.
    ELSE
    DO:
        IF request_method = "POST" 
            THEN ASSIGN lc-ivClass = get-value("ivclass").
    END.


    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip.
    RUN ip-JavaScript.


    {&out}
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
        (IF LOOKUP("ivclass",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Inventory Type")
        ELSE htmlib-SideLabel("Inventory Type"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left">'.

    IF lc-mode = "ADD" 
        THEN {&out} fnSelectClass(htmlib-Select("ivclass",lc-list-class,lc-list-Name,
        lc-ivclass)) skip.
    else {&out} html-encode(get-value("inventory")).

    {&out}
    '</TD></TR>' skip. 

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("ref",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Reference")
        ELSE htmlib-SideLabel("Reference"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("ref",40,lc-ref) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-ref),'left')
           skip.
    {&out} '</TR>' skip.

      {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("decom",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Decommissioned?")
        ELSE htmlib-SideLabel("Decommissioned?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("decom",lc-decom = "on") 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(IF lc-decom = "on" THEN "Yes" ELSE "No"),'left')
           skip.
    {&out} '</TR>' skip.
    
    RUN ip-InventoryTable.

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
         
    {&out} skip
           htmlib-Hidden("customer",lc-customer) skip
           htmlib-Hidden("returnback",lc-returnback) skip
           htmlib-hidden("submitsource","") skip.
   
    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-fnSelectClass) = 0 &THEN

FUNCTION fnSelectClass RETURNS CHARACTER
    ( pc-htm AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

    lc-htm = REPLACE(pc-htm,'<select',
        '<select onChange="ChangeClass()"'). 


    RETURN lc-htm.


END FUNCTION.


&ENDIF

