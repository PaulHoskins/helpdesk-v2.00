/***********************************************************************

    Program:        crm/crmloadmnt.p
    
    Purpose:        Maintain CRM Dataset        
    
    Notes:
    
    
    When        Who         What
    03/09/2016  phoski      Initial      
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


DEFINE BUFFER b-valid FOR crm_data_load.
DEFINE BUFFER b-table FOR crm_data_load.


DEFINE VARIABLE lc-search       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.



DEFINE VARIABLE lc-description  AS CHARACTER NO-UNDO.





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



    IF lc-description = ""
        OR lc-description = ?
        THEN RUN htmlib-AddErrorMessage(
            'description', 
            'You must enter the description',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

PROCEDURE ipViewAcc:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-loop     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-cont     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-url      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-count    AS INTEGER   NO-UNDO.
    
    {&out} '<div class="infobox">Sections&nbsp;<a name="top"></a>' SKIP.
    DO li-loop = 1 TO NUM-ENTRIES(lc-global-CRMRS-Code,"|"):
        ASSIGN
            li-count = 0.
        FOR EACH crm_data_acc NO-LOCK OF b-table
            WHERE crm_data_acc.record_status = ENTRY(li-loop,lc-global-CRMRS-Code,"|"):
            ASSIGN 
                li-count = li-count + 1.
        END.
        lc-url = com-DecodeLookup(ENTRY(li-loop,lc-global-CRMRS-Code,"|"),lc-global-CRMRS-Code,lc-global-CRMRS-Desc) + " - [" + string(li-count) + "]".
        {&out}
        '<a class=tlink href="#' + ENTRY(li-loop,lc-global-CRMRS-Code,"|") + '">' lc-url '</a>&nbsp;' SKIP.                
    END.
    
    {&out} '</div>'.
    
    {&out} SKIP
           htmlib-StartMntTable().

    {&out}
    htmlib-TableHeading(
        "|ID|Name|Address 1|Address 2|City|County|Post Code|Telephone|Business Type|Contact Details|Position"
        ) SKIP.
    DO li-loop = 1 TO NUM-ENTRIES(lc-global-CRMRS-Code,"|"):
            
        {&out} '<tr><td colspan=12><div class="infobox">'
        '<a name="'  ENTRY(li-loop,lc-global-CRMRS-Code,"|") '"></a>' SKIP
        '<a href="#top"><img src="/asset/img/up_16.gif"></a>' SKIP
        com-DecodeLookup(ENTRY(li-loop,lc-global-CRMRS-Code,"|"),lc-global-CRMRS-Code,lc-global-CRMRS-Desc)
        '</div</td></tr>' SKIP.
        
        FOR EACH crm_data_acc NO-LOCK OF b-table
            WHERE crm_data_acc.record_status = ENTRY(li-loop,lc-global-CRMRS-Code,"|")
            BY crm_data_acc.Name
            :
              
              
            IF crm_data_acc.record_status =  lc-global-CRMRS-ACC-CRT 
                THEN lc-url = "".
            ELSE ASSIGN
                    lc-url = appurl + "/crm/crmloadedit.p?rowid=" + string(ROWID(crm_data_acc)) + "&mode=update&parent=" +  string(ROWID(b-table)).
           
            ASSIGN
                lc-cont = crm_data_acc.contact_title + " " + crm_data_acc.contact_forename + " " + crm_data_acc.contact_surname.
                 
                               
            {&out}
            '<tr>'
            '<td>' 
            IF lc-url <> "" THEN htmlib-ImageLink('/images/toolbar/update.gif',lc-url,"Update " + crm_data_acc.name) 
            ELSE '&nbsp;' '</td>' SKIP
                htmlib-MntTableField(html-encode( crm_data_acc.accid),'left')
                
                htmlib-MntTableField(html-encode( crm_data_acc.Name),'left')
                htmlib-MntTableField(html-encode( crm_data_acc.Address1),'left')
                htmlib-MntTableField(html-encode( crm_data_acc.Address2),'left')
                htmlib-MntTableField(html-encode( crm_data_acc.City),'left')
                htmlib-MntTableField(html-encode( crm_data_acc.County),'left')
                htmlib-MntTableField(html-encode( crm_data_acc.PostCode),'left')
                htmlib-MntTableField(html-encode( crm_data_acc.Telephone),'left')
                htmlib-MntTableField(html-encode( crm_data_acc.bus_type),'left')
                htmlib-MntTableField(html-encode( lc-cont),'left')
                htmlib-MntTableField(html-encode( crm_data_acc.contact_position),'left')
                
                
                '</tr>' SKIP.                      
        END.
    
    END.
    
    {&out} SKIP 
           htmlib-EndTable()
           SKIP.
    
    

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
                lc-submit-label = "Add Dataset".
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
                lc-submit-label = 'Delete Dataset'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Dataset'.
    END CASE.


    ASSIGN 
        lc-title = lc-title + ' Dataset'
        lc-link-url = appurl + '/crm/crmload.p' + 
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
            set-user-field("nexturl",appurl + "/crm/crmload.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN                  
                lc-description       = get-value("description").
               
            
             
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
                        
                        b-table.CompanyCode = lc-global-company
                        b-table.load_id = NEXT-VALUE(crm_data_load)
                        b-table.loginid = lc-global-user
                        b-table.created = NOW
                        lc-firstrow      = STRING(ROWID(b-table))
                        .
                   
                END.
           
                ASSIGN 
                    b-table.descr     = lc-description
                    .
            
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
                FOR EACH crm_data_acc OF b-table EXCLUSIVE-LOCK:
                    DELETE crm_data_acc.
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
            RUN run-web-object IN web-utilities-hdl ("crm/crmload.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.


        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post"
            THEN ASSIGN lc-description       = b-table.descr
                .
       
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) SKIP
           htmlib-StartForm("mainform","post", appurl + '/crm/crmloadmnt.p' )
           htmlib-ProgramTitle(lc-title) SKIP.

    {&out} htmlib-Hidden ("savemode", lc-mode) SKIP
           htmlib-Hidden ("saverowid", lc-rowid) SKIP
           htmlib-Hidden ("savesearch", lc-search) SKIP
           htmlib-Hidden ("savefirstrow", lc-firstrow) SKIP
           htmlib-Hidden ("savelastrow", lc-lastrow) SKIP
           htmlib-Hidden ("savenavigation", lc-navigation) SKIP
           htmlib-Hidden ("nullfield", lc-navigation) SKIP.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' SKIP.

    {&out} htmlib-StartInputTable() SKIP.


   

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("description",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Description")
        ELSE htmlib-SideLabel("Description"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("description",40,lc-description) 
    '</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-description),'left')
           SKIP.
    {&out} '</TR>' SKIP.
    

    {&out} htmlib-EndTable() SKIP.


    IF lc-mode = "VIEW"
        THEN RUN ipViewAcc.
    
    
    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' SKIP.
    END.

    IF lc-submit-label <> "" THEN
    DO:
        {&out} '<br/><center>' htmlib-SubmitButton("submitform",lc-submit-label) 
        '</center>' SKIP.
    END.
         
    {&out} htmlib-EndForm() SKIP
           htmlib-Footer() SKIP.
    
  
END PROCEDURE.


&ENDIF

