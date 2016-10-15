/***********************************************************************

    Program:        cust/custmnt.p
    
    Purpose:        Customer Maintenance         
    
    Notes:
    
    
    When        Who         What
    10/04/2006  phoski      CompanyCode  
    11/04/2006  phoski      Show users on view    
    30/04/2006  phoski      Mobile number on user list
    15/07/2006  phoski      Ticket flag
    20/07/2006  phoski      Statement Email
    26/07/2006  phoski      Ticket Transactions
    29/09/2014  phoski      Account Manager
    09/06/2015  phoski      Removed contract DJS drivel 
    15/08/2015  phoski      Default user - Issue/Bulk Email/Status
                            Changes
    24/08/2015  phoski      Inventory renewal user
    22/10/2015  phoski      allowAllTeams    
    08/11/2015  phoski      AccountRef field 
    25/06/2016  phoski      iss_survey field   
    08/07/2016  phoski      Remove View related stuff as view is done 
                            in custview.p
    31/07/2016  phoski      AccStatus field instead of active field
    02/08/2016  phoski      CRM fields update
    15/10/2016  phoski      CRM Phase 2
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


DEFINE VARIABLE v-debug        AS LOG       INITIAL FALSE NO-UNDO.

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-mode        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title       AS CHARACTER NO-UNDO.


DEFINE BUFFER b-valid FOR customer.
DEFINE BUFFER b-table FOR customer.


DEFINE VARIABLE lc-search         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters     AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url       AS CHARACTER NO-UNDO.



DEFINE VARIABLE lc-accountnumber  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-name           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-address1       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-address2       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-city           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-county         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-country        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-postcode       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-telephone      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-contact        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-notes          AS CHARACTER NO-UNDO. 
DEFINE VARIABLE lc-supportticket  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-statementemail AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-isActive       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-viewAction     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-viewActivity   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-st-num         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-st-code        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-st-descr       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-AccountManager AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-iss-loginid    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-bulk-loginid   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-stat-loginid   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-renew-loginid  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-allowAllTeams  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-accountref     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-iss-survey     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-sla-rows       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sla-selected   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-temp           AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-ct-code        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ct-desc        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-contract       AS CHARACTER EXTENT 20 NO-UNDO.
DEFINE VARIABLE ll-billable       AS LOG       EXTENT 20 NO-UNDO.
DEFINE VARIABLE lc-connotes       AS CHARACTER EXTENT 20 NO-UNDO.
DEFINE VARIABLE ll-default        AS LOG       EXTENT 20 NO-UNDO.
DEFINE VARIABLE ll-conactive      AS LOG       EXTENT 20 NO-UNDO.
DEFINE VARIABLE lc-cu-code        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-cu-desc        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-AccStatus      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-SalesManager   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sm-code        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sm-desc        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-SalesContact   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Website        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-noEmp          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-turn           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-SalesNote      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-indsector      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ind-code       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ind-desc       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-add-note       AS CHARACTER NO-UNDO.








/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */



/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 6.12
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




&IF DEFINED(EXCLUDE-ip-MainPage) = 0 &THEN

PROCEDURE ip-MainPage :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    {&out} htmlib-StartTable("mnt",
        100,
        0,
        0,
        0,
        "center").


    {&out} '<TR align="left"><TD VALIGN="middle" ALIGN="right" width="25%">' 
        ( IF LOOKUP("accountnumber",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Account Number")
        ELSE htmlib-SideLabel("Account Number"))
    '</TD>' skip
    .

    IF lc-mode = "ADD" THEN
    DO:
        IF glob-company.autoGenAccount THEN
        DO:
            {&out} '<td><div class="infobox">An Account Number will be automatically generated</div></td>' SKIP. 
        END.
        ELSE
            {&out} '<TD VALIGN="TOP" ALIGN="left">' htmlib-InputField("accountnumber",8,lc-accountnumber) '</TD>' SKIP.
    END.
    ELSE
        {&out} htmlib-TableField(html-encode(lc-accountnumber),'left')
           skip.

    {&out} '<td valign="top" align="right" >' skip
           '<div id="contracts" name="contracts" style="position:absolute;float:right;width:450px;right:20px;">&nbsp;' skip
           '</div>'
           '</td>' skip.



    {&out} '</TR>' skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("name",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Name")
        ELSE htmlib-SideLabel("Name"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("name",40,lc-name) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-name),'left')
           skip.

    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("address1",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Address")
        ELSE htmlib-SideLabel("Address"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("address1",40,lc-address1) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-address1),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("address2",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("")
        ELSE htmlib-SideLabel(""))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("address2",40,lc-address2) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-address2),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("city",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("City/Town")
        ELSE htmlib-SideLabel("City/Town"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("city",40,lc-city) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-city),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("county",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("County")
        ELSE htmlib-SideLabel("County"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("county",40,lc-county) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-county),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("country",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Country")
        ELSE htmlib-SideLabel("Country"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("country",40,lc-country) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-country),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("postcode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Post Code")
        ELSE htmlib-SideLabel("Post Code"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("postcode",20,lc-postcode) 
    '</TD>' skip.
    
    {&out} '</TR>' skip.
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("website",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Web Site")
        ELSE htmlib-SideLabel("Web Site"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("website",40,lc-website) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-website),'left')
           skip.
    {&out} '</TR>' skip.
    

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("contact",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Contact")
        ELSE htmlib-SideLabel("Contact"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("contact",40,lc-contact) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-contact),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("telephone",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Telephone")
        ELSE htmlib-SideLabel("Telephone"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("telephone",20,lc-telephone) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-telephone),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Account Status")
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-Select("accstatus",lc-global-accStatus-code,lc-global-accStatus-code,lc-accstatus)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-accStatus,'left')
           skip.
    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("notes",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("General Note")
        ELSE htmlib-SideLabel("General Note"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-TextArea("notes",lc-notes,5,60)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(replace(html-encode(lc-notes),"~n",'<br>'),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<tr><td></td><td colspan=2><div class="infobox">Helpdesk Information</div></td></tr>' SKIP.
    
    IF lc-sla-rows <> "" THEN
    DO:
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right" width="25%">' 
            (IF LOOKUP("sla",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Default SLA")
            ELSE htmlib-SideLabel("Default SLA"))
        '</TD>'
            .
        IF NOT CAN-DO("view,delete",lc-mode)
            THEN 
        DO:
            {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">' skip.
            RUN ip-SLATable.
            {&out} '</td>'.
        END.
        ELSE 
        DO:
            IF b-table.DefaultSLAID = 0
                THEN {&out} htmlib-TableField(html-encode("None"),'left').
            else
            do:
        FIND slahead WHERE slahead.SLAID = b-table.DefaultSLAID NO-LOCK NO-ERROR.
        {&out} htmlib-TableField(html-encode(slahead.description),'left').
    END.
               

END.

{&out} '</TR>' skip.

END.
IF lc-mode <> "ADD" THEN
DO:
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Default Issue User")
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-Select("iss-loginid",lc-cu-Code,lc-cu-desc,lc-iss-loginid)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-iss-loginid,'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Bulk Email User")
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-Select("bulk-loginid",lc-cu-Code,lc-cu-desc,lc-bulk-loginid)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-bulk-loginid,'left')
           skip.
    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Status Change User")
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-Select("stat-loginid",lc-cu-Code,lc-cu-desc,lc-stat-loginid)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-stat-loginid,'left')
           skip.
    {&out} '</TR>' skip.
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Inventory Renewal User")
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-Select("renew-loginid",lc-cu-Code,lc-cu-desc,lc-renew-loginid)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-renew-loginid,'left')
           skip.
    {&out} '</TR>' skip.
    
    
    
END.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("st-num",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Support Team")
    ELSE htmlib-SideLabel("Support Team"))
'</TD>'.
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
htmlib-Select("st-num",lc-st-Code,lc-st-descr,lc-st-num)
'</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-st-num,'left')
           skip.
{&out} '</TR>' skip.

IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("allowAllTeams",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Allow Access To All Teams?")
    ELSE htmlib-SideLabel("Allow Access To All Teams?"))
'</TD>'
'<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
htmlib-CheckBox("allowAllTeams", IF lc-allowAllTeams = 'on'
    THEN TRUE ELSE FALSE) 
'</TD></TR>' skip.




{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("AccountManager",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Account Manager")
    ELSE htmlib-SideLabel("Account Manager"))
'</TD>'.

IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
htmlib-Select("accountmanager",lc-ct-Code,lc-ct-desc,lc-AccountManager)
'</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-AccountManager,'left')
           skip.
{&out} '</TR>' skip.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("supportticket",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Support Tickets Used?")
    ELSE htmlib-SideLabel("Support Tickets Used?"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" SPAN="2">'
htmlib-Select("supportticket",lc-global-SupportTicket-Code,lc-global-SupportTicket-Desc,lc-supportticket)
'</TD>' skip.
    else 
    {&out} htmlib-TableField(dynamic-function("com-DecodeLookup",lc-supportticket,
                                     lc-global-SupportTicket-Code,
                                     lc-global-SupportTicket-Desc
                                     ),'left')
           skip.
{&out} '</TR>' skip.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("statementemail",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Statement Email Address")
    ELSE htmlib-SideLabel("Statement Email Address"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
htmlib-InputField("statementemail",40,lc-statementemail) 
'</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-statementemail),'left')
           skip.
{&out} '</TR>' skip.


IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("viewaction",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("View Actions?")
    ELSE htmlib-SideLabel("View Actions?"))
'</TD>'
'<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
htmlib-CheckBox("viewaction", IF lc-viewAction = 'on'
    THEN TRUE ELSE FALSE) 
'</TD></TR>' skip.

IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("viewactivity",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("View Activities?")
    ELSE htmlib-SideLabel("View Activities?"))
'</TD>'
'<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
htmlib-CheckBox("viewactivity", IF lc-viewActivity = 'on'
    THEN TRUE ELSE FALSE) 
'</TD></TR>' skip.

IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("viewaction",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Send Surveys?")
    ELSE htmlib-SideLabel("Send Surveys?"))
'</TD>'
'<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
htmlib-CheckBox("iss-survey", IF lc-iss-survey = 'on'
    THEN TRUE ELSE FALSE) 
'</TD></TR>' skip.


 
{&out} '<tr><td></td><td colspan=2><div class="infobox">CRM Information</div></td></tr>' SKIP.
  
    
    
{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("accountref",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Account Reference")
    ELSE htmlib-SideLabel("Account Reference"))
'</TD>'.
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
htmlib-InputField("accountref",15,lc-accountref) 
'</TD>' skip.
    else 
 {&out} htmlib-TableField(html-encode(lc-accountref),'left')
           skip.
{&out} '</TR>' skip.
    
{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("SalesManager",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Sales Manager")
    ELSE htmlib-SideLabel("Sales Manager"))
'</TD>'.

IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
htmlib-Select("salesmanager",lc-sm-Code,lc-sm-desc,lc-SalesManager)
'</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-SalesManager,'left')
           skip.
{&out} '</TR>' skip.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
htmlib-SideLabel("Sales Contact")
'</TD>'.
IF lc-mode <> 'add' THEN
DO:
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-Select("salescontact",lc-cu-Code,lc-cu-desc,lc-salescontact)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-salescontact,'left')
           skip.
    {&out} '</TR>' skip.
END.
{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("noemp",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("No Of Employees")
    ELSE htmlib-SideLabel("No Of Employees"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
htmlib-InputField("noemp",6,lc-noemp) 
'</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-noemp),'left')
           skip.

{&out} '</TR>' skip.
    
{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("turn",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Annual Turnover")
    ELSE htmlib-SideLabel("Annual Turnover"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
htmlib-InputField("turn",8,lc-turn) 
'</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-turn),'left')
           skip.

{&out} '</TR>' skip.
        
{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("indsector",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Industry Sector")
    ELSE htmlib-SideLabel("Industry Sector"))
'</TD>'.

IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
htmlib-Select("indsector",lc-ind-Code,lc-ind-desc,lc-indsector)
'</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-indsector,'left')
           skip.
{&out} '</TR>' skip.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("salesnote",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Sales Note")
    ELSE htmlib-SideLabel("Sales Note"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
htmlib-TextArea("salesnote",lc-salesnote,5,60)
'</TD>' skip.
    else 
    {&out} htmlib-TableField(replace(html-encode(lc-salesnote),"~n",'<br>'),'left')
           skip.
{&out} '</TR>' skip.
        
   
 
    
{&out} htmlib-EndTable() skip.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-SLATable) = 0 &THEN

PROCEDURE ip-SLATable :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE BUFFER slahead  FOR slahead.
    DEFINE VARIABLE li-loop     AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lc-object   AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE lc-rowid    AS CHARACTER     NO-UNDO.


    {&out}
    htmlib-StartMntTable()
    htmlib-TableHeading(
        "Select?^left|SLA|Notes"
        ) skip.

    IF lc-global-company = "MICAR" THEN
    DO:
        {&out}
        htmlib-trmouse()
        '<td>'
        htmlib-Radio("sla", "slanone" , IF lc-sla-selected = "slanone" THEN TRUE ELSE FALSE)
        '</td>'
        htmlib-TableField(html-encode("None"),'left')
        htmlib-TableField("",'left')
        '</tr>' skip.
    END.

    DO li-loop = 1 TO NUM-ENTRIES(lc-sla-rows,"|"):
        ASSIGN
            lc-rowid = ENTRY(li-loop,lc-sla-rows,"|").

        FIND slahead WHERE ROWID(slahead) = to-rowid(lc-rowid) NO-LOCK NO-ERROR.
        IF NOT AVAILABLE slahead THEN NEXT.
        ASSIGN
            lc-object = "sla" + lc-rowid.
        {&out}
        htmlib-trmouse()
        '<td>'
        htmlib-Radio("sla" , lc-object, IF lc-sla-selected = lc-object THEN TRUE ELSE FALSE) 
        '</td>'
        htmlib-TableField(html-encode(slahead.description),'left')
        htmlib-TableField(REPLACE(slahead.notes,"~n",'<br>'),'left')
        '</tr>' skip.

    END.
    
        
    {&out} skip 
       htmlib-EndTable()
       skip.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      objtargets:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg    AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-Customer FOR Customer.
    DEFINE VARIABLE li-int  AS INT  NO-UNDO.
    
    
    IF lc-mode = "ADD":U AND glob-company.autoGenAccount = FALSE THEN
    DO:
        IF lc-accountnumber = ""
            OR lc-accountnumber = ?
            THEN RUN htmlib-AddErrorMessage(
                'accountnumber', 
                'You must enter the account number',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        

        IF CAN-FIND(FIRST b-valid
            WHERE b-valid.CompanyCode = lc-global-company
            AND b-valid.accountnumber = lc-accountnumber
            NO-LOCK)
            THEN RUN htmlib-AddErrorMessage(
                'accountnumber', 
                'This account number already exists',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).

    END.

    IF lc-name = ""
        OR lc-name = ?
        THEN RUN htmlib-AddErrorMessage(
            'name', 
            'You must enter the name',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
 
    IF lc-accountref <> "" THEN
    DO:
        FIND FIRST b-customer 
            WHERE b-customer.companyCode = lc-global-company
            AND b-customer.accountref = lc-accountRef
            NO-LOCK NO-ERROR. 
        IF AVAILABLE b-customer THEN
        DO:
            IF lc-mode = "ADD"
                OR b-table.AccountNumber <> b-customer.AccountNumber THEN
            DO:
                RUN htmlib-AddErrorMessage(
                    'accountref', 
                    'This account reference already exists on account ' + b-customer.accountnumber + ' ' + b-customer.name,
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).
                
            END.
        END.
              
    END.
    ASSIGN 
        li-int = int(lc-noemp) NO-ERROR.
    IF ERROR-STATUS:ERROR
        OR li-int < 0 THEN RUN htmlib-AddErrorMessage(
            'noemp', 
            'The number of employees is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    
    ASSIGN 
        li-int = int(lc-turn) NO-ERROR.
    IF ERROR-STATUS:ERROR
        OR li-int < 0 THEN RUN htmlib-AddErrorMessage(
            'turn', 
            'The annual turnover is invalid',
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
  
 

    RUN com-GetTeams ( lc-global-company, OUTPUT lc-st-code, OUTPUT lc-st-descr ).
    RUN com-GetUserListByClass ( lc-global-company, "INTERNAL", REPLACE(lc-global-EngType-Code,'|',",") ,OUTPUT lc-ct-code, OUTPUT lc-ct-desc).
    
    RUN com-GetUserListByClass ( lc-global-company, "INTERNAL", REPLACE(lc-global-SalType-Code,'|',",") ,OUTPUT lc-sm-code, OUTPUT lc-sm-desc).
    
    RUN com-GenTabSelect ( lc-global-company, "CRM.IndustrySector", 
        OUTPUT lc-ind-code,
        OUTPUT lc-ind-desc ).
       
    IF lc-ind-code = ""
        THEN lc-ind-desc = "None".
    ELSE 
        ASSIGN lc-ind-code = "|" + lc-ind-code
            lc-ind-desc = "None|" + lc-ind-desc.
           
    
    
    ASSIGN
        lc-ct-code = "|" + lc-ct-code
        lc-ct-desc = "None Selected|" + lc-ct-desc
        lc-sm-code = "|" + lc-sm-code
        lc-sm-desc = "None Selected|" + lc-sm-desc
        lc-st-code = "0|" + lc-st-code
        lc-st-descr = "None Selected|" + lc-st-descr.


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
                lc-submit-label = "Add Customer".
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
                lc-submit-label = 'Delete Customer'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Customer'.
    END CASE.


    ASSIGN 
        lc-title = lc-title + ' Customer'
        lc-link-url = appurl + '/cust/cust.p' + 
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
            set-user-field("nexturl",appurl + "/cust/cust.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.
   
    END.
    
    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
            IF lc-mode = 'update' THEN
            DO:
                FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
                    NO-LOCK NO-ERROR.
            END.
                        
            ASSIGN 
                lc-accountnumber     = get-value("accountnumber")
                lc-name              = get-value("name")
                lc-address1          = get-value("address1")
                lc-address2          = get-value("address2")
                lc-city              = get-value("city")
                lc-county            = get-value("county")
                lc-country           = get-value("country")
                lc-postcode          = get-value("postcode")
                lc-telephone         = get-value("telephone")
                lc-contact           = get-value("contact")
                lc-notes             = get-value("notes")
                lc-sla-selected      = get-value("sla")
                lc-supportticket     = get-value("supportticket")
                lc-statementemail    = get-value("statementemail")
                lc-isactive          = get-value("isactive")
                lc-st-num            = get-value("st-num")
                lc-viewAction        = get-value("viewaction")
                lc-AccountManager    = get-value("accountmanager")
                lc-viewActivity      = get-value("viewactivity")
                lc-iss-loginid       = get-value("iss-loginid")
                lc-bulk-loginid      = get-value("bulk-loginid")
                lc-stat-loginid      = get-value("stat-loginid")
                lc-renew-loginid     = get-value("renew-loginid")
                lc-allowAllTeams     = get-value("allowallteams")
                lc-accountref        = get-value("accountref")
                lc-iss-survey        = get-value("iss-survey")
                lc-accStatus         = get-value("accstatus")
                lc-SalesManager      = get-value("salesmanager")
                lc-SalesContact      = get-value("salescontact")
                lc-website           = get-value("website")
                lc-noemp             = get-value("noemp")
                lc-turn              = get-value("turn")
                lc-salesnote         = get-value("salesnote")
                lc-indsector        =  get-value("indsector")
             
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
                    IF glob-company.autogenAccount THEN
                    DO:
                        RUN lib/autogenAccount.p ( lc-global-company, OUTPUT lc-accountNumber).
                        lc-add-note = "Account " + lc-accountNumber + " created".
                    END.   
                    
                    CREATE b-table.
                    ASSIGN 
                        b-table.accountnumber = CAPS(lc-accountnumber)
                        b-table.CompanyCode   = lc-global-company
                        lc-firstrow      = STRING(ROWID(b-table)).
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.name         = lc-name
                        b-table.address1       = lc-address1
                        b-table.address2       = lc-address2
                        b-table.city           = lc-city
                        b-table.county         = lc-county
                        b-table.country        = lc-country
                        b-table.postcode       = lc-postcode
                        b-table.contact        = lc-contact
                        b-table.telephone      = lc-telephone
                        b-table.notes          = lc-notes
                        b-table.supportticket  = lc-supportticket
                        b-table.statementemail = lc-statementemail
                        /* b-table.isActive       = lc-isActive = "on" */
                        b-table.ViewAction     = lc-viewAction = "on"
                        b-table.ViewActivity   = lc-viewActivity = "on"
                        b-table.allowAllTeams  = lc-allowAllTeams = "on"
                        b-table.AccountManager = lc-AccountManager
                        b-table.st-num         = INT(lc-st-num)
                        b-table.def-iss-loginid = lc-iss-loginid
                        b-table.def-bulk-loginid = lc-bulk-loginid
                        b-table.def-stat-loginid = lc-stat-loginid
                        b-table.def-renew-loginid = lc-renew-loginid
                        b-table.accountref       = lc-accountref
                        b-table.iss_survey      = lc-iss-survey = "on"
                        b-table.accStatus       = lc-accStatus
                        b-table.SalesManager    = lc-SalesManager
                        b-table.salesContact    = lc-SalesContact
                        b-table.website         = lc-WebSite
                        b-table.NoOfEmployees   = int(lc-noemp)
                        b-table.AnnualTurnover = int(lc-turn)
                        b-table.salesnote       = lc-salesnote
                        b-table.industrySector = lc-indsector
                        .
                        
                    /* Active now means active on the help desk only */
                    
                    ASSIGN
                        b-table.isActive = b-table.accStatus = "Active".
                     
                    

                    ASSIGN
                        lc-sla-rows = com-CustomerAvailableSLA(lc-global-company,b-table.AccountNumber).
                    IF lc-sla-selected = "slanone" 
                        OR lc-sla-rows = "" THEN 
                    DO:
                        ASSIGN 
                            b-table.DefaultSLAID = 0.
                           
                    END.
                    ELSE
                    DO:
                        FIND slahead WHERE ROWID(slahead) = to-rowid(substr(lc-sla-selected,4)) NO-LOCK NO-ERROR.
                        IF AVAILABLE slahead THEN 
                        DO:
                            ASSIGN 
                                b-table.DefaultSLAID = slahead.SLAID.
                        END.
    
                    END.
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
                
                DELETE b-table.
            END.
        END.

        IF lc-error-field = "" THEN
        DO:
            RUN outputHeader.
            set-user-field("navigation",'refresh').
            set-user-field("firstrow",lc-firstrow).
            set-user-field("search",lc-search).
            set-user-field("addnote",lc-add-note).
            
            RUN run-web-object IN web-utilities-hdl ("cust/cust.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        ASSIGN 
            lc-accountnumber = b-table.accountnumber.
        RUN com-GetUserListForAccount (lc-global-company,lc-AccountNumber,OUTPUT lc-cu-code, OUTPUT lc-cu-desc).
        IF lc-cu-code = ""
            THEN lc-cu-desc = "None".
        ELSE
            ASSIGN
                lc-cu-code = "|" + lc-cu-code
                lc-cu-desc = "None|" + lc-cu-desc.

        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post" THEN 
        DO:
            ASSIGN 
                lc-name      = b-table.name
                lc-address1  = b-table.address1
                lc-address2  = b-table.address2
                lc-city      = b-table.city
                lc-county    = b-table.county
                lc-country   = b-table.country
                lc-postcode  = b-table.postcode
                lc-telephone = b-table.telephone
                lc-contact   = b-table.contact
                lc-notes     = b-table.notes
                lc-supportticket = b-table.SupportTicket
                lc-statementemail = b-table.statementemail
                /* lc-isactive = IF b-table.isActive THEN "on" ELSE "" */
                lc-viewAction = IF b-table.viewAction THEN "on" ELSE ""
                lc-viewActivity = IF b-table.viewActivity THEN "on" ELSE ""
                lc-allowAllTeams = IF b-table.allowAllTeams THEN "on" ELSE ""
                lc-st-num = STRING(b-table.st-num)
                lc-AccountManager   = b-table.AccountManager
                lc-iss-loginid  = b-table.def-iss-loginid
                lc-bulk-loginid  = b-table.def-bulk-loginid
                lc-stat-loginid  = b-table.def-stat-loginid
                lc-renew-loginid  = b-table.def-renew-loginid
                lc-accountref     = b-table.accountRef
                lc-iss-survey = IF b-table.iss_survey THEN "on" ELSE ""
                lc-accstatus = b-table.accStatus
                lc-SalesManager = b-table.SalesManager
                lc-SalesContact = b-table.salescontact
                lc-website      = b-table.website
                lc-noemp        = STRING(b-table.NoOfEmployees)
                lc-turn         = STRING(b-table.AnnualTurnover)
                lc-salesnote    = b-table.SalesNote
                lc-indsector    = b-table.industrySector
                
                
                .

            IF b-table.DefaultSLAID = 0
                THEN ASSIGN lc-sla-selected = "slanone".
            ELSE
            DO:
                FIND slahead
                    WHERE slahead.SLAID = b-table.defaultSLAID NO-LOCK NO-ERROR.
                IF AVAILABLE slahead
                    THEN ASSIGN lc-sla-selected = "sla" + string(ROWID(slahead)).
            END.
            
        END.
        ASSIGN 
            lc-sla-rows = com-CustomerAvailableSLA(lc-global-company,b-table.AccountNumber).
       
    END.
    ELSE ASSIGN lc-sla-rows = com-CustomerAvailableSLA(lc-global-company,"").


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



    RUN ip-MainPage.

    

    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
    END.

    IF lc-submit-label <> "" THEN
    DO:
        {&out} '<br><center>' htmlib-SubmitButton("submitform",lc-submit-label) 
        '</center>' skip.
    END.


    {&out} htmlib-EndForm() skip
           htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */


