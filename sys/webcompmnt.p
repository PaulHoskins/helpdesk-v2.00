/***********************************************************************

    Program:        sys/webcompmnt.p
    
    Purpose:        Company Maintenance             
    
    Notes:
    
    
    When        Who         What
    10/04/2006  phoski      Initial
    11/04/2006  phoski      SMTP & Email & WebAddress & EmailFooter
    23/04/2006  phoski      HelpDeskPhone
    14/07/2006  phoski      MonitorMessage
    21/03/2007  phoski      Timeout & PasswordExpire
    
    07/09/2010  DJS         3704  Removed streetmap button.
    30/04/2014  phoski      Marketing Banner
    09/11/2014  phoski      Email Stuff
    11/12/2014  phoski      Renewal user
    05/06/2015  phoski      Engineer Cost
    19/08/2015  phoski      Email bulkemail custaddissue
    27/02/2016  phoski      helpdesklink field for SLA alerts
    25/06/2016  phoski      Issue Survey
    03/07/2016  phoski      2 Factor Auth Config     
    15/10/2016  phoski      Autogen Account Numbers - CRM Phase 2 
    15/12/2016  phoski      Company.unqualOppEmail 
    17/12/2016  phoski      Company.opactwarnDays & Company.opactwarnEmail
    
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


DEFINE BUFFER b-valid FOR company.
DEFINE BUFFER b-table FOR company.


DEFINE VARIABLE lc-search         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters     AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-link-label     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url       AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-companycode    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-name           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-smtp           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-helpdeskemail  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-email2db       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-HelpDeskPhone  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-webaddress     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-emailfooter    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-monitormessage AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-slabeginhour   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-slabeginmin    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-slaendhour     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-slaendmin      AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-address1       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-address2       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-city           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-county         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-country        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-postcode       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-temp           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-issueinfo      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-TimeOut        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-PasswordExpire AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mBanner        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-emuser         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-empass         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-emssl          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-renew          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-engCost        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-bulkemail      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-custaddissue   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-helpdesklink   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-iss-survey     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sv-code        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sv-desc        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-factorAuth     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-factorEmail    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-factorAccount  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-factorPassword AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-factorPIN      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-autogenAccount AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-nextAccount    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lengthAccount  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-unqualOppEmail AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-opactwarnDays  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-opactwarnEmail AS CHARACTER NO-UNDO.








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

&IF DEFINED(EXCLUDE-ip-BuildPage) = 0 &THEN

PROCEDURE ip-BuildPage :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    {&out} htmlib-StartInputTable() SKIP.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("companycode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Company Code")
        ELSE htmlib-SideLabel("Company Code"))
    '</TD>' SKIP
    .

    IF lc-mode = "ADD" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("companycode",10,lc-companycode) SKIP
           '</TD>'.
    ELSE
    {&out} htmlib-TableField(html-encode(lc-companycode),'left')
           SKIP.

    {&out} '</TR>' SKIP.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("name",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Name")
        ELSE htmlib-SideLabel("Name"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("name",40,lc-name) 
    '</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-name),'left')
           SKIP.
    {&out} '</TR>' SKIP.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("address1",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Address")
        ELSE htmlib-SideLabel("Address"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("address1",40,lc-address1) 
    '</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-address1),'left')
           SKIP.
    {&out} '</TR>' SKIP.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("address2",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("")
        ELSE htmlib-SideLabel(""))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("address2",40,lc-address2) 
    '</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-address2),'left')
           SKIP.
    {&out} '</TR>' SKIP.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("city",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("City/Town")
        ELSE htmlib-SideLabel("City/Town"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("city",40,lc-city) 
    '</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-city),'left')
           SKIP.
    {&out} '</TR>' SKIP.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("county",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("County")
        ELSE htmlib-SideLabel("County"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("county",40,lc-county) 
    '</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-county),'left')
           SKIP.
    {&out} '</TR>' SKIP.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("country",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Country")
        ELSE htmlib-SideLabel("Country"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("country",40,lc-country) 
    '</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-country),'left')
           SKIP.
    {&out} '</TR>' SKIP.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("postcode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Post Code")
        ELSE htmlib-SideLabel("Post Code"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("postcode",20,lc-postcode) 
    '</TD>' SKIP.
    ELSE 
    DO:

IF lc-postcode = "" THEN 
    {&out} htmlib-TableField(html-encode(lc-postcode),'left')
           SKIP.
        ELSE

         {&out}  REPLACE(htmlib-TableField(html-encode(lc-postcode),'left'),"</td>","").

END.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("webaddress",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Web Site")
    ELSE htmlib-SideLabel("Web Site"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("webaddress",40,lc-webaddress) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-webaddress),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("helpdesklink",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Link URL")
    ELSE htmlib-SideLabel("Link URL"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("helpdesklink",80,lc-helpdesklink) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-helpdesklink),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("smtp",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("SMTP Server")
    ELSE htmlib-SideLabel("SMTP Server"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("smtp",40,lc-smtp) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-smtp),'left')
           SKIP.
{&out} '</TR>' SKIP.
/**/
{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("emuser",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("SMTP Account")
    ELSE htmlib-SideLabel("SMTP Account"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("emuser",40,lc-emuser) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-emuser),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("empass",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("SMTP Password")
    ELSE htmlib-SideLabel("SMTP Password"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("empass",40,lc-empass) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-empass),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("emssl",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("SMTP SSL/TLS Connection")
    ELSE htmlib-SideLabel("SMTP SSL/TLS Connection"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-checkBox("emssl",lc-emssl = "on")
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(IF lc-emssl = "on" THEN "Yes" ELSE 'No','left')
           SKIP.
{&out} '</TR>' SKIP.


/**/
{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("helpdeskemail",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("HelpDesk Email Address")
    ELSE htmlib-SideLabel("HelpDesk Email Address"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("helpdeskemail",40,lc-helpdeskemail) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-helpdeskemail),'left')
           SKIP.
{&out} '</TR>' SKIP.
{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("bulkemail",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Bulk Email Address")
    ELSE htmlib-SideLabel("Bulk Email Address"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("bulkemail",40,lc-bulkemail) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-bulkemail),'left')
           SKIP.
{&out} '</TR>' SKIP.
{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("custaddissue",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Unassigned Issue Alert Email Address")
    ELSE htmlib-SideLabel("Unassigned Issue Alert Email Address"))
'</TD>'.
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("custaddissue",40,lc-custaddissue) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-custaddissue),'left')
           SKIP.
{&out} '</TR>' SKIP.

/**/
{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("unqualoppemail",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Unqualified Lead Email Alert List")
    ELSE htmlib-SideLabel("Unqualified Lead Email Alert List"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("unqualoppemail",80,lc-unqualoppemail) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-unqualoppemail),'left')
           SKIP.
{&out} '</TR>' SKIP.

    



{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("email2db",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Email2DB Monitor")
    ELSE htmlib-SideLabel("Email2DB Monitor"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("email2db",40,lc-email2db) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-email2db),'left')
           SKIP.
{&out} '</TR>' SKIP.



{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("helpdeskphone",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("HelpDesk Phone")
    ELSE htmlib-SideLabel("HelpDesk Phone"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("helpdeskphone",20,lc-helpdeskphone) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-helpdeskphone),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("timeout",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Timeout (Mins)")
    ELSE htmlib-SideLabel("Timeout (Mins)"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("timeout",2,lc-timeout) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-timeout),'left')
           SKIP.
{&out} '</TR>' SKIP.
{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("passwordexpire",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Password Expiry (Days)")
    ELSE htmlib-SideLabel("Password Expiry (Days)"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("passwordexpire",2,lc-passwordexpire) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-passwordexpire),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("renew",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Inventory Renewal User")
    ELSE htmlib-SideLabel("Inventory Renewal User"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("renew",15,lc-renew) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-renew),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("emailfooter",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Email Footer")
    ELSE htmlib-SideLabel("Email Footer"))
'</TD>'.
    

IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-TextArea("emailfooter",lc-emailfooter,10,60)
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(REPLACE(html-encode(lc-emailfooter),"~n",'<br>'),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("monitormessage",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Email Monitor Reply")
    ELSE htmlib-SideLabel("Email Monitor Reply"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-TextArea("monitormessage",lc-monitormessage,10,60)
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(REPLACE(html-encode(lc-monitormessage),"~n",'<br>'),'left')
           SKIP.
{&out} '</TR>' SKIP.


{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("issueinfo",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Customer Note")
    ELSE htmlib-SideLabel("Customer Note"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-TextArea("issueinfo",lc-issueinfo,10,60)
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(REPLACE(html-encode(lc-issueinfo),"~n",'<br>'),'left')
           SKIP.
{&out} '</TR>' SKIP.


{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
IF LOOKUP("slabegin",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Office Hours Based SLA - Start/End")
ELSE htmlib-SideLabel("Office Hours Based SLA - Start/End")
               
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-TimeSelect("slabeginhour",lc-slabeginhour,"slabeginmin",lc-slabeginmin)
' / ' 
htmlib-TimeSelect("slaendhour",lc-slaendhour,"slaendmin",lc-slaendmin)
            
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField("format time",'left')
           SKIP.
{&out} '</TR>' SKIP.


{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("mbanner",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Marketing HTML")
    ELSE htmlib-SideLabel("Marketing HTML"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-TextArea("mbanner",lc-mbanner,10,60)
'</TD>' SKIP.
    ELSE
    
    DO:
IF lc-mbanner <> "" THEN
    {&out} htmlib-TableField(html-encode(lc-mbanner) + '<BR><BR><BR>' + lc-mbanner,'left')
           SKIP.
        ELSE
        {&out} htmlib-TableField("&nbsp;",'left') SKIP.

END.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("engcost",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Engineer Cost")
    ELSE htmlib-SideLabel("Engineer Cost"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("engcost",10,lc-engcost) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-engcost),'left')
           SKIP.
{&out} '</TR>' SKIP.


{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("iss-survey",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Issue Survey")
    ELSE htmlib-SideLabel("Issue Survey"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-Select("iss-survey",lc-sv-code ,lc-sv-desc,lc-iss-survey)
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-iss-survey),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("factorauth",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("RedOxygen SMS 2 Factor Authorisation?")
    ELSE htmlib-SideLabel("RedOxygen SMS 2 Factor Authorisation?"))
'</TD>'.

IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-checkBox("factorauth",lc-factorAuth = "on")
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(IF lc-factorAuth = "on" THEN "Yes" ELSE "No"),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("factoremail",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("RedOxygen Email")
    ELSE htmlib-SideLabel("RedOxygen Email"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("factoremail",30,lc-factoremail) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-factoremail),'left')
           SKIP.
{&out} '</TR>' SKIP.


{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("factoraccount",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("RedOxygen Account")
    ELSE htmlib-SideLabel("RedOxygen Account"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("factoraccount",30,lc-factoraccount) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-factoraccount),'left')
           SKIP.
{&out} '</TR>' SKIP.


{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("factorpassword",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("RedOxygen Password")
    ELSE htmlib-SideLabel("RedOxygen Password"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("factorpassword",30,lc-factorpassword) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-factorpassword),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("factorpin",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("SMS PIN Length")
    ELSE htmlib-SideLabel("SMS PIN Length"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-Select("factorpin","4|5|6|7|8","4|5|6|7|8",lc-factorpin)
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-factorPin),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("autogenaccount",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Auto Generate Account Numbers?")
    ELSE htmlib-SideLabel("Auto Generate Account Numbers?"))
'</TD>'.

IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-checkBox("autogenaccount",lc-autogenaccount = "on")
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(IF lc-autogenaccount = "on" THEN "Yes" ELSE "No"),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("nextaccount",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Next Account Number")
    ELSE htmlib-SideLabel("Next Account Number"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("nextaccount",8,lc-nextaccount) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-nextaccount),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("lengthaccount",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Account Length")
    ELSE htmlib-SideLabel("Account Length"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-Select("lengthaccount","0|3|4|5|6|7|8","No Padding|3 Digits - 999|4 Digits - 9999|5 Digits - 99999|6 Digits - 999999|7 Digits - 9999999 |8 Digits - 99999999",lc-lengthaccount)
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-lengthaccount),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("opactwarnDays",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Opportunity Last Activity Warning - Number of Days")
    ELSE htmlib-SideLabel("Opportunity Last Activity Warning - Number of Days"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("opactwarndays",4,lc-opactwarnDays) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-opactwarnDays),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("opactwarnemail",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Opportunity Last Activity Warning - Email List")
    ELSE htmlib-SideLabel("Opportunity Last Activity Warning - Email List"))
'</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left">'
htmlib-InputField("opactwarnemail",80,lc-opactwarnEmail) 
'</TD>' SKIP.
    ELSE 
    {&out} htmlib-TableField(html-encode(lc-opactwarnEmail),'left')
           SKIP.
{&out} '</TR>' SKIP.

{&out} htmlib-EndTable() '<br /> 'SKIP.
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


    DEFINE VARIABLE lc-code         AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE li-int          AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lf-dec          AS DECIMAL      NO-UNDO.
    
    IF lc-mode = "ADD":U THEN
    DO:
        IF lc-companycode = ""
            OR lc-companycode = ?
            THEN RUN htmlib-AddErrorMessage(
                'companycode', 
                'You must enter the company',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        

        IF CAN-FIND(FIRST b-valid
            WHERE b-valid.companycode = lc-companycode
            NO-LOCK)
            THEN RUN htmlib-AddErrorMessage(
                'companycode', 
                'This company already exists',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).

    END.

    IF lc-name = ""
        OR lc-name = ?
        THEN RUN htmlib-AddErrorMessage(
            'name', 
            'You must enter the company name',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

   
    ASSIGN 
        li-int = int(lc-Timeout) no-error.
    IF ERROR-STATUS:ERROR
        OR li-int < 0 
        THEN RUN htmlib-AddErrorMessage(
            'timeout', 
            'The timeout period must be 0 or greater',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    
    ASSIGN 
        li-int = int(lc-PasswordExpire) no-error.
    IF ERROR-STATUS:ERROR
        OR li-int < 0 
        THEN RUN htmlib-AddErrorMessage(
            'passwordexpire', 
            'The password expiry period must be 0 or greater',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
            
    IF lc-renew <> "" THEN
    DO:
        FIND FIRST WebUser WHERE WebUser.LoginID = lc-renew NO-LOCK NO-ERROR.
        IF NOT AVAILABLE WebUser 
        THEN RUN htmlib-AddErrorMessage(
                'renew', 
                'The renewal user does not exist' ,
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        ELSE
        IF WebUser.CompanyCode <> lc-companyCode
        THEN RUN htmlib-AddErrorMessage(
                'renew', 
                'The renewal user is not in this company' ,
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
                
 
    END.          
    ASSIGN 
        lf-dec = dec(lc-engcost) no-error.
    IF ERROR-STATUS:ERROR
    OR lf-dec <= 0 
        THEN RUN htmlib-AddErrorMessage(
            'engcost', 
            'The engineer cost must be over zero',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
            
    IF lc-factorAuth = "on" THEN
    DO:
        IF lc-factorEmail = ""
        THEN RUN htmlib-AddErrorMessage(
            'factoremail', 
            'You must enter the email address',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ). 
            
        IF lc-factorAccount = ""
        THEN RUN htmlib-AddErrorMessage(
            'factoraccount', 
            'You must enter the account',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ). 
        IF lc-factorPassword = ""
        THEN RUN htmlib-AddErrorMessage(
            'factorpassword', 
            'You must enter the password',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ). 
        
    END.         

 
    ASSIGN 
        li-int = int(lc-nextAccount) no-error.
    IF ERROR-STATUS:ERROR
    OR li-int <= 0
    OR li-int > 99999999 
        THEN RUN htmlib-AddErrorMessage(
            'nextaccount', 
            'The next account must be in the range 1 to  99999999',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
            
    ASSIGN 
        li-int = int(lc-opactwarnDays) no-error.
    IF ERROR-STATUS:ERROR
        OR li-int < 0 
        THEN RUN htmlib-AddErrorMessage(
            'opactwarndays', 
            'The warning days must be 0 or greater',
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
                lc-submit-label = "Add Company".
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
                lc-submit-label = 'Delete Company'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Company'.
    END CASE.


    ASSIGN 
        lc-title = lc-title + ' Company'
        lc-link-url = appurl + '/sys/webcomp.p' + 
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
            set-user-field("nexturl",appurl + "/sys/webcomp.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:
             
                        
            ASSIGN 
                lc-companycode   = get-value("companycode")
                lc-name          = get-value("name")
                lc-address1      = get-value("address1")
                lc-address2      = get-value("address2")
                lc-city          = get-value("city")
                lc-county        = get-value("county")
                lc-country       = get-value("country")
                lc-postcode      = get-value("postcode")
                lc-smtp          = get-value("smtp")
                lc-helpdeskemail = get-value("helpdeskemail")
                lc-helpdeskphone = get-value("helpdeskphone")
                lc-webaddress    = get-value("webaddress")
                lc-emailfooter   = get-value("emailfooter")
                lc-slabeginhour  = get-value("slabeginhour")
                lc-slabeginmin   = get-value("slabeginmin")
                lc-slaendhour    = get-value("slaendhour")
                lc-slaendmin     = get-value("slaendmin")
                lc-monitormessage = get-value("monitormessage")
                lc-issueinfo = get-value("issueinfo")
                lc-timeout   = get-value("timeout")
                lc-passwordexpire = get-value("passwordexpire")
                lc-email2db       = get-value("email2db")
                lc-mbanner        = get-value("mbanner")
                lc-emuser         = get-value("emuser")
                lc-empass         = get-value("empass")
                lc-emssl          = get-value("emssl")
                lc-renew          = get-value("renew")
                lc-engcost        = get-value("engcost")
                lc-bulkemail      = get-value("bulkemail")
                lc-custaddissue   = get-value("custaddissue")
                lc-helpdesklink   = get-value("helpdesklink")
                lc-iss-survey     = get-value("iss-survey")
                lc-FactorAuth     = get-value("factorauth")
                lc-FactorEmail    = get-value("factoremail")
                lc-FactorAccount  = get-value("factoraccount")
                lc-FactorPassword = get-value("factorpassword")
                lc-FactorPIN      = get-value("factorpin")
                lc-autogenAccount = get-value("autogenaccount")
                lc-nextaccount    = get-value("nextaccount")
                lc-lengthaccount  = get-value("lengthaccount")
                lc-unqualoppemail = get-value("unqualoppemail")
                lc-opactwarnDays  = get-value("opactwarndays")
                lc-opactwarnEmail = get-value("opactwarnemail")
                 .
            IF lc-mode = 'update' THEN
            DO:
                FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
                    NO-LOCK NO-ERROR.
                lc-companycode = b-table.companyCode.
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
                        b-table.companycode = CAPS(lc-companycode)
                        lc-firstrow      = STRING(ROWID(b-table))
                        .
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.name            = lc-name
                        b-table.address1 = lc-address1
                        b-table.address2 = lc-address2
                        b-table.city     = lc-city
                        b-table.county   = lc-county
                        b-table.country  = lc-country
                        b-table.postcode = lc-postcode
                        b-table.smtp            = lc-smtp
                        b-table.helpdeskemail   = lc-helpdeskemail
                        b-table.helpdeskphone   = lc-helpdeskphone
                        b-table.webaddress      = lc-webaddress
                        b-table.emailfooter     = lc-emailfooter
                        b-table.slabeginhour    = int(lc-slabeginhour)
                        b-table.slabeginmin     = int(lc-slabeginmin)
                        b-table.slaendhour      = int(lc-slaendhour)
                        b-table.slaendmin       = int(lc-slaendmin)
                        b-table.MonitorMessage  = lc-monitormessage
                        b-table.issueinfo = lc-issueinfo
                        b-table.Timeout   = int(lc-timeout)
                        b-table.PasswordExpire = int(lc-passwordExpire)
                        b-table.Email2DB       = lc-Email2DB
                        b-table.mBanner        = lc-mBanner
                        b-table.em_user        = lc-emuser
                        b-table.em_pass        = lc-empass
                        b-table.em_ssl         = lc-emssl = "on"
                        b-table.renewal-login  = lc-renew
                        b-table.engcost        = dec(lc-engcost)
                        b-table.custaddissue   = lc-custaddissue
                        b-table.bulkemail      = lc-bulkemail
                        b-table.helpdesklink   = lc-helpdesklink
                        b-table.isc_acs_code   = TRIM(lc-iss-survey)
                        b-table.twoFactor_auth = lc-factorAuth = "on"
                        b-table.twoFactor_Email = lc-factorEmail
                        b-table.twoFactor_Account = lc-factoraccount
                        b-table.twoFactor_Password = lc-factorPassword
                        b-table.twoFactor_PinLength = int(lc-factorPin)
                        b-table.autogenaccount = lc-autogenaccount = "on"
                        b-table.nextaccount = int(lc-nextaccount)
                        b-table.lengthaccount = int(lc-lengthaccount)
                        b-table.unqualoppemail = lc-unqualoppemail
                        b-table.opactwarnDays = int(lc-opactwarnDays)
                        b-table.opactwarnEmail = lc-opactwarnEmail
                        
                        
                        
                        
                        .
                   
                    
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
            RUN run-web-object IN web-utilities-hdl ("sys/webcomp.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        ASSIGN 
            lc-companycode = b-table.companycode
            lc-sv-code     = " "
            lc-sv-desc     = "None"
            .

        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post" THEN 
        DO:
            ASSIGN 
                lc-companycode = b-table.companycode
                lc-name             = b-table.name
                lc-address1  = b-table.address1
                lc-address2  = b-table.address2
                lc-city      = b-table.city
                lc-county    = b-table.county
                lc-country   = b-table.country
                lc-postcode  = b-table.postcode
                lc-smtp             = b-table.smtp
                lc-helpdeskemail    = b-table.helpdeskemail
                lc-helpdeskphone    = b-table.helpdeskphone
                lc-webaddress       = b-table.webaddress
                lc-emailfooter      = b-table.emailfooter
                lc-monitormessage   = b-table.monitormessage
                lc-slabeginhour     = STRING(b-table.slabeginhour)
                lc-slabeginmin      = STRING(b-table.slabeginmin)
                lc-slaendhour       = STRING(b-table.slaendhour)
                lc-slaendmin        = STRING(b-table.slaendmin)
                lc-issueinfo = b-table.issueinfo
                lc-timeout = STRING(b-table.timeout)
                lc-passwordexpire = STRING(b-table.passwordExpire)
                lc-email2db       = b-table.email2db
                lc-mbanner        = b-table.mBanner
                lc-emuser         = b-table.em_user
                lc-empass         = b-table.em_pass
                lc-emssl          = IF b-table.em_ssl THEN "on" ELSE ""
                lc-renew          = b-table.renewal-login
                lc-engcost        = STRING(b-table.engcost)
                lc-bulkemail      = b-table.bulkemail
                lc-custaddissue   = b-table.custaddissue
                lc-helpdesklink   = b-table.helpdesklink
                lc-iss-survey     = b-table.isc_acs_code
                lc-FactorAuth     = IF b-table.twoFactor_auth THEN "on" ELSE ""
                lc-FactorEmail    = b-table.twoFactor_Email
                lc-FactorAccount  = b-table.twoFactor_Account
                lc-FactorPassword = b-table.twoFactor_Password
                lc-FactorPin      = STRING(b-table.twoFactor_PinLength)
                lc-autogenaccount = IF b-table.autogenaccount THEN "on" ELSE ""
                lc-nextaccount    = STRING(b-table.nextaccount)
                lc-lengthaccount  = STRING(b-table.lengthaccount)
                lc-unqualoppemail = b-table.unqualoppemail
                lc-opactwarnDays  = STRING(b-table.opactwarnDays)
                lc-opactwarnEmail = b-table.opactwarnEmail
                .
                
            FOR EACH acs_head NO-LOCK
                WHERE acs_head.CompanyCode = b-table.companyCode:
                ASSIGN
                    lc-sv-code = lc-sv-code + "|" + acs_head.acs_code
                    lc-sv-desc = lc-sv-desc + "|" + acs_head.descr.
                          
            END.                     
        END.
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) SKIP
           htmlib-StartForm("mainform","post", appurl + '/sys/webcompmnt.p' )
           htmlib-ProgramTitle(lc-title) SKIP.

    {&out} htmlib-Hidden ("savemode", lc-mode) SKIP
           htmlib-Hidden ("saverowid", lc-rowid) SKIP
           htmlib-Hidden ("savesearch", lc-search) SKIP
           htmlib-Hidden ("savefirstrow", lc-firstrow) SKIP
           htmlib-Hidden ("savelastrow", lc-lastrow) SKIP
           htmlib-Hidden ("savenavigation", lc-navigation) SKIP
           htmlib-Hidden ("nullfield", lc-navigation) SKIP.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' SKIP.

    
    RUN ip-BuildPage.

    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<BR><BR><CENTER>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' SKIP.
    END.

    IF lc-submit-label <> "" THEN
    DO:
        {&out} '<center>' htmlib-SubmitButton("submitform",lc-submit-label) 
        '</center>' SKIP.
    END.
         
    {&out} htmlib-EndForm() SKIP
           htmlib-Footer() SKIP.
    
  
END PROCEDURE.


&ENDIF

