/***********************************************************************

    Program:        sys/webusermnt.p
    
    Purpose:        User Maintenance 
    
    Notes:
    
    
    When        Who         What
    09/04/2006  phoski      UserClass field
    10/04/2006  phoski      Company Code
    11/04/2006  phoski      CustomerTrack
    28/04/2006  phoski      RecordsPerPage
    30/04/2006  phoski      Mobile & AllowSMS AccessSMS
    17/08/2006  phoski      QuickView
    20/05/2014  phoski      DFS bug fixes & Team Selections
    13/06/2014  phoski      UX
    22/07/2014  phoski      Timeout
    04/10/2014  phoski      Account Manager 
    13/11/2014  phoski      Customer View Inventory Flag
    20/11/2014  phoski      save & Pass back 'selacc' field
    29/11/2014  phoski      remove working hours
    03/12/2014  phoski      Engineer Type 
    24/05/2015  phoski      Dashboard selection  
    25/06/2016  phoski      iss_survey field  
    03/07/2016  phoski      TwoFactor_Disable field 
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg      AS CHARACTER NO-UNDO.

DEFINE VARIABLE li-curr-year      AS INTEGER   FORMAT "9999" NO-UNDO.
DEFINE VARIABLE li-end-week       AS INTEGER   FORMAT "99" NO-UNDO.
DEFINE VARIABLE ld-curr-hours     AS DECIMAL   FORMAT "99.99" EXTENT 7 NO-UNDO.
DEFINE VARIABLE lc-day            AS CHARACTER INITIAL "Mon,Tue,Wed,Thu,Fri,Sat,Sun" NO-UNDO.

DEFINE VARIABLE lc-mode           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title          AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-search         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-label     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-selacc         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-loginid        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-forename       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-surname        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-email          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-usertitle      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-pagename       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-disabled       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-accountnumber  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-jobtitle       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-telephone      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-password       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-userClass      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-customertrack  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-recordsperpage AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mobile         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-allowsms       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-accesssms      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-superuser      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-accountmanager AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-quickview      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-DefaultUser    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-DisableTimeout AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-CustInv        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-engType        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-EmailTimeReport AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-iss-survey       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-factorDisable    AS CHARACTER NO-UNDO.



DEFINE VARIABLE lc-html           AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-check          AS LOG       NO-UNDO.
DEFINE VARIABLE li-Count          AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-row            AS INTEGER   INITIAL 3 NO-UNDO.


DEFINE VARIABLE lc-usertitleCode  AS CHARACTER
    INITIAL '' NO-UNDO.
DEFINE VARIABLE lc-usertitleDesc  AS CHARACTER
    INITIAL '' NO-UNDO.



DEFINE BUFFER b-valid   FOR webuser.
DEFINE BUFFER b-table   FOR webuser.
DEFINE BUFFER webuSteam FOR webuSteam.
DEFINE BUFFER steam     FOR steam.

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-html-InputFieldMasked) = 0 &THEN

FUNCTION html-InputFieldMasked RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pc-maxlength AS CHARACTER,
    pc-datatype AS CHARACTER,
    pc-mask AS CHARACTER,
    pc-value AS CHARACTER,
    pc-style AS CHARACTER )  FORWARD.


&ENDIF


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
{lib/maillib.i}

/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-Page) = 0 &THEN

PROCEDURE ip-Page :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
   
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        ( IF LOOKUP("loginid",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("User Name")
        ELSE htmlib-SideLabel("User Name"))
    '</TD>' skip
    .

    IF lc-mode = "ADD" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("loginid",20,lc-loginid) skip
           '</TD>'.
    else
    {&out} htmlib-TableField(html-encode(lc-loginid),'left')
           skip.
    {&out} '</TR>' skip.

    IF NOT CAN-DO("VIEW,DELETE",lc-mode) THEN
    DO:
        {&out} '<TR><TD VALIGN="TOP" ALIGN="RIGHT">' 
        IF LOOKUP("password",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Password")
        ELSE htmlib-SideLabel("Password")
        '</TD><TD VALIGN="TOP" ALIGN="LEFT">'.
        {&out}  htmlib-InputPassword("password",20,"")
        '</TD>' skip.
    END.
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("usertitle",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Title")
        ELSE htmlib-SideLabel("Title"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("usertitle",lc-usertitleCode,lc-usertitleDesc,lc-usertitle) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(
        entry(lookup(lc-usertitle,lc-usertitleCode,'|'),lc-usertitleDesc,'|')
        ),'left')
           skip.
    {&out} '</TR>' skip.



    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("forename",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Forename")
        ELSE htmlib-SideLabel("Forename"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("forename",40,lc-forename) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-forename),'left')
           skip.
    {&out} '</TR>' skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("surname",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Surname")
        ELSE htmlib-SideLabel("Surname"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("surname",40,lc-surname) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-surname),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("jobtitle",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Job Title/Position")
        ELSE htmlib-SideLabel("Job Title/Position"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("jobtitle",20,lc-jobtitle) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-jobtitle),'left')
           skip.
    {&out} '</TR>' skip.
 

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("email",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Email")
        ELSE htmlib-SideLabel("Email"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("email",40,lc-email) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-email),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("customertrack",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Customer Track?")
        ELSE htmlib-SideLabel("Customer Track?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("customertrack", IF lc-customertrack = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-customertrack = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("telephone",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Telephone")
        ELSE htmlib-SideLabel("Telephone"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("telephone",20,lc-telephone) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-telephone),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("mobile",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Mobile")
        ELSE htmlib-SideLabel("Mobile"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("mobile",20,lc-mobile) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-mobile),'left')
           skip.
    {&out} '</TR>' skip.
       
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("factordisable",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Do NOT use SMS Two Factor Authorisation?")
        ELSE htmlib-SideLabel("Do NOT use SMS  Two Factor Authorisation?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("factordisable", IF lc-factordisable = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-factordisable = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' SKIP.
/**   
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("allowsms",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("SLA SMS Alerts?")
        ELSE htmlib-SideLabel("SLA SMS Alerts?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("allowsms", IF lc-allowsms = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-allowsms = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("accesssms",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Access SMS Web Page?")
        ELSE htmlib-SideLabel("Access SMS Web Page?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("accesssms", IF lc-accesssms = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-accesssms = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.
**/

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("pagename",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Menu Page")
        ELSE htmlib-SideLabel("Menu Page"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("pagename",20,lc-pagename) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-pagename),'left')
           skip.
    IF CAN-DO("add,update",lc-mode) THEN
    DO:
        {&out} skip
               '<td>'
               htmlib-Lookup("Lookup Page",
                             "pagename",
                             "nullfield",
                             appurl + '/lookup/menupage.p')
               '</TD>'
               skip.
    END.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("userclass",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("User Type")
        ELSE htmlib-SideLabel("User Type"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("userclass","INTERNAL|CUSTOMER|CONTRACT","Internal|Customer|Contractor",lc-userclass) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(
        lc-userclass
        ),'left')
           skip.
    {&out} '</TR>' skip.
   
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("engtype",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Engineer Type")
        ELSE htmlib-SideLabel("Engineer Type"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("engtype",lc-global-engType-Code,lc-global-engType-desc,lc-engtype) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(
        lc-engtype
        ),'left')
           skip.
    {&out} '</TR>' skip.
    
    /**/
    

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("superuser",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Super User?")
        ELSE htmlib-SideLabel("Super User?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("superuser", IF lc-superuser = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-superuser = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("accountmanager",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("TAM/CAM?")
        ELSE htmlib-SideLabel("TAM/CAM?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("accountmanager", IF lc-accountmanager = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-accountmanager = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.
    

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("quickview",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Access To Quick View?")
        ELSE htmlib-SideLabel("Access To Quick View?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("quickview", IF lc-quickview = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-quickview = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("accountnumber",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Account Number")
        ELSE htmlib-SideLabel("Account Number"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("accountnumber",8,lc-accountnumber) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-accountnumber),'left')
           skip.
    IF CAN-DO("add,update",lc-mode) THEN
    DO:
        {&out} skip
               '<td>'
               htmlib-Lookup("Lookup Account",
                             "accountnumber",
                             "nullfield",
                             appurl + '/lookup/customer.p')
               '</TD>'
               skip.
    END.
    {&out} '</TR>' skip.

   
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("disabled",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Disabled?")
        ELSE htmlib-SideLabel("Disabled?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("disabled", IF lc-disabled = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-disabled = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("defaultuser",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Main Customer Issue Contact?")
        ELSE htmlib-SideLabel("Main Customer Issue Contact?"))
            
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("defaultuser", IF lc-defaultuser = 'on'
        THEN TRUE ELSE FALSE) 
          
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-defaultuser = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.
    
     
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("custinv",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Customer Can View Inventory?")
        ELSE htmlib-SideLabel("Customer Can View Inventory?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("custinv", IF lc-custinv = 'on'
        THEN TRUE ELSE FALSE) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-custinv = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.
    

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("disabletimeout",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Disable Web Timeout?")
        ELSE htmlib-SideLabel("Disable Web Timeout?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("disabletimeout", IF lc-DisableTimeout = 'on'
        THEN TRUE ELSE FALSE) 
          
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-DisableTimeout = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.
    /* */
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("emailtimereport",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Email Engineer Log Report?")
        ELSE htmlib-SideLabel("Email Engineer Log Report?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-CheckBox("emailtimereport", IF lc-EmailTimeReport = 'on'
        THEN TRUE ELSE FALSE) 
          
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-EmailTimeReport = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.
    /* */
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("iss-survey",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Send Surveys?")
        ELSE htmlib-SideLabel("Send Surveys?"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
   htmlib-CheckBox("iss-survey", IF lc-iss-survey = 'on'
    THEN TRUE ELSE FALSE) 
          
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-iss-survey = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</TR>' skip.
    /* */
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("recordperpage",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Records Per Page")
        ELSE htmlib-SideLabel("Records Per Page"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("recordsperpage",2,lc-recordsperpage) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-recordsperpage),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Assigned Support Teams")
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
    DO:
        {&out} '<TD VALIGN="TOP" ALIGN="left">'.

        {&out} htmlib-StartMntTable().

        FOR EACH steam NO-LOCK WHERE STEAM.companycode = lc-global-company:

            li-count = li-count + 1.
            IF li-count = 1 THEN
            DO:
                {&out} '<tr>' SKIP.

            END.
            lc-html = "steam" + STRING(steam.st-num).
            ll-check = get-value(lc-html) = "on".
            {&out} '<td>' htmlib-CheckBox(lc-html,ll-check) 
            ' - '  html-encode(steam.descr) '</td>' SKIP.
            IF li-count MOD li-row = 0 THEN
            DO:
                {&out} '</tr>'.
                li-count = 0.
            END.


        END.
        {&out} htmlib-EndTable() skip.

        {&out} '</TD>' skip.
    END.
    ELSE
    DO:
        {&out} '<TD VALIGN="TOP" ALIGN="left">'.

        {&out} htmlib-StartMntTable().

        FOR EACH steam NO-LOCK WHERE STEAM.companycode = lc-global-company:

            lc-html = "steam" + STRING(steam.st-num).
            ll-check = get-value(lc-html) = "on".
            IF NOT ll-check THEN NEXT.

            li-count = li-count + 1.
            IF li-count = 1 THEN
            DO:
                {&out} '<tr>' SKIP.

            END.
            
            {&out} '<td>' html-encode(steam.descr) '</td>' SKIP.
            IF li-count MOD li-row = 0 THEN
            DO:
                {&out} '</tr>'.
                li-count = 0.
            END.


        END.
        {&out} htmlib-EndTable() skip.

        {&out} '</TD>' skip.

     
    END.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Dashboards")
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
    DO:
        {&out} '<TD VALIGN="TOP" ALIGN="left">'.

        ASSIGN li-count = 0.
        
        {&out} htmlib-StartMntTable().

        FOR EACH dashb NO-LOCK WHERE dashb.companycode = lc-global-company:

            li-count = li-count + 1.
            IF li-count = 1 THEN
            DO:
                {&out} '<tr>' SKIP.

            END.
            lc-html = "dash" + STRING(ROWID(dashb)).
            ll-check = get-value(lc-html) = "on".
            {&out} '<td>' htmlib-CheckBox(lc-html,ll-check) 
            ' - '  html-encode(dashb.descr) '</td>' SKIP.
            IF li-count MOD li-row = 0 THEN
            DO:
                {&out} '</tr>'.
                li-count = 0.
            END.


        END.
        {&out} htmlib-EndTable() skip.

        {&out} '</TD>' skip.
    END.
    ELSE
    DO:
        {&out} '<TD VALIGN="TOP" ALIGN="left">'.

        ASSIGN li-count = 0.
        
        {&out} htmlib-StartMntTable().

        FOR EACH dashb NO-LOCK WHERE dashb.companycode = lc-global-company:

            li-count = li-count + 1.
            IF li-count = 1 THEN
            DO:
                {&out} '<tr>' SKIP.

            END.
            lc-html = "dash" + STRING(ROWID(dashb)).
            ll-check = get-value(lc-html) = "on".
            IF NOT ll-check THEN NEXT.
            
            {&out} '<td>' html-encode(dashb.descr) '</td>' SKIP.
            IF li-count MOD li-row = 0 THEN
            DO:
                {&out} '</tr>'.
                li-count = 0.
            END.


        END.
        {&out} htmlib-EndTable() skip.

        {&out} '</TD>' skip.
    END.
    

    {&out} '</TR>' skip.


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-ResetOtherMain) = 0 &THEN

PROCEDURE ip-ResetOtherMain :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-companycode      AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-accountNumber    AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-loginid          AS CHARACTER     NO-UNDO.

    DEFINE BUFFER b-user   FOR webUser.

    
    FOR EACH b-user EXCLUSIVE-LOCK
        WHERE b-user.companyCode = pc-companyCode
        AND b-user.AccountNumber = pc-AccountNumber:

        IF b-user.LoginId <> pc-LoginId
            THEN ASSIGN b-user.defaultUser = FALSE.
    END.
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


    DEFINE VARIABLE li-int      AS INTEGER      NO-UNDO.

    IF lc-mode = "ADD":U THEN
    DO:
        IF lc-loginid = ""
            OR lc-loginid = ?
            THEN RUN htmlib-AddErrorMessage(
                'loginid', 
                'You must enter the user name',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        

        IF CAN-FIND(FIRST b-valid
            WHERE b-valid.loginid = lc-loginid
            NO-LOCK)
            THEN RUN htmlib-AddErrorMessage(
                'loginid', 
                'This user already exists',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).

    END.

    IF lc-forename = ""
        OR lc-forename = ?
        THEN RUN htmlib-AddErrorMessage(
            'forename', 
            'You must enter the forename',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF lc-surname = ""
        OR lc-surname = ?
        THEN RUN htmlib-AddErrorMessage(
            'surname', 
            'You must enter the surname',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
/*
    IF lc-allowsms = "on"
        AND lc-mobile = ""
        THEN RUN htmlib-AddErrorMessage(
            'allowsms', 
            'To allow SLA SMS alert messages you must enter a mobile number',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF lc-allowsms = "on"
        AND lc-userClass = "CUSTOMER"
        THEN RUN htmlib-AddErrorMessage(
            'allowsms', 
            'SLA SMS alert messages can not be sent to a customer',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    IF lc-accesssms = "on"
        AND lc-userClass = "CUSTOMER"
        THEN RUN htmlib-AddErrorMessage(
            'accesssms', 
            'Access to the SMS web page is restricted to internal users',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
*/

    IF lc-userClass <> "INTERNAL"
        AND lc-superuser = "on" THEN
    DO:
        RUN htmlib-AddErrorMessage(
            'superuser', 
            'Only Internal users can be super users',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    END.
    
    IF lc-userClass <> "INTERNAL"
        AND lc-accountmanager = "on" THEN
    DO:
        RUN htmlib-AddErrorMessage(
            'accountmanager', 
            'Only Internal users can be TAM/CAM',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    END.
    IF lc-userClass = "CUSTOMER"
        AND lc-quickview = "on" THEN
    DO:
        RUN htmlib-AddErrorMessage(
            'quickview', 
            'Only Internal users can have access to the quick view menu',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    END.

    IF lc-userClass = "CUSTOMER"
    AND lc-engtype <> "" THEN
    DO:
        RUN htmlib-AddErrorMessage(
            'engtype', 
            'Only Internal users should have an engineer type',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    END.
    
    IF lc-userclass <> "CUSTOMER"
        AND lc-accountnumber <> "" THEN
    DO:
        RUN htmlib-AddErrorMessage(
            'userclass', 
            'Internal/Contractor users do not have an account',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    END.
    ELSE
        IF lc-userclass = "CUSTOMER"
            AND lc-accountnumber = "" THEN
        DO:
            RUN htmlib-AddErrorMessage(
                'accountnumber', 
                'You must enter an account',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        END.

    IF lc-accountnumber <> "" THEN
    DO:
        IF NOT CAN-FIND(customer WHERE customer.company = lc-global-company AND customer.accountnumber = lc-accountnumber NO-LOCK)
            THEN RUN htmlib-AddErrorMessage(
                'accountnumber', 
                'This account does not exist',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
    END.

    ASSIGN 
        li-int = int(lc-recordsperpage) no-error.
    IF ERROR-STATUS:ERROR 
        OR li-int < 5 THEN RUN htmlib-AddErrorMessage(
            'recordsperpage', 
            'This number of records to display must be 5 or greater',
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
    
    DEFINE VARIABLE li-loop  AS INTEGER  NO-UNDO.

    {lib/checkloggedin.i} 


    ASSIGN 
        lc-usertitleCode = htmlib-GetAttr("USER","Titles").

    IF lc-usertitleCode =  "" 
        THEN ASSIGN lc-usertitleCode = 'Mr|Mrs'.

    ASSIGN 
        lc-usertitleDesc = lc-usertitleCode.


    ASSIGN 
        lc-mode = get-value("mode")
        lc-rowid = get-value("rowid")
        lc-search = get-value("search")
        lc-firstrow = get-value("firstrow")
        lc-lastrow  = get-value("lastrow")
        lc-navigation = get-value("navigation")
        lc-selacc    = get-value("selacc")
        li-curr-year  = INTEGER(get-value("submityear")).

    IF li-curr-year = ? OR li-curr-year = 0 THEN li-curr-year = YEAR(TODAY).

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
                           "&lastrow=" + lc-lastrow +
                           "&selacc=" + lc-SelAcc + 
                           "&submityear=" + string(li-curr-year).

    CASE lc-mode:
        WHEN 'add'
        THEN 
            ASSIGN 
                lc-title = 'Add'
                lc-link-label = "Cancel addition"
                lc-submit-label = "Add User".
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
                lc-submit-label = 'Delete User'.
        WHEN 'Update'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update User'.
    END CASE.


    ASSIGN 
        lc-title = lc-title + ' User'
        lc-link-url = appurl + '/sys/webuser.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&selacc=' + lc-selacc + 
                                  '&submityear=' + string(li-curr-year) +
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
            set-user-field("nexturl",appurl + "/sys/webuser.p").
            RUN run-web-object IN web-utilities-hdl ("mn/deleted.p").
            RETURN.
        END.

    END.


    IF request_method = "POST" THEN
    DO:
        IF lc-mode <> "delete" THEN
        DO:
            ASSIGN 
                lc-loginid         = get-value("loginid")
                lc-forename        = get-value("forename")
                lc-surname         = get-value("surname")
                lc-email           = get-value("email")
                lc-usertitle       = get-value("usertitle")
                lc-pagename        = get-value("pagename")
                lc-disabled        = get-value("disabled")
                lc-accountnumber   = get-value("accountnumber")
                lc-Jobtitle        = get-value("jobtitle")
                lc-telephone       = get-value("telephone")
                lc-password        = get-value("password")
                lc-userclass       = get-value("userclass")
                lc-customertrack   = get-value("customertrack")
                lc-recordsperpage  = get-value("recordsperpage")
                lc-allowsms        = get-value("allowsms")
                lc-mobile          = get-value("mobile")
                lc-accesssms       = get-value("accesssms")
                lc-superuser       = get-value("superuser")
                lc-accountmanager  = get-value("accountmanager")
                lc-quickview       = get-value("quickview")
                lc-defaultuser     = get-value("defaultuser")
                lc-disableTimeout  = get-value("disabletimeout")
                lc-custinv         = get-value("custinv")
                lc-engtype         = get-value("engtype")
                lc-EmailTimeReport = get-value("emailtimereport")
                lc-iss-survey       = get-value("iss-survey")
                lc-FactorDisable    = get-value("factordisable")
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
                        b-table.loginid = lc-loginid
                        b-table.CompanyCode = lc-global-company
                        lc-firstrow      = STRING(ROWID(b-table))
                        .
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    IF lc-disabled = "on" AND b-table.disabled = FALSE 
                        THEN com-SystemLog("OK:AccountDisabled",b-table.loginid,"By " + lc-global-user).
                        
                    IF lc-disabled <> "on" AND b-table.disabled = TRUE 
                        THEN com-SystemLog("OK:AccountEnabled",b-table.loginid,"By " + lc-global-user).
                            
                    ASSIGN 
                        b-table.forename         = lc-forename
                        b-table.surname          = lc-surname
                        b-table.email            = lc-email
                        b-table.usertitle        = lc-usertitle
                        b-table.pagename         = lc-pagename
                        b-table.disabled         = lc-disabled = 'on'
                        b-table.customertrack    = lc-customertrack = 'on'
                        b-table.accountnumber    = lc-accountnumber
                        b-table.jobtitle         = lc-jobtitle
                        b-table.telephone        = lc-telephone
                        b-table.userclass        = lc-userclass
                        b-table.recordsperpage   = int(lc-recordsperpage)
                        b-table.mobile           = lc-mobile
                        b-table.allowsms         = lc-allowsms = "on"
                        b-table.accesssms        = lc-accesssms = "on"
                        b-table.superuser        = lc-superuser = "on"
                        b-table.accountmanager   = lc-accountmanager = "on"
                        b-table.quickview        = lc-quickview = "on"
                        b-table.defaultuser      = lc-defaultuser = "on"
                        b-table.disabletimeout   = lc-disabletimeout = "on"
                        b-table.CustomerViewInventory = lc-custinv = 'on'
                        b-table.engtype               = lc-engtype
                        b-table.dashbList           = ""
                        b-table.EmailTimeReport     = lc-EmailTimeReport = 'on'
                        b-table.iss_survey      = lc-iss-survey = "on"
                        b-table.twofactor_Disable = lc-factordisable = "on"
                        .
                    ASSIGN 
                        b-table.name = b-table.forename + ' ' + 
                                          b-table.surname.
                    IF lc-password <> "" THEN 
                    DO:
                        ASSIGN 
                            b-table.Passwd = ENCODE(lc-password)
                            b-table.LastPasswordChange = TODAY.
                            
                        com-SystemLog("OK:PasswordChanged",b-table.loginid,"By " + lc-global-user).    
                            
                    
                    END.
                    FOR EACH webusteam OF b-table  EXCLUSIVE-LOCK:
                    
                        DELETE webusteam.
                    END.
                    FOR EACH steam NO-LOCK
                        WHERE steam.companycode = lc-global-company:
                        lc-html = "steam" + STRING(steam.st-num).
                        IF get-value(lc-html) <> "on" THEN NEXT.
                        CREATE webuSteam.
                        ASSIGN
                            webuSteam.LoginID = b-table.loginid
                            webuSteam.st-num = steam.st-num.

                    END.
                    FOR EACH dashb NO-LOCK WHERE dashb.CompanyCode = b-table.companyCode:
                        lc-html = "dash" + string(ROWID(dashb)). 
                        IF get-value(lc-html) <> "on" THEN NEXT.
                        IF b-table.dashbList = ""
                        THEN b-table.dashblist = dashb.dashCode.
                        ELSE b-table.dashblist = b-table.dashblist + "," + dashb.dashCode.
                    END.
                    IF b-table.UserClass = "customer"
                        AND b-table.AccountNumber <> ""
                        AND b-table.DefaultUser = TRUE THEN 
                    DO:
                        b-table.CustomerTrack = TRUE.
                        RUN ip-ResetOtherMain ( lc-global-company,
                            b-table.AccountNumber,
                            b-table.LoginId ).
                    END.
                    
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
            ELSE 
            DO:
                FOR EACH webusteam OF b-table  EXCLUSIVE-LOCK:
                    
                    DELETE webusteam.
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
            set-user-field("selacc",lc-selacc).
            RUN run-web-object IN web-utilities-hdl ("sys/webuser.p").
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        ASSIGN 
            lc-loginid = b-table.loginid.
        IF request_method = "GET" THEN
        DO:
            FOR EACH dashb NO-LOCK WHERE dashb.CompanyCode = b-table.companyCode:
                lc-html = "dash" + string(ROWID(dashb)). 
                
                IF LOOKUP(dashb.dashCode,b-table.dashbList) > 0
                THEN set-user-field(lc-html,"on").
            END.
            FOR EACH webUsteam OF b-table NO-LOCK:
                
                lc-html = "steam" + STRING(webusteam.st-num).
                set-user-field(lc-html,"on").

            END.
        END.

        IF CAN-DO("view,delete",lc-mode) 
            OR request_method <> "post" THEN 
        DO:
            ASSIGN 
                lc-surname        = b-table.surname
                lc-email          = b-table.email
                lc-forename       = b-table.forename
                lc-usertitle      = b-table.usertitle
                lc-pagename       = b-table.pagename
                lc-disabled       = IF b-table.disabled THEN 'on' ELSE ''
                lc-accountnumber  = b-table.accountnumber
                lc-jobtitle       = b-table.jobtitle
                lc-telephone      = b-table.telephone
                lc-userclass      = b-table.userclass
                lc-customertrack  = IF b-table.customertrack THEN 'on' ELSE ''
                lc-recordsperpage = STRING(b-table.recordsperpage)
                lc-mobile         = b-table.mobile
                lc-accesssms      = IF b-table.accesssms THEN 'on' ELSE ''
                lc-allowsms       = IF b-table.allowsms THEN 'on' 
                                    ELSE ''
                lc-superuser      = IF b-table.superuser THEN 'on'
                                    ELSE ''
                lc-accountmanager = IF b-table.accountmanager THEN 'on'
                                    ELSE ''
                lc-quickview      = IF b-table.QuickView THEN 'on' 
                                    ELSE '' 
                lc-defaultuser    = IF b-table.DefaultUser THEN 'on'
                                    ELSE ''
                lc-disableTimeout  = IF b-table.disabletimeout THEN 'on'
                                    ELSE ''
                lc-custinv         = IF b-table.CustomerViewInventory THEN 'on'
                                    ELSE ''
                lc-engtype         = b-table.engtype
                lc-emailtimereport = IF b-table.EmailTimeReport THEN 'on' ELSE ''
                lc-iss-survey = IF b-table.iss_survey THEN "on" ELSE ""
                lc-factorDisable = IF b-table.twofactor_disable THEN "on" ELSE ""
                .
            
        END.

       
    END.
    
    IF request_method = "GET" AND lc-mode = "ADD" THEN
    DO:
        ASSIGN 
            lc-recordsperpage = "10".

        IF lc-selacc <> "ALLC"
            AND lc-selacc <> ""
            AND lc-selacc <> "INTERNAL" THEN
        DO:
            ASSIGN 
                lc-userClass = "CUSTOMER"
                lc-accountnumber = lc-selacc.
        END.
    END.

    RUN outputHeader.
    
    {&out} htmlib-Header(lc-title) skip
           htmlib-StartForm("mainform","post", selfurl )
           htmlib-ProgramTitle(lc-title) skip.
    /*
    ***
    *** Force blank password on add/update ( can be autocompleted by the browser )
    ***
    */
    IF lc-mode = "ADD"
    OR lc-mode = "UPDATE" THEN
        {&out} '<script language="javascript">' SKIP
            'window.onload = pgload;' SKIP
            'function pgload() ~{' SKIP
            'var FieldName = "password"' SKIP
            'document.mainform.elements[FieldName].value = ""' SKIP
            '}'  skip
            '</script>' SKIP.

    {&out} '<script language="JavaScript"> var debugThis         = true; </script>' skip.
    {&out} '<script language="JavaScript" src="/scripts/js/validate.js"></script>' skip.


    {&out} htmlib-Hidden ("savemode", lc-mode) SKIP
           htmlib-Hidden ("submityear", string(li-curr-year)) skip
           htmlib-Hidden ("saverowid", lc-rowid) skip
           htmlib-Hidden ("savesearch", lc-search) skip
           htmlib-Hidden ("savefirstrow", lc-firstrow) skip
           htmlib-Hidden ("savelastrow", lc-lastrow) skip
           htmlib-Hidden ("savenavigation", lc-navigation) skip
           htmlib-Hidden ("nullfield", lc-navigation) SKIP
           htmlib-Hidden ("selacc", lc-selacc) SKIP.
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' skip.

    
    {&out} REPLACE(htmlib-StartInputTable(),"mnt","MainTable") skip.

    

    RUN ip-Page.          


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

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-html-InputFieldMasked) = 0 &THEN

FUNCTION html-InputFieldMasked RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pc-maxlength AS CHARACTER,
    pc-datatype AS CHARACTER,
    pc-mask AS CHARACTER,
    pc-value AS CHARACTER,
    pc-style AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE r-htm AS CHARACTER NO-UNDO.
   
    r-htm = '<input type="text" id="' + pc-name + '" name="' + pc-name + '" value="' + pc-value + '"' +
        ' maxlength="' + pc-maxlength + '" datatype="' + pc-datatype + '" mask="' + pc-mask + '"' +
        ' onpaste="return tbPaste(this);"' +
        ' onfocus="return tbFocus(this);"' +
        ' onkeydown="return tbFunction(this);"' +
        ' onkeypress="return tbMask(this);"' +
        ' style="' + pc-style + '">'.
        
    RETURN r-htm.

END FUNCTION.


&ENDIF

