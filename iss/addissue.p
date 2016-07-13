/***********************************************************************

    Program:        iss/addissue.p
    
    Purpose:        Add Issue 
    
    Notes:
    
    
    When        Who         What
    06/04/2006  phoski      SearchField populate
    10/04/2006  phoski      CompanyCode
    02/06/2006  phoski      Category
    16/07/2006  phoski      Create from email
    18/07/2006  phoski      Ticket Job
    
    09/08/2010  DJS         3667 - view only active co's & users
    24/04/2014  Phoski      Timer problem when customer is creating
                            & various
    23/07/2014  phoski      Telephone on add user default's to customer  
    08/12/2014  phoski      Fix timer  
    16/12/2014  phoski      Timer hour and page submit 
    24/01/2015  phoski      Default to correct contract       
    07/03/2015  phoski      Send email to support when client add's an 
                            issue ( unassigned issue so this lets them 
                            know )   
    25/04/2015  phoski      End date/end time is calculated now  
    29/03/2015  phoski      Complex Project Class                                
    07/06/2015  phoski      webissCont ( removed description from DB )  
    15/08/2015  phoski      Default user change  
    19/08/2015  phoski      Company.custaddissue get email when customer
                            adds unassigned
    20/10/2015  phoski      com-GetHelpDeskEmail for email sender  
    14/11/2015  phoski      No Ad hoc contract and a type must be entered  
    23/02/2016  phoski      isDecom flag     
    13/03/2016  phoski      Customer view on action default to yes   
    01/07/2016  phoski      Shorten name in customer combo   
    02/07/2016  phoski      issActivity.ActivityType    
    02/07/2016  phoski      com-GetTicketBalance for ticket balance
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE v-debug             AS LOG       INITIAL FALSE NO-UNDO.

DEFINE VARIABLE lf-Audit            AS DECIMAL   NO-UNDO.

DEFINE VARIABLE lc-error-field      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-accountnumber    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-briefdescription AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-longdescription  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submitsource     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-raisedlogin      AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-issue            AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-date             AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-AreaCode         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Address          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Ticket           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title            AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-number      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-name        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-login       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-lname       AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-list-area        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-aname       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-gotomaint        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-sla-rows         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sla-selected     AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll-customer         AS LOG       NO-UNDO.

DEFINE VARIABLE lc-default-catcode  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-catcode          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-catcode     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-cname       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-iclass           AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-issuesource      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-emailid          AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-actcode     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-actdesc     AS CHARACTER NO-UNDO.

/* Action Stuff */

DEFINE VARIABLE lc-Quick            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-actioncode       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ActionNote       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-CustomerView     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-activitycharge   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-actionstatus     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-assign      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-assname     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-currentassign    AS CHARACTER NO-UNDO.


/* Activity */
DEFINE VARIABLE lc-hours            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mins             AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-secs             AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-hours            AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-mins             AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-StartDate        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-starthour        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-startmin         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-endDate          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-endhour          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-endmin           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ActDescription   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-actid       AS CHARACTER NO-UNDO.  
DEFINE VARIABLE lc-list-activtype   AS CHARACTER NO-UNDO. 
DEFINE VARIABLE lc-list-activdesc   AS CHARACTER NO-UNDO.  
DEFINE VARIABLE lc-list-activtime   AS CHARACTER NO-UNDO. 


DEFINE VARIABLE lc-activitytype     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-saved-contract   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-saved-billable   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-saved-activity   AS CHARACTER NO-UNDO.

/* Status */
DEFINE VARIABLE lc-list-status      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-sname       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-currentstatus    AS CHARACTER NO-UNDO.

/* Contract stuff  */

DEFINE VARIABLE lc-list-ctype       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-cdesc       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-contract-type    AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-billable-flag    AS CHARACTER NO-UNDO.

DEFINE VARIABLE ll-billing          AS LOG       NO-UNDO.
DEFINE VARIABLE lc-timeSecondSet    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-timeMinuteSet    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-timehourset      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-DefaultTimeSet   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-manChecked       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-Enc-Key          AS CHARACTER NO-UNDO.
DEFINE BUFFER webStatus FOR webStatus.

/** Adding user on the fly */

DEFINE VARIABLE lc-uadd-loginid AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-uadd-name    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-uadd-email   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-uadd-phone   AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-inv-key      AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-mail         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-subject      AS CHARACTER NO-UNDO.
                    


/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-Format-Select-Account) = 0 &THEN

FUNCTION Format-Select-Account RETURNS CHARACTER
    ( pc-htm AS CHARACTER )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Select-Activity) = 0 &THEN

FUNCTION Format-Select-Activity RETURNS CHARACTER
    ( pc-htm AS CHARACTER  )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Select-Desc) = 0 &THEN

FUNCTION Format-Select-Desc RETURNS CHARACTER
    ( pc-htm AS CHARACTER  )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Select-Duration) = 0 &THEN

FUNCTION Format-Select-Duration RETURNS CHARACTER
    ( pc-htm AS CHARACTER   )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-Get-Activity) = 0 &THEN

FUNCTION Get-Activity RETURNS INTEGER
    ( pc-inp AS CHARACTER)  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-htmlib-ThisInputField) = 0 &THEN

FUNCTION htmlib-ThisInputField RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pi-size AS INTEGER,
    pc-value AS CHARACTER )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-Return-Submit-Button) = 0 &THEN

FUNCTION Return-Submit-Button RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pc-value AS CHARACTER,
    pc-post AS CHARACTER
    )  FORWARD.


&ENDIF


/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 10.31
         WIDTH              = 30.57.
/* END WINDOW DEFINITION */
                                                                        */

/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}
{lib/htmlib.i}
{iss/issue.i}
{lib/ticket.i}



 




/* ************************  Main Code Block  *********************** */

FIND FIRST webStatus
    WHERE webStatus.CompanyCode = lc-global-company
    AND webStatus.CompletedStatus = TRUE NO-LOCK NO-ERROR.                                   
                                   
/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-AreaSelect) = 0 &THEN

PROCEDURE ip-AreaSelect :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    {&out}  skip
            '<select id="areacode" name="areacode" class="inputfield">' skip.
    {&out}
    '<option value="' DYNAMIC-FUNCTION("htmlib-Null") '" ' 
    IF lc-AreaCode = dynamic-function("htmlib-Null") 
        THEN "selected" 
    ELSE "" '>Select Area</option>' skip
            '<option value="" ' if lc-AreaCode = ""
                then "selected" else "" '>Not Applicable/Unknown</option>' skip        
    .
    FOR EACH webIssArea NO-LOCK
        WHERE webIssArea.CompanyCode = lc-Global-Company 
        BREAK BY webIssArea.GroupID
        BY webIssArea.AreaCode:

        IF FIRST-OF(webissArea.GroupID) THEN
        DO:
            FIND webissagrp
                WHERE webissagrp.companycode = webissArea.CompanyCode
                AND webissagrp.Groupid     = webissArea.GroupID NO-LOCK NO-ERROR.
            {&out}
            '<optgroup label="' html-encode(IF AVAILABLE webissagrp THEN webissagrp.description ELSE "Unknown") '">' skip.
        END.

        {&out}
        '<option value="' webIssArea.AreaCode '" ' 
        IF lc-AreaCode = webIssArea.AreaCode  
            THEN "selected" 
        ELSE "" '>' html-encode(webIssArea.Description) '</option>' skip.

        IF LAST-OF(WebIssArea.GroupID) THEN {&out} '</optgroup>' skip.
    END.

    {&out} '</select>'.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-ContractSelect) = 0 &THEN

PROCEDURE ip-ContractSelect :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
  
    {&out}  skip
            '<select id="selectcontract" name="selectcontract" class="inputfield"  onchange=~"javascript:ChangeContract();~">' skip.
    {&out}
    '<option value="SELECT|yes" >Select Contract Type</option>' skip
    .
 


    IF lc-accountnumber <> "" THEN
    DO:

        IF lc-saved-contract <> "" THEN  
        DO:
            ASSIGN 
                lc-contract-type = lc-saved-contract
                ll-billing       = lc-saved-billable = "on"
                lc-billable-flag = lc-saved-billable.
        END.
        
        /*
        *** 
        *** Default contract for client
        ***
        */
        IF lc-submitsource = "AccountChange" THEN
        DO:
            FIND FIRST WebIssCont                           
                WHERE WebIssCont.CompanyCode     = lc-global-company     
                AND WebIssCont.Customer        = lc-accountnumber            
                AND WebIssCont.ConActive       = TRUE
                AND WebissCont.defcon          = TRUE NO-LOCK NO-ERROR.
            IF AVAILABLE WebissCont
                THEN ASSIGN lc-contract-type = /* WebissCont.ContractCode */ "SELECT"
                    ll-billing       = WebissCont.Billable
                    lc-billable-flag = IF ll-billing THEN "on" ELSE "".
        END.
        ELSE
        IF request_method <> "GET" THEN
        DO:
            lc-contract-type = ENTRY(1,get-value("selectcontract"),"|").
        END.
      
 
        IF CAN-FIND (FIRST WebIssCont                           
            WHERE WebIssCont.CompanyCode     = lc-global-company     
            AND WebIssCont.Customer        = lc-accountnumber            
            AND WebIssCont.ConActive       = TRUE ) 
            THEN
        DO:

            FOR EACH WebIssCont NO-LOCK                             
                WHERE WebIssCont.CompanyCode     = lc-global-company     
                AND WebIssCont.Customer        = lc-accountnumber            
                AND WebIssCont.ConActive       = TRUE
                :                 

                FIND FIRST ContractType  WHERE ContractType.CompanyCode = WebIssCont.CompanyCode
                    AND  ContractType.ContractNumber = WebIssCont.ContractCode 
                    NO-LOCK NO-ERROR.
                                      
                IF WebIssCont.DefCon AND lc-saved-contract = "" THEN 
                    ASSIGN lc-contract-type = WebIssCont.ContractCode
                        ll-billing       = WebissCont.Billable
                        lc-billable-flag = IF ll-billing THEN "on" ELSE "".

                {&out}
                '<option value="' WebIssCont.ContractCode "|" STRING(WebissCont.Billable) '" ' 
             
                IF lc-contract-type = WebIssCont.ContractCode
                    THEN " selected " 
                ELSE "" '>' 
                  
                html-encode(IF AVAILABLE ContractType THEN ContractType.Description ELSE "Unknown") '</option>' skip.
 
            END.
        END.
    END.
      

    {&out} '</select>'.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-ExportJScript) = 0 &THEN

PROCEDURE ip-ExportJScript :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/


 
    {&out} skip 
       '<script language="JavaScript">' skip
       'var manualTime = false;' skip

       ' function ChangeDuration() ' skip
       '~{' skip
       '  var curHourDuration   = parseInt(document.mainform.ffhours.value,10) ' skip
       '  var curMinDuration    = parseInt(document.mainform.ffmins.value,10)  ' skip
       '  var startDate         = parseInt(document.mainform.startdate.value,10) ' skip
       '  var endDate           = parseInt(document.mainform.enddate.value,10)  ' skip
       '  var endHourOption     = parseInt(document.getElementById("endhour").value,10); ' skip
       '  var endMinuteOption   = parseInt(document.getElementById("endmin").value,10);' skip
       '  var startHourOption   = parseInt(document.getElementById("starthour").value,10); ' skip
       '  var startMinuteOption = parseInt(document.getElementById("startmin").value,10);' skip
       '  var startTime         = internalTime(startHourOption,startMinuteOption) ; '  skip
       '  var endTime           = internalTime(endHourOption,endMinuteOption) ; '  skip
       '  var durationTime      = internalTime(curHourDuration,curMinDuration) ; '  skip
       '  document.mainform.manualTime.checked = true;' skip
       '  document.mainform.ffmins.value = (curMinDuration < 10 ? "0" : "") + curMinDuration ;' skip
       '  manualTime = true; ' skip 


/*        '  document.mainform.ffmins.value = (curMinDuration < 10 ? "0" : "") + curMinDuration ;' skip                                                         */
/*        '  if (manualTime) return;  ' skip                                                                                                                    */
/*        '  if ( (endTime - startTime) != 0  || (endTime - startTime) != durationTime || !manualTime )' skip                                                   */
/*        '  ~{' skip                                                                                                                                           */
/*        '      alert("The duration entered does not match with the Start and End time! ~\n ~\n                              Setting to Manual Time."); ' skip */
/*        '      document.getElementById("throbber").src="/images/ajax/ajax-loaded-red.gif"; ' skip                                                             */
/*        '      document.mainform.manualTime.checked = true; ' skip                                                                                            */
/*        '      manualTime = true; ' skip                                                                                                                      */
/*        '  ~}' skip                                                                                                                                           */
       '~}' skip.

    /*
    ***
    *** only for internal users, customer don't have a timer
    ***
    */
    IF NOT ll-customer THEN
        {&out}
      
    ' function PrePost(Indx) ' skip
      '~{' skip
       '  var curHourDuration   = parseInt(document.mainform.ffhours.value,10) ' skip
       '  var curMinDuration    = parseInt(document.mainform.ffmins.value,10)  ' skip
       '  var startDate         = parseInt(document.mainform.startdate.value,10) ' skip
       '  var endDate           = parseInt(document.mainform.enddate.value,10)  ' skip
       '  var endHourOption     = parseInt(document.getElementById("endhour").value,10); ' skip
       '  var endMinuteOption   = parseInt(document.getElementById("endmin").value,10);' skip
       '  var startHourOption   = parseInt(document.getElementById("starthour").value,10); ' skip
       '  var startMinuteOption = parseInt(document.getElementById("startmin").value,10);' skip
       '  var startTime         = internalTime(startHourOption,startMinuteOption) ; '  skip
       '  var endTime           = internalTime(endHourOption,endMinuteOption) ; '  skip
       '  var durationTime      = internalTime(curHourDuration,curMinDuration) ; '  SKIP
       '  document.forms["mainform"].submit();' SKIP
       /**
      '  if ( (endTime - startTime) != 0  && (endTime - startTime) != durationTime )' skip
      '  ~{' skip
      '     var answer = confirm("The duration entered does not match with the Start and End time! ~\n ~\n      Press Cancel if you want to update the times before posting"); ' skip
      '     if (answer) ~{ document.forms["mainform"].submit();  ~} ' skip
      '     else  ~{ return false;  ~} ' skip
      '  ~}' skip
      '  else ~{ document.forms["mainform"].submit();  ~} ' skip
      **/
      '~}' skip.
    ELSE
    {&out}
    ' function PrePost(Indx) ' skip
      '~{' skip
       
      '  document.forms["mainform"].submit();   ' skip
      '~}' skip.



    {&out} SKIP



       'function internalTime(piHours,piMins) ' skip
       '~{' skip
       '  return ( ( piHours * 60 ) * 60 ) + ( piMins * 60 ); ' skip
       '~}' skip.

    {&out} skip
        'function ChangeAccount() ~{' skip
        '   SubmitThePage("AccountChange")' skip
        '~}' skip.

    {&out} skip
        'function Quick(box) ~{' skip
        ' if ( box.checked == true) ~{' skip
        '   document.mainform.actionstatus.value="CLOSED";' skip.
    IF AVAILABLE webStatus 
        THEN {&out} '   document.mainform.currentstatus.value="' webStatus.StatusCode '";' skip.
    {&out}
    '   return;' skip
        '~}' skip
        '   document.mainform.actionstatus.value="OPEN";' skip
        '   document.mainform.currentstatus.value="' entry(1,lc-list-status,"|") '";' skip
        '~}' skip.
    {&out} skip
        '</script>' skip.

    {&out} 
    '<script>' skip
        'function copyinfo() ~{' skip
        'document.mainform.elements["actionnote"].value = document.mainform.elements["longdescription"].value' skip
        '~}' skip
        '</script>' skip.

    {&out} 
    '<script type="text/javascript" language="JavaScript">' skip
      '// --  Clock --' skip
      'var timerID = null;' skip
      'var timerRunning = false;' skip
      'var timerStart = null;' skip
      'var timeSet = null;' skip
      'var defaultTime = parseInt(' lc-DefaultTimeSet ',10);' skip
      'var timeSecondSet = parseInt(' lc-timeSecondSet ',10);' skip
      'var timeMinuteSet = parseInt(' lc-timeMinuteSet ',10);' skip
      'var timeHourSet =  ' string(integer(lc-timeHourSet)) ';' SKIP
      'var timerStartseconds = 0;' skip
      
      'function manualTimeSet()~{' skip
      'manualTime = (manualTime == true) ? false : true;' skip
      'if (!manualTime) ~{document.getElementById("throbber").src="/images/ajax/ajax-loader-red.gif"~}' skip
      'else ~{document.getElementById("throbber").src="/images/ajax/ajax-loaded-red.gif"~}' skip
      '~}' skip

      'function stopclock()~{' skip
      'if(timerRunning)' skip
      'clearTimeout(timerID);' skip
      'timerRunning = false;' skip
      '~}' skip

      'function startclock()~{' skip
      'stopclock();' skip
      /*'timeHourSet = 0;' skip */
      'document.getElementById("clockface").innerHTML =  "00" +   ((defaultTime < 10) ? ":0" : ":") + defaultTime  + ":00" ' skip
      'document.mainform.ffmins.value = ((defaultTime < 10) ? "0" : "") + defaultTime ' skip
      'showtime();' skip
      '~}' SKIP
    .
      
     
    {&out}
    
    'function showtime()~{' skip
      'var curMinuteOption;' skip
      'var curHourOption;' skip
      'var now = new Date()' skip
      'var hours = now.getHours()' skip
      'var minutes = now.getMinutes()' skip
      'var seconds = now.getSeconds()' skip
      'var millisec = now.getMilliseconds()' skip
      'var timeValue = "" +   hours' skip 
      'timeSecondSet = timeSecondSet + 1' skip
      'if (!manualTime)' skip
      '~{' SKIP
      'timeValue  += ((minutes < 10) ? ":0" : ":") + minutes' skip
      'timeValue  += ((seconds < 10) ? ":0" : ":") + seconds' SKIP
       
      'curHourOption = document.getElementById("endhour"  + ((hours == 0) ? "0" : "") + hours) ' skip
      'curHourOption.selected = true' skip
      'curMinuteOption = document.getElementById("endmin" + ((minutes < 10) ? "0" : "") + minutes)' skip
      'curMinuteOption.selected = true' skip
      'if ( timeSecondSet >= 60 ) ~{ timeSecondSet = 0 ; timeMinuteSet = timeMinuteSet + 1; ~}' skip
      'if ( timeMinuteSet >= 60 ) ' SKIP
      '~{ ' SKIP 
      '     timeMinuteSet = 0 ; ' SKIP
      '     timeHourSet = timeHourSet + 1; ' SKIP
      '~}' SKIP
      
      'if ( defaultTime <= timeMinuteSet || defaultTime == 0 || timeHourSet > 0)' skip
      '  ~{' skip
      '     document.mainform.ffhours.value = ((timeHourSet  < 10) ? "0" : "") + timeHourSet' skip
      '     document.mainform.ffmins.value = ((timeMinuteSet < 10) ? "0" : "") + timeMinuteSet ' skip
      '     document.getElementById("clockface").innerHTML = ((timeHourSet < 10) ? "0" : "") + timeHourSet '
      '       +   ((timeMinuteSet < 10) ? ":0" : ":") + timeMinuteSet  + ((timeSecondSet < 10) ? ":0" : ":") + timeSecondSet ' skip
      '  ~}'  skip
      '~}' SKIP
      'document.getElementById("timeHourSet").value = timeHourSet ;' skip
      'document.getElementById("timeSecondSet").value = timeSecondSet ;' skip
      'document.getElementById("timeMinuteSet").value = timeMinuteSet ;' skip
      'timerRunning = true;' skip
      'timerID = setTimeout("showtime()",1000);' SKIP /* 1000=1second */
      '~}' skip
      '</script>' SKIP.
      
    {&out} 
    '<script language="JavaScript" src="/scripts/js/tree.js"></script>' skip
        '<script language="JavaScript" src="/scripts/js/prototype.js"></script>' skip
        '<script language="JavaScript" src="/scripts/js/scriptaculous.js"></script>' skip.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-GenHTML) = 0 &THEN

PROCEDURE ip-GenHTML :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    {&out} htmlib-Header(lc-title) skip.
    RUN ip-ExportJScript.

    {&out} htmlib-StartForm("mainform","post", appurl + '/iss/addissue.p' ) htmlib-ProgramTitle(lc-title) skip.
    
    IF NOT ll-Customer THEN
    DO:
        {&out} htmlib-StartInputTable() skip
                    '<tr><td>&nbsp;</td><td  align="right" width="50%">' SKIP
                    '<span id="clockface" class="clockface">' skip
                    '00:00:00' skip
                    '</span><img id="throbber" src="/images/ajax/ajax-loader-red.gif"></td></tr>' skip
                    '<tr><td valign="top"><fieldset><legend>Main Issue Entry</legend>' skip                 .
    END.
    RUN ip-MainEntry.
    IF NOT ll-Customer THEN 
    DO: 
        {&out} '</td><td valign="top" style="padding-left: 5px;">' skip .
        RUN ip-QuickFinish.
        {&out} '</td></tr>'.
        {&out} htmlib-EndTable().
        {&out} '</fieldset>' skip
                    '</td></tr>' skip.
    END.
    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<br><br><center>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</center>' skip.
    END.
    {&out} '<center>' Return-Submit-Button("submitform","Add Issue","PrePost()") 
    '</center>' skip.
    IF NOT ll-Customer AND CAN-FIND(customer WHERE customer.CompanyCode = lc-global-company AND 
        customer.AccountNumber = lc-AccountNumber) THEN
    DO:
        RUN ip-Inventory ( lc-global-company, lc-AccountNumber ).
    END.

    {&out} htmlib-Hidden("submitsource","null") skip
         htmlib-Hidden("emailid",lc-emailid) skip
         htmlib-Hidden("issuesource",lc-issuesource) skip
         htmlib-Hidden("timeSecondSet",lc-timeSecondSet) skip
         htmlib-Hidden("timeMinuteSet",lc-timeMinuteSet) SKIP
         htmlib-Hidden("timeHourSet",lc-timeHourSet) skip
         htmlib-Hidden("defaultTime",lc-DefaultTimeSet) skip
         htmlib-Hidden("contract",lc-contract-type) skip
         htmlib-Hidden("billable",lc-billable-flag) skip
         htmlib-Hidden("savedactivetype",lc-saved-activity) skip   
         htmlib-Hidden("actDesc",lc-list-activdesc) skip     
         htmlib-Hidden("actTime",lc-list-activtime) skip 
         htmlib-Hidden("actID",lc-list-actid) skip 
         htmlib-EndForm() skip.
    IF NOT ll-customer THEN
        {&out}  htmlib-CalendarScript("date") skip
                                    htmlib-CalendarScript("startdate") SKIP
                                    .
    {&out}
    '<script type="text/javascript">' skip
    'startclock();' skip
    '</script>' skip.
    {&out} htmlib-Footer() skip.
  
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-GetAccountNumbers) = 0 &THEN

PROCEDURE ip-GetAccountNumbers :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-user          AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-AccountNumber AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name          AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-user FOR WebUser.
    DEFINE BUFFER b-cust FOR Customer.
 
    DEFINE VARIABLE ll-Steam AS LOG NO-UNDO.
    
    FIND b-user WHERE b-user.LoginID = pc-user NO-LOCK NO-ERROR.
    
    ll-Steam = CAN-FIND(FIRST webUsteam WHERE webusteam.loginid = pc-user NO-LOCK).



    ASSIGN 
        pc-AccountNumber = htmlib-Null()
        pc-Name          = "Select Account".


    FOR EACH b-cust NO-LOCK
        WHERE b-cust.CompanyCode = b-user.CompanyCode
        AND  b-cust.isActive = TRUE   
        BY b-cust.name:

        /*
        *** if user is in teams then customer must be in 1 of the users teams
        *** or they have been assigned to the an issue for the customer
        */
        IF ll-steam
            AND NOT CAN-FIND(FIRST webUsteam 
            WHERE webusteam.loginid = pc-user
            AND webusteam.st-num = b-cust.st-num NO-LOCK) THEN NEXT. 

        ASSIGN 
            pc-AccountNumber = pc-AccountNumber + '|' + b-cust.AccountNumber
            pc-Name          = pc-Name + '|' + trim(substr(b-cust.name,1,30)).

    END.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-GetArea) = 0 &THEN

PROCEDURE ip-GetArea :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    

    DEFINE OUTPUT PARAMETER pc-AreaCode AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Description          AS CHARACTER NO-UNDO.

    
    DEFINE BUFFER b-cust FOR WebIssArea.

   
    ASSIGN 
        pc-AreaCode    = htmlib-Null() + '|'
        pc-Description = "Select Area|Not Applicable/Known".


    FOR EACH b-cust NO-LOCK
        WHERE b-cust.CompanyCode = lc-global-company
        :

        ASSIGN 
            pc-AreaCode    = pc-AreaCode + '|' + b-cust.AreaCode
            pc-Description = pc-Description + '|' + b-cust.Description.

    END.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-GetCatCode) = 0 &THEN

PROCEDURE ip-GetCatCode :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE OUTPUT PARAMETER pc-CatCode AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Description          AS CHARACTER NO-UNDO.

    
    DEFINE BUFFER b-Cat FOR WebIssCat.

   
    ASSIGN 
        pc-CatCode     = ""
        pc-Description = "".

    FOR EACH b-Cat NO-LOCK
        WHERE b-Cat.CompanyCode = lc-global-company
        BY b-Cat.description
        :

        IF pc-CatCode = ""
            THEN ASSIGN  pc-CatCode     = b-Cat.CatCode
                pc-Description = b-Cat.Description.
        ELSE ASSIGN pc-CatCode     = pc-CatCode + '|' + b-Cat.CatCode
                pc-Description = pc-Description + '|' + b-Cat.Description.

    END.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-GetContract) = 0 &THEN

PROCEDURE ip-GetContract :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-Account       AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Type          AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Contract      AS CHARACTER NO-UNDO.

 

    IF pc-Account <> "" THEN
    DO:
        IF CAN-FIND (FIRST WebIssCont                           
            WHERE WebIssCont.CompanyCode     = lc-global-company     
            AND WebIssCont.Customer        = pc-Account            
            AND WebIssCont.ConActive       = TRUE ) 
            THEN
        DO:
            ASSIGN 
                pc-Type     = '0'
                pc-Contract = "SELECT".

            FOR EACH WebIssCont NO-LOCK                             
                WHERE WebIssCont.CompanyCode     = lc-global-company     
                AND WebIssCont.Customer        = pc-Account            
                AND WebIssCont.ConActive       = TRUE
                :                 
                                                                  
                                      
                /*            if WebIssCont.DefCon then assign lc-contract-type = WebIssCont.ContractCode. */
                /*                                                                                         */
                /*            assign pc-Type          = htmlib-Null() + '|0'     */
                /*                   pc-Contract      = "Select Contract|AdHoc". */
   
    
                ASSIGN 
                    pc-Type     = pc-Type      + '|' + string(WebIssCont.ContractCode)
                    pc-Contract = pc-Contract  + '|' + WebIssCont.Notes.
    
            END.
        END.
        ELSE
        DO:
            ASSIGN 
                pc-Type     = '0'
                pc-Contract = "SELECT".
        END.
    END.                                                        
    ELSE
    DO:
        ASSIGN 
            pc-Type     = '0'
            pc-Contract = "SELECT".
    END.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-GetOwner) = 0 &THEN

PROCEDURE ip-GetOwner :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-Account       AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Login         AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name          AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-user FOR WebUser.
    DEFINE BUFFER cu     FOR Customer.
     

    IF pc-Account <> "" THEN
    DO: 
        FIND cu WHERE cu.CompanyCode   = lc-global-company      
            AND cu.AccountNumber = pc-Account           
           NO-LOCK NO-ERROR.
                                                                      
        FIND FIRST b-user NO-LOCK                                  
            WHERE b-user.CompanyCode   = lc-global-company      
            AND b-user.AccountNumber = pc-Account             
            AND b-user.Disabled      = FALSE                  
            AND b-user.LoginID = cu.def-iss-loginid                
            NO-ERROR.                  
           
        IF ll-Customer THEN
        DO:                                                        
            IF AVAILABLE b-user THEN                                       
            ASSIGN pc-login = b-user.loginid                   
                   pc-Name  = b-user.name     .  
            ELSE
            ASSIGN pc-login = htmlib-Null() 
                pc-Name  = "Select Person".
        END.
        ELSE
        DO:                                                        
        IF AVAILABLE b-user THEN                                       
            ASSIGN pc-login = b-user.loginid  + '|'                 
                pc-Name  = b-user.name     + '|Add New'.  
        ELSE
            ASSIGN pc-login = htmlib-Null() + '|'
                pc-Name  = "Select Person|Add New".
        END.
         
        FOR EACH b-user NO-LOCK
            WHERE b-user.CompanyCode   = lc-global-company
            AND b-user.AccountNumber = pc-Account
            AND b-user.Disabled      = FALSE               
            AND b-user.loginid <> cu.def-iss-loginid        
            BY b-user.name:
  
            ASSIGN 
                pc-login = pc-login  + '|' + b-user.loginid
                pc-Name  = pc-Name + '|' + b-user.name.
  
        END.
    END.                                                        /* 3667 */  
    ELSE
    DO:
        ASSIGN 
            pc-login = htmlib-Null() + '|'
            pc-Name  = "Select Person|Not Applicable".
    END.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-HeaderInclude-Calendar) = 0 &THEN

PROCEDURE ip-HeaderInclude-Calendar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Inventory) = 0 &THEN

PROCEDURE ip-Inventory :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-companycode      AS CHARACTER     NO-UNDO.
    DEFINE INPUT PARAMETER pc-AccountNumber    AS CHARACTER     NO-UNDO.
    
    DEFINE BUFFER Customer FOR Customer.
    DEFINE BUFFER ivClass  FOR ivClass.
    DEFINE BUFFER ivSub    FOR ivSub.
    DEFINE BUFFER b-query  FOR CustIv.
    DEFINE BUFFER b-search FOR CustIv.

    DEFINE VARIABLE lc-object        AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-subobject     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-ajaxSubWindow AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-expand        AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE lc-update-id     AS CHARACTER NO-UNDO.


    lc-expand = "yes".

    FIND customer 
        WHERE customer.CompanyCode = pc-CompanyCode
        AND customer.AccountNumber = pc-AccountNumber
        NO-LOCK.

    ASSIGN 
        lc-enc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"customer",STRING(ROWID(customer))).
                            
    
    {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="95%" align="center"').

    {&out}
    htmlib-TableHeading(
        "Select Inventory|"
        ) skip.

    
    {&out}
    '<tr class="tabrow1">'
    '<td valign="top" nowrap class="tree">' skip
    .
    FOR EACH b-query NO-LOCK OF Customer
        WHERE b-query.isDecom = FALSE,
        FIRST ivSub NO-LOCK OF b-query,
        FIRST ivClass NO-LOCK OF ivSub
        BREAK 
        BY ivClass.DisplayPriority DESCENDING
        BY ivClass.name
        BY ivSub.DisplayPriority DESCENDING
        BY ivSub.name
        BY b-query.Ref:

        
        

        ASSIGN 
            lc-object    = "CLASS" + string(ROWID(ivClass))
            lc-subobject = "SUB" + string(ROWID(ivSub)).
        IF FIRST-OF(ivClass.name) THEN
        DO:
            IF lc-expand = "yes" 
                THEN {&out} '<img src="/images/general/menuopen.gif" onClick="hdexpandcontent(this, ~''
            lc-object '~')">'
            '&nbsp;' '<span style="' ivClass.Style '">' html-encode(ivClass.name) '</span><br>'
            '<div id="' lc-object '" style="padding-left: 15px; display: block;">' skip.
            else {&out}
                '<img src="/images/general/menuclosed.gif" onClick="hdexpandcontent(this, ~''
                        lc-object '~')">'
                '&nbsp;' '<span style="' ivClass.Style '">' html-encode(ivClass.name) '</span><br>'
                '<div id="' lc-object '" style="padding-left: 15px; display: none;">' skip.
        END.

        IF FIRST-OF(ivSub.name) THEN
        DO:
            
            IF lc-expand = "yes"
                THEN {&out} 
            '<img src="/images/general/menuopen.gif" onClick="hdexpandcontent(this, ~''
            lc-subobject '~')">'
            '&nbsp;'
            '<span style="' ivSub.Style '">'
            html-encode(ivSub.name) '</span><br>' skip
                '<div id="' lc-subobject '" style="padding-left: 15px; display: block;">' skip.
                
            else {&out} 
                '<img src="/images/general/menuclosed.gif" onClick="hdexpandcontent(this, ~''
                        lc-subobject '~')">'
                '&nbsp;'
                '<span style="' ivSub.Style '">'
                html-encode(ivSub.name) '</span><br>' skip
                '<div id="' lc-subobject '" style="padding-left: 15px; display: none;">' skip.
        END.
       
         
        ASSIGN 
            lc-inv-key = DYNAMIC-FUNCTION("sysec-EncodeValue","Inventory",TODAY,"Inventory",STRING(ROWID(b-query))).
        
        {&out} '<a href="'
        "javascript:ahah('" 
                    
        appurl "/cust/custequiptable.p?rowid=" url-encode(lc-inv-key,"Query") "&customer=" url-encode(lc-enc-key,"Query") "&sec=" url-encode(lc-global-secure,"Query")
        "','inventory');".

        
        {&out}
        '">' html-encode(b-query.ref) '</a><br>' skip.

        
        
        IF LAST-OF(ivSub.name) THEN
        DO:
            {&out} '</div>' skip.
            
             
        END.


        IF LAST-OF(ivClass.name) THEN
        DO:
            {&out} '</div>' skip.
            
        END.

        
            
    END.

    {&out} '</td>' skip.
                
    {&out} '<td valign="top" rowspan="100" ><div id="inventory">&nbsp;</div></td>'.
    {&out} '</tr>' skip.


    {&out} skip 
           htmlib-EndTable()
           skip.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-MainEntry) = 0 &THEN

PROCEDURE ip-MainEntry :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    {&out} htmlib-StartInputTable() skip.
    
    DEFINE BUFFER bcust FOR customer.

    IF NOT ll-customer THEN
    DO:
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("accountnumber",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Account")
            ELSE htmlib-SideLabel("Account"))
        '</TD>' 
        '<TD VALIGN="TOP" ALIGN="left">'
        format-Select-Account(htmlib-Select("accountnumber",lc-list-number,lc-list-name,
            lc-accountnumber) )
        '</TD></TR>' skip. 
    END.
    ELSE
    DO:
        {&out} '<tr><td valign="top" align="right">'
        htmlib-SideLabel("Account")
        '</td>'
        htmlib-TableField(
            REPLACE(html-encode(lc-accountnumber + " " + customer.name + '~n' + lc-address),
            "~n","<br>")
                        
            ,'left')
                    

        '</tr>' skip.
        FIND company WHERE company.companycode = lc-global-company
            NO-LOCK NO-ERROR.
        IF company.issueinfo <> "" THEN
        DO:
            {&out} '<tr><td colspan="2">'
            '<div class="infobox">'
            REPLACE(html-encode(company.issueinfo),'~n','<br>')
            '</div>'
            '</td></tr>' skip.

        END.

    END.
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("raisedlogin",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Raised By")
        ELSE htmlib-SideLabel("Raised By"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("raisedlogin",lc-list-login,lc-list-lname,lc-raisedlogin)
    '</TD></TR>' skip. 


    IF NOT ll-customer THEN
    DO:
        {&out} '<TR><TD VALIGN="TOP" ALIGN="left" colspan=2>'  SKIP.
        
        RUN ip-NewUserHTML.
    
        {&out} '</td></tr>' SKIP. /* end of new user */
    END.

    IF NOT ll-customer  AND CAN-FIND(customer WHERE customer.companycode = lc-global-company
        AND customer.AccountNumber = lc-AccountNumber) THEN
    DO:

        FIND bcust WHERE bcust.companycode = lc-global-company
            AND bcust.AccountNumber = lc-AccountNumber NO-LOCK NO-ERROR.

        IF AVAILABLE bcust AND bcust.SupportTicket <> "none" THEN
            {&out} '<TR><TD VALIGN="TOP" ALIGN="center" colspan=2>'
        '<div class="infobox" style="font-size: 15px;">'
        "Ticketed Customer Balance: "
             DYNAMIC-FUNCTION("com-TimeToString",com-GetTicketBalance(lc-global-company,lc-accountnumber))
        '</TD></TR>' skip. 




    END.


    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("areacode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Area")
        ELSE htmlib-SideLabel("Area"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left">'
    SKIP(4).

    RUN ip-AreaSelect.

    {&out}
    '</TD></TR>' skip. 

    IF NOT ll-customer THEN
    DO:

        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("date",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Date")
            ELSE htmlib-SideLabel("Date"))
        '</TD>'
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-InputField("date",10,lc-date) 
        htmlib-CalendarLink("date")
        '</TD>' skip.
        {&out} '</TR>' skip.


    
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("contract",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Contract")
            ELSE htmlib-SideLabel("Contract"))
        '</TD>' 
        '<TD VALIGN="TOP" ALIGN="left">'.


        RUN ip-ContractSelect.

        {&out} '</TD></tr> ' skip.  

        {&out} '<tr><td valign="top" align="right">' 
        htmlib-SideLabel("Billable?")
        '</td><td valign="top" align="left">'
        REPLACE(htmlib-CheckBox("billcheck", IF ll-billing THEN TRUE ELSE FALSE),
            '>',' onClick="ChangeBilling(this);">')
        '</td></tr>' skip.
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("iclass",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Class")
            ELSE htmlib-SideLabel("Class"))
        '</TD>' 
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-Select("iclass",lc-global-iclass-Add-code,lc-global-iclass-Add-desc,lc-iclass)
        '</TD></TR>' skip. 

    END.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("briefdescription",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Brief Description")
        ELSE htmlib-SideLabel("Brief Description"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("briefdescription",50,lc-briefdescription) 
    '</TD>' skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("longdescription",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Details")
        ELSE htmlib-SideLabel("Details"))
    '</TD>' skip
            '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-TextArea("longdescription",lc-longdescription,10,40)
           '</TD>' skip
            skip.
    
    IF lc-sla-rows <> "" AND lc-accountnumber <> "" AND NOT ll-customer THEN
    DO:
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("sla",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("SLA")
            ELSE htmlib-SideLabel("SLA"))
        '</TD>'
        '<TD VALIGN="TOP" ALIGN="left">' skip.
        RUN ip-SLATable.
        {&out}
        '</TD>' skip.
        {&out} '</TR>' skip.

    END. 

   
    IF CAN-FIND(customer WHERE customer.companycode = lc-global-company
        AND customer.AccountNumber = lc-AccountNumber)
        AND com-AskTicket(lc-global-company,lc-AccountNumber) THEN
    DO:
        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("ticket",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Ticketed Issue?")
            ELSE htmlib-SideLabel("Ticketed Issue?"))
        '</TD>'
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-CheckBox("ticket", IF lc-ticket = 'on'
            THEN TRUE ELSE FALSE) 
        '</TD></TR>' skip.
    END.

    IF NOT ll-customer THEN
    DO:
        IF lc-list-catcode <> "" THEN
            {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("catcode",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Category")
            ELSE htmlib-SideLabel("Category"))
        '</TD>' 
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-Select("catcode",lc-list-catcode,lc-list-cname,
            lc-catcode)
        '</TD></TR>' skip. 

        {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
            (IF LOOKUP("gotomaint",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Update Issue Now?")
            ELSE htmlib-SideLabel("Update Issue Now?"))
        '</TD>'
        '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-CheckBox("gotomaint", IF lc-gotomaint = 'on'
            THEN TRUE ELSE FALSE) 
        '</TD></TR>' skip.
    END.

    

    {&out} htmlib-EndTable() skip.



END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-NewUserHTML) = 0 &THEN

PROCEDURE ip-NewUserHTML :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    {&out} htmlib-BeginCriteria("Or Create New User").

    {&out}
    htmlib-StartMntTable().
    
    {&out} '</td></tr>' SKIP.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("uadd-loginid",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("User ID")
        ELSE htmlib-SideLabel("User ID"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("uadd-loginid",20,lc-uadd-loginid) 
    '</TD></TR>' skip. 
        
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("uadd-name",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Name")
        ELSE htmlib-SideLabel("Name"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("uadd-name",40,lc-uadd-name) 
    '</TD></TR>' skip. 
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("uadd-email",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Email")
        ELSE htmlib-SideLabel("Email"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("uadd-email",40,lc-uadd-email) 
    '</TD></TR>' skip. 
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("uadd-phone",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Telephone")
        ELSE htmlib-SideLabel("Telephone"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("uadd-phone",40,lc-uadd-phone) 
    '</TD></TR>' skip. 
    
    {&out} skip 
        htmlib-EndTable()
         htmlib-EndCriteria() skip.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-QuickFinish) = 0 &THEN

PROCEDURE ip-QuickFinish :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
 
 
 
    {&out} 
    '<fieldset><legend>Quick Issue Resolution</legend>'.
            

    {&out} htmlib-CustomerViewable(lc-global-company,lc-AccountNumber).

    {&out} htmlib-StartInputTable() skip.

    {&out} '<tr><td valign="top" align="right">' 
    htmlib-SideLabel("Issue Resolved?")
    '</td><td valign="top" align="left">'
    REPLACE(htmlib-CheckBox("quick", IF lc-quick = 'on'
        THEN TRUE ELSE FALSE),
        '>',' onClick="Quick(this);">')
    '</td></tr>' skip.

    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("currentstatus",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Issue Status")
        ELSE htmlib-SideLabel("Issue Status"))
    '</td>' 
    '<td valign="top" align="left">'
    htmlib-Select("currentstatus",lc-list-status,lc-list-sname,lc-currentstatus)
    '</td></tr>' skip. 

    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("currentassign",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Issue/Action Assigned To")
        ELSE htmlib-SideLabel("Issue/Action Assigned To"))
    '</td>' 
    '<td valign="top" align="left">'
    htmlib-Select("currentassign",lc-list-assign,lc-list-assname,
        lc-currentassign)
    '</td></tr>' skip. 

    {&out} '<tr><td valign="top" align="right">' 
        ( IF LOOKUP("actioncode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Action Type")
        ELSE htmlib-SideLabel("Action Type"))
    '</td>' skip
           '<td valign="top" align="left">'
           htmlib-Select("actioncode",lc-list-actcode,lc-list-actdesc,
                lc-actioncode)
           '</td></tr>' skip.

    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("actionnote",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Note")
        ELSE htmlib-SideLabel("Note"))
    '</td>' skip
           '<td valign="top" align="left">'
           '<input type="button" class="submitbutton" onclick="copyinfo();" value="Copy Issue Details"><br>'
           htmlib-TextArea("actionnote",lc-actionnote,6,40)
          '</td></tr>' skip
           skip.

    {&out} '<tr><td valign="top" align="right">' 
    htmlib-SideLabel("Customer View?")
    '</td><td valign="top" align="left">'
    htmlib-CheckBox("customerview", IF lc-customerview = 'on'
        THEN TRUE ELSE FALSE) 
    '</td></tr>' skip.

    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("actionstatus",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Action Status")
        ELSE htmlib-SideLabel("Action Status"))
    '</td><td valign="top" align="left">'
    htmlib-Select("actionstatus",lc-global-action-code,lc-global-action-display,lc-actionstatus)
    '</td></tr>' 
            
        skip.

    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("activitytype",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Activity Type")
        ELSE htmlib-SideLabel("Activity Type"))
    '</td>' 
    '<td valign="top" align="left">'
    Format-Select-Activity(htmlib-Select("activitytype",lc-list-actid,lc-list-activtype,lc-saved-activity)) skip
             '</td></tr>' skip. 


    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("startdate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Start Date")
        ELSE htmlib-SideLabel("Start Date"))
    '</td>'.
    
    
    {&out} '<td valign="top" align="left">'
    htmlib-InputField("startdate",10,lc-startdate) 
    htmlib-CalendarLink("startdate")
    "&nbsp;@&nbsp;"
    htmlib-TimeSelect("starthour",lc-starthour,"startmin",lc-startmin)
    '</td>' skip.
    
           
    {&out} '</tr>' skip.

    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("enddate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("End Date")
        ELSE htmlib-SideLabel("End Date"))
    '</td>'.
    
    {&out} '<td valign="top" align="left">'
    REPLACE(htmlib-InputField("enddate",10,lc-enddate),">"," disabled>") 
    REPLACE(htmlib-CalendarLink("enddate"),">"," disabled>") 
    "&nbsp;@&nbsp;"
    REPLACE(htmlib-TimeSelect-By-Id("endhour",lc-endhour,"endmin",lc-endmin),">"," disabled>") 
    '</td>' skip.
    
    {&out} '</tr>' skip.



    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("hours",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Duration (HH:MM)")
        ELSE htmlib-SideLabel("Duration (HH:MM)"))
    '</td>'.
    
    {&out} '<td valign="top" align="left">'
    Format-Select-Duration(htmlib-InputField("hours",4,lc-hours))
    ':'
    Format-Select-Duration(htmlib-InputField("mins",2,lc-mins))
    '</td>' skip.
    
    {&out} '</tr>' skip.

    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("manualTime",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Manual Time Entry?")
        ELSE htmlib-SideLabel("Manual Time Entry?"))
    '</td>'.


    {&out} '<td valign="top" align="left">'
    '<input class="inputfield" type="checkbox" onclick="javascript:manualTimeSet()" id="manualTime" name="manualTime" ' lc-manChecked ' >' 
    '</td></tr>' skip.




    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("actdescription",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Activity Description")
        ELSE htmlib-SideLabel("Activity Description"))
    '</td><td valign="top" align="left">'
    /*             htmlib-InputField("actdescription",40,lc-actdescription) */
    Format-Select-Desc(htmlib-ThisInputField("actdescription",40,lc-actdescription) )
    '</td></tr>' skip.




    

    {&out} htmlib-EndTable() skip.

    {&out}
                
    '</fieldset>'
    '</td></tr>' skip.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-QuickUpdate) = 0 &THEN

PROCEDURE ip-QuickUpdate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE VARIABLE lr-Action AS ROWID   NO-UNDO.
    DEFINE VARIABLE lr-Issue  AS ROWID   NO-UNDO.
    DEFINE VARIABLE li-amount AS INTEGER NO-UNDO.

    IF lc-actionCode <> lc-global-selcode THEN
    DO:
        FIND WebAction
            WHERE WebAction.CompanyCode = lc-global-company
            AND WebAction.ActionCode  = lc-ActionCode
            NO-LOCK NO-ERROR.
        CREATE IssAction.
        ASSIGN 
            IssAction.actionID     = WebAction.ActionID
            IssAction.CompanyCode  = lc-global-company
            IssAction.IssueNumber  = issue.IssueNumber
            IssAction.CreateDate   = TODAY
            IssAction.CreateTime   = TIME
            IssAction.CreatedBy    = lc-global-user
            IssAction.customerview = lc-customerview = "on"
            .
    
        DO WHILE TRUE:
            RUN lib/makeaudit.p (
                "",
                OUTPUT lf-audit
                ).
            IF CAN-FIND(FIRST IssAction
                WHERE IssAction.IssActionID = lf-audit NO-LOCK)
                THEN NEXT.
            ASSIGN
                IssAction.IssActionID = lf-audit.
            LEAVE.
        END.
        ASSIGN 
            IssAction.notes        = lc-actionnote
            IssAction.ActionStatus = lc-ActionStatus
            IssAction.ActionDate   = TODAY
            IssAction.customerview = lc-customerview = "on"
            IssAction.AssignTo     = lc-currentassign
            IssAction.AssignDate   = TODAY
            IssAction.AssignTime   = TIME.
    
        ASSIGN
            lr-Action = ROWID(issAction).
        RELEASE issAction.
        
        FIND issAction WHERE ROWID(issAction) = lr-Action EXCLUSIVE-LOCK.
    
        DYNAMIC-FUNCTION("islib-CreateAutoAction",issAction.IssActionID).
    
        IF lc-ActDescription <> "" THEN
        DO:
    
            
            CREATE IssActivity.
            ASSIGN 
                IssActivity.IssActionID = IssAction.IssActionID
                IssActivity.CompanyCode = lc-global-company
                IssActivity.IssueNumber = issue.IssueNumber
                IssActivity.CreateDate  = TODAY
                IssActivity.CreateTime  = TIME
                IssActivity.CreatedBy   = lc-global-user
                IssActivity.ActivityBy  = lc-CurrentAssign .
        
            DO WHILE TRUE:
                RUN lib/makeaudit.p (
                    "",
                    OUTPUT lf-audit
                    ).
                IF CAN-FIND(FIRST IssActivity
                    WHERE IssActivity.IssActivityID = lf-audit NO-LOCK)
                    THEN NEXT.
                ASSIGN
                    IssActivity.IssActivityID = lf-audit.
                LEAVE.
            END.
            ASSIGN 
                IssActivity.Description    = lc-briefdescription
                IssActivity.ActDate        = TODAY
                IssActivity.Customerview   = lc-customerview = "on"
                issActivity.ActDescription = lc-actdescription
                issActivity.Billable       = lc-billable-flag = "on"
                issActivity.ContractType   = lc-contract-type
                issActivity.CustomerView   = lc-customerview = "on"
                issActivity.Notes          = lc-actionnote
                issActivity.typeID         = int(lc-activityType).
           ASSIGN
                 issActivity.activityType = com-GetActivityByType(lc-global-company,issActivity.TypeID).
                 
                        
            IF lc-startdate <> "" THEN
            DO:
                ASSIGN 
                    IssActivity.StartDate = DATE(lc-StartDate).
        
                ASSIGN 
                    IssActivity.StartTime = DYNAMIC-FUNCTION("com-InternalTime",
                                 int(lc-starthour),
                                 int(lc-startmin)
                                 ).
            END.
            ELSE ASSIGN IssActivity.StartDate = ?
                    IssActivity.StartTime = 0.
            
            
            
            ASSIGN 
                IssActivity.Duration = ( ( int(lc-hours) * 60 ) * 60 ) + 
                ( int(lc-mins) * 60 ).
        
            RUN com-EndTimeCalc
                        (
                        IssActivity.StartDate,
                        IssActivity.StartTime,
                        IssActivity.Duration,
                        OUTPUT IssActivity.EndDate,
                        OUTPUT IssActivity.EndTime
                        ).
                        
            IF Issue.Ticket THEN
            DO:
                ASSIGN
                    li-amount = IssActivity.Duration.
                IF li-amount <> 0 THEN
                DO:
                    EMPTY TEMP-TABLE tt-ticket.
                    CREATE tt-ticket.
                    ASSIGN
                        tt-ticket.CompanyCode   = issue.CompanyCode
                        tt-ticket.AccountNumber = issue.AccountNumber
                        tt-ticket.Amount        = li-Amount * -1
                        tt-ticket.CreateBy      = lc-global-user
                        tt-ticket.CreateDate    = TODAY
                        tt-ticket.CreateTime    = TIME
                        tt-ticket.IssueNumber   = Issue.IssueNumber
                        tt-ticket.Reference     = IssActivity.description
                        tt-ticket.TickID        = ?
                        tt-ticket.TxnDate       = IssActivity.ActDate
                        tt-ticket.TxnTime       = TIME
                        tt-ticket.TxnType       = "ACT"
                        tt-ticket.IssActivityID = IssActivity.IssActivityID.
                    RUN tlib-PostTicket.
        
        
                END.
        
            END.
    
        END.

    END.

    /*
    *** 
    *** final update of the issue
    ***
    */
    ASSIGN
        Issue.AssignTo   = lc-CurrentAssign
        Issue.AssignDate = TODAY
        Issue.AssignTime = TIME
        lr-Issue         = ROWID(Issue).

    IF Issue.StatusCode <> lc-currentstatus THEN
    DO:
        RELEASE issue.
        FIND Issue WHERE ROWID(Issue) = lr-Issue EXCLUSIVE-LOCK.
        RUN islib-StatusHistory(
            Issue.CompanyCode,
            Issue.IssueNumber,
            lc-global-user,
            Issue.StatusCode,
            lc-currentStatus ).
        RELEASE issue.
        FIND Issue WHERE ROWID(Issue) = lr-Issue EXCLUSIVE-LOCK.
        ASSIGN
            Issue.StatusCode = lc-CurrentStatus.
        
    END.

    IF DYNAMIC-FUNCTION("islib-StatusIsClosed",
        Issue.CompanyCode,
        Issue.StatusCode)
        THEN DYNAMIC-FUNCTION("islib-RemoveAlerts",ROWID(Issue)).


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-SetUpQuick) = 0 &THEN

PROCEDURE ip-SetUpQuick :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-end AS INTEGER NO-UNDO.

    ASSIGN 
        lc-StartDate      = STRING(TODAY,"99/99/9999")
        lc-EndDate        = STRING(TODAY,"99/99/9999")
        lc-hours          = "00"
        lc-mins           = "0"
        lc-secs           = "1"
        lc-starthour      = STRING(int(substr(STRING(TIME,"hh:mm"),1,2)))
        lc-endhour        = lc-starthour
        lc-startmin       = STRING(int(substr(STRING(TIME,"hh:mm"),4,2)))
        lc-endmin         = lc-startmin
        lc-currentassign  = lc-global-user
        lc-timeSecondSet  = IF lc-timeSecondSet <> "" THEN lc-timeSecondSet ELSE lc-secs 
        lc-timeMinuteSet  = IF lc-timeMinuteSet <> "" THEN lc-timeMinuteSet ELSE lc-mins
        lc-timeHourSet    = IF lc-timeHourSet <> "" THEN lc-timeHourSet ELSE "0"
        lc-DefaultTimeSet = ENTRY(1,lc-list-activtime,"|")
        lc-saved-activity = "0"
      
        .


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-SLATable) = 0 &THEN

PROCEDURE ip-SLATable :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE BUFFER slahead FOR slahead.
    DEFINE VARIABLE li-loop   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-object AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-rowid  AS CHARACTER NO-UNDO.

    {&out} htmlib-Hidden("djs",lc-sla-selected) skip.

    {&out}
    htmlib-StartMntTable()
    htmlib-TableHeading(
        "Select?^left|SLA"
        ) skip.

    IF lc-global-company = "MICAR" THEN
    DO:
        {&out}
        htmlib-trmouse()
        '<td>'
        htmlib-Radio("sla", "slanone" , IF lc-sla-selected = "slanone" THEN TRUE ELSE FALSE)
        '</td>'
        htmlib-TableField(html-encode("None"),'left')
    
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
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.


    DEFINE VARIABLE ld-date   AS DATE    NO-UNDO.
    DEFINE VARIABLE ld-startd AS DATE    NO-UNDO.
    DEFINE VARIABLE ld-endd   AS DATE    NO-UNDO.
    DEFINE VARIABLE li-startt AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-endt   AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-int    AS INTEGER NO-UNDO.
    DEFINE BUFFER b FOR webuser.
    

    IF NOT CAN-FIND(customer WHERE customer.accountnumber 
        = lc-accountnumber 
        AND customer.companycode = lc-global-company
        NO-LOCK) 
        THEN RUN htmlib-AddErrorMessage(
            'accountnumber', 
            'You must select the account',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    IF pc-error-field = "" 
        AND ( lc-raisedlogin = htmlib-Null() OR lc-raisedLogin = "" ) THEN 
    DO:
        
        IF lc-uadd-loginId = "" THEN
            RUN htmlib-AddErrorMessage(
                'raisedlogin', 
                'Select the person who raised the issue or create one',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        /* Oherwise adding a new user! */
        ELSE
        DO:
            IF CAN-FIND(b WHERE b.loginid = lc-uadd-loginid NO-LOCK) 
                THEN RUN htmlib-AddErrorMessage(
                    'uadd-loginid', 
                    'This user already exists',
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).
            ELSE
            DO:
                IF lc-uadd-name = "" THEN
                    RUN htmlib-AddErrorMessage(
                        'uadd-name', 
                        'You must enter the users name',
                        INPUT-OUTPUT pc-error-field,
                        INPUT-OUTPUT pc-error-msg ).
                IF lc-uadd-email = "" THEN
                    RUN htmlib-AddErrorMessage(
                        'uadd-email', 
                        'You must enter the users email',
                        INPUT-OUTPUT pc-error-field,
                        INPUT-OUTPUT pc-error-msg ).
                IF lc-uadd-phone = "" THEN
                    RUN htmlib-AddErrorMessage(
                        'uadd-phone', 
                        'You must enter the users phone number',
                        INPUT-OUTPUT pc-error-field,
                        INPUT-OUTPUT pc-error-msg ).



            END.
        END.
    END.

    IF lc-areacode = htmlib-Null() 
        THEN RUN htmlib-AddErrorMessage(
            'areacode', 
            'Select the issue area',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).





    ASSIGN 
        ld-date = DATE(lc-date) no-error.
    IF ERROR-STATUS:ERROR
        OR ld-date = ? 
        THEN RUN htmlib-AddErrorMessage(
            'date', 
            'You must enter the date',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    
    IF NOT ll-customer
    AND ( lc-contract-type = "" OR lc-contract-Type BEGINS "SELECT" ) 
    THEN RUN htmlib-AddErrorMessage(
            'contract', 
            'You must select contract',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    
    IF lc-briefdescription = ""
        THEN RUN htmlib-AddErrorMessage(
            'briefdescription', 
            'You must enter a brief description for the issue',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF lc-longdescription = ""
        THEN RUN htmlib-AddErrorMessage(
            'longdescription', 
            'You must enter the details for the issue',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF NOT ll-Customer THEN
    DO:
        IF lc-actionCode = lc-global-selcode THEN 
        DO:
            IF lc-quick = "on" THEN
            DO:
                RUN htmlib-AddErrorMessage(
                    'actioncode', 
                    'You have not selected an action type but have closed the issue',
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).

            END.
            IF lc-actionnote <> "" THEN
            DO:
                RUN htmlib-AddErrorMessage(
                    'actioncode', 
                    'You have not selected an action type but have entered a note',
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).

            END.
        END.
        ELSE
        DO:
            IF lc-actionnote = "" THEN
                RUN htmlib-AddErrorMessage(
                    'actionnote', 
                    'You must enter the action note',
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).
            IF lc-startdate <> "" THEN
            DO:
                ASSIGN 
                    ld-startd = DATE(lc-startdate) no-error.
                IF ERROR-STATUS:ERROR
                    OR ld-startd = ? THEN
                DO:
                    RUN htmlib-AddErrorMessage(
                        'startdate', 
                        'The start date is invalid',
                        INPUT-OUTPUT pc-error-field,
                        INPUT-OUTPUT pc-error-msg ).
        
                END.
            END.
            ELSE ASSIGN ld-startd = ?.
        
            
            ASSIGN 
                li-int = int(lc-hours) no-error.
            IF ERROR-STATUS:ERROR OR li-int < 0
                THEN RUN htmlib-AddErrorMessage(
                    'hours', 
                    'The hours are invalid',
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).
        
            ASSIGN 
                li-int = int(lc-mins) no-error.
            IF ERROR-STATUS:ERROR OR li-int < 0 OR li-int > 59
                THEN RUN htmlib-AddErrorMessage(
                    'hours', 
                    'The minutes are invalid',
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).
        
            
            ASSIGN 
                li-int = int(lc-hours + lc-mins) no-error.
            IF NOT ERROR-STATUS:ERROR
                AND li-int = 0 
                THEN RUN htmlib-AddErrorMessage(
                    'hours', 
                    'You must enter the duration',
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).


            IF lc-actdescription = "" 
                THEN RUN htmlib-AddErrorMessage(
                    'actdescription', 
                    'You must enter the activity description',
                    INPUT-OUTPUT pc-error-field,
                    INPUT-OUTPUT pc-error-msg ).

            

        END.
    END.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ipCreateNewUser) = 0 &THEN

PROCEDURE ipCreateNewUser :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE BUFFER b FOR webuser.
    DEFINE BUFFER c FOR webuser.

    FIND FIRST c 
        WHERE c.companyCode = issue.companyCode
        AND  c.accountnumber = issue.accountnumber
        AND c.defaultuser NO-LOCK NO-ERROR.
    IF NOT AVAILABLE c THEN
        FIND FIRST c 
            WHERE c.companyCode = issue.companyCode
            AND  c.accountnumber = issue.accountnumber
            AND c.DISABLED = NO
            NO-LOCK NO-ERROR.

    CREATE b.
    IF AVAILABLE c
        THEN BUFFER-COPY c EXCEPT c.loginid TO b.
    ASSIGN
        b.loginid            = lc-uadd-loginid
        b.NAME               = lc-uadd-name
        b.companycode        = issue.companyCode
        b.accountnumber      = issue.accountnumber
        b.email              = lc-uadd-email
        b.expiredate         = TODAY - 2000
        b.passwd             = ENCODE(LC(b.loginid))
        b.telephone          = lc-uadd-phone
        b.mobile             = ""
        b.userclass          = "CUSTOMER"
        b.defaultuser        = NO
        b.forename           = ""
        b.surname            = ""
        b.lastDate           = ?
        b.LastPasswordChange = b.expireDate
        b.lastTime           = 0
        b.userTitle          = ""
        .
    IF NUM-ENTRIES(b.NAME," ") > 1 THEN
    DO:
        ASSIGN
            b.forename = ENTRY(1,b.NAME," ")
            b.surname  = ENTRY(2,b.NAME," ").

    END.



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
    DEFINE BUFFER b FOR webUser.
    DEFINE VARIABLE ll-ok AS LOG NO-UNDO.

    {lib/checkloggedin.i}

    ASSIGN  
        lc-title           = 'Add Issue'
        lc-default-catcode = DYNAMIC-FUNCTION("com-GetDefaultCategory",lc-global-company)
        lc-emailid         = get-value("emailid")
        lc-issuesource     = get-value("issuesource")
        lc-iclass          = ENTRY(1,lc-global-iclass-code,"|").
    FIND webuser WHERE webuser.LoginID = lc-global-user NO-LOCK NO-ERROR.

    RUN com-GetAction ( lc-global-company , OUTPUT lc-list-actcode, OUTPUT lc-list-actdesc ).
    RUN com-GetStatusIssue ( lc-global-company , OUTPUT lc-list-status, OUTPUT lc-list-sname ).
    RUN com-GetActivityType ( lc-global-company , OUTPUT lc-list-actid, OUTPUT lc-list-activtype, OUTPUT lc-list-activdesc, OUTPUT lc-list-activtime ).
    RUN com-GetAssignList ( lc-global-company , OUTPUT lc-list-assign , OUTPUT lc-list-assname ).
    ASSIGN  
        lc-list-actcode   = lc-global-selcode + "|" + lc-list-actcode
        lc-list-actdesc   = lc-global-seldesc + "|" + lc-list-actdesc
        lc-actdescription = ENTRY(1,lc-list-activdesc,"|").

    IF lc-IssueSource = "custenq" THEN
    DO:
        ASSIGN
            lc-AccountNumber = get-value("accountnumber") .
        lc-sla-selected = "slanone". 
    END.
    IF WebUser.UserClass = "CUSTOMER" THEN
    DO:
        ASSIGN
            lc-emailid     = ""
            lc-issuesource = "".
        FIND Customer WHERE Customer.CompanyCode   = lc-global-company
            AND Customer.AccountNumber = WebUser.AccountNumber
            NO-LOCK NO-ERROR.
        ASSIGN 
            lc-AccountNumber = WebUser.AccountNumber
            lc-raisedlogin   = WebUser.LoginID
            ll-customer      = TRUE.
        IF request_method = "get" THEN
        DO:
            set-user-field("raisedlogin",lc-raisedLogin).
        END.
        ELSE 
        DO:
            ASSIGN 
                lc-raisedlogin = get-value("raisedlogin").
        END.
        set-user-field("accountnumber",lc-accountNumber).
        set-user-field("raisedlogin",lc-raisedLogin).
        ASSIGN
            lc-address = "".
        lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,customer.Address1).
        lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,customer.Address2).
        lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,customer.City).
        lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,customer.County).
        lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,customer.Country).
        lc-address = DYNAMIC-FUNCTION("com-StringReturn",lc-address,customer.PostCode).
    END.
    IF request_method = 'post' THEN
    DO:
        ASSIGN 
            lc-accountnumber    = get-value("accountnumber")
            lc-briefdescription = get-value("briefdescription")
            lc-longdescription  = get-value("longdescription")
            lc-submitsource     = get-value("submitsource")
            lc-raisedlogin      = get-value("raisedlogin")
            lc-date             = get-value("date")
            lc-AreaCode         = get-value("areacode")
            lc-gotomaint        = get-value("gotomaint")
            lc-sla-selected     = get-value("sla")
            lc-catcode          = get-value("catcode")
            lc-ticket           = get-value("ticket")
            lc-iclass           = get-value("iclass")
            lc-uadd-loginid     = get-value("uadd-loginid")
            lc-uadd-name        = get-value("uadd-name")
            lc-uadd-email       = get-value("uadd-email")
            lc-uadd-phone       = get-value("uadd-phone")
            .
        IF lc-iclass = ""
            THEN lc-iclass = ENTRY(1,lc-global-iclass-code,"|").
        IF NOT ll-customer THEN
        DO:
            ASSIGN
                lc-quick          = get-value("quick")
                lc-currentstatus  = get-value("currentstatus")
                lc-currentassign  = get-value("currentassign")
                lc-actioncode     = get-value("actioncode")
                lc-actionnote     = get-value("actionnote")
                lc-customerview   = get-value("customerview")
                lc-actionstatus   = get-value("actionstatus")
                lc-activitytype   = get-value("activitytype")
                lc-startdate      = get-value("startdate")
                lc-starthour      = get-value("starthour")
                lc-startmin       = get-value("startmin")
                lc-enddate        = get-value("enddate")
                lc-endhour        = get-value("endhour")
                lc-endmin         = get-value("endmin")
                lc-hours          = get-value("hours")
                lc-mins           = get-value("mins")
                lc-manChecked     = get-value("manualTime")
                lc-manChecked     = IF lc-manChecked =  "on" THEN "checked" ELSE ""
                lc-actdescription = get-value("actdescription")
                lc-timeSecondSet  = get-value("timeSecondSet")
                lc-timeMinuteSet  = get-value("timeMinuteSet")
                lc-timeHourSet    = get-value("timeHourSet")
                lc-DefaultTimeSet = get-value("defaultTime")
                lc-contract-type  = get-value("selectcontract")
                lc-billable-flag  = get-value("billcheck")
                lc-saved-activity = get-value("savedactivetype")                
                lc-saved-contract = lc-contract-type 
                lc-saved-billable = lc-billable-flag.
            IF lc-manChecked <> "checked"  THEN
                lc-mins             = STRING(INTEGER(lc-mins) + 1).
            
        END.
        IF ll-customer
            THEN ASSIGN lc-date    = STRING(TODAY,"99/99/9999")
                lc-catcode = lc-default-catcode.
        IF lc-submitsource <> "accountchange" THEN
        DO:
            IF NUM-ENTRIES(lc-contract-type,"|") > 1
            THEN lc-contract-type = ENTRY(1,lc-contract-type,"|").
            
            IF ll-customer THEN
            DO:
                FIND FIRST WebIssCont                           
                    WHERE WebIssCont.CompanyCode     = lc-global-company     
                      AND WebIssCont.Customer        = lc-accountnumber            
                      AND WebIssCont.ConActive       = TRUE
                      AND WebissCont.defcon          = TRUE NO-LOCK NO-ERROR.
                IF NOT AVAILABLE WebissCont THEN
                FIND FIRST WebIssCont                           
                    WHERE WebIssCont.CompanyCode     = lc-global-company     
                    AND WebIssCont.Customer        = lc-accountnumber            
                    AND WebIssCont.ConActive       = TRUE
                    NO-LOCK NO-ERROR.    
                IF NOT AVAILABLE WebissCont THEN
                FIND FIRST WebIssCont                           
                        WHERE WebIssCont.CompanyCode     = lc-global-company     
                        AND WebIssCont.Customer        = lc-accountnumber            
                        NO-LOCK NO-ERROR.   
                ASSIGN
                    lc-contract-type = IF AVAILABLE webissCont THEN WebissCont.ContractCode ELSE "".         
                    
            END.
            
            
            RUN ip-Validate( OUTPUT lc-error-field,OUTPUT lc-error-msg ).
            IF lc-error-field = "" THEN
            DO:
                REPEAT:
                    FIND LAST issue 
                        WHERE issue.companycode = lc-global-company
                        NO-LOCK NO-ERROR.
                    ASSIGN
                        li-issue = IF AVAILABLE issue THEN issue.issueNumber + 1 ELSE 1.
                    LEAVE.
                END.
                IF com-TicketOnly(lc-global-company,lc-AccountNumber) THEN ASSIGN lc-ticket = "on".
                CREATE issue.
                ASSIGN 
                    issue.IssueNumber      = li-issue
                    issue.BriefDescription = lc-BriefDescription
                    issue.LongDescription  = lc-LongDescription
                    issue.AccountNumber    = lc-accountnumber
                    issue.CompanyCode      = lc-global-company
                    issue.CreateDate       = TODAY
                    issue.CreateTime       = TIME
                    issue.CreateBy         = lc-user
                    issue.IssueDate        = DATE(lc-date)
                    issue.IssueTime        = TIME
                    issue.areacode         = lc-areacode
                    issue.CatCode          = lc-catcode
                    issue.Ticket           = lc-ticket = "on"
                    issue.SearchField      = issue.BriefDescription + " " + issue.LongDescription
                    issue.ActDescription   = lc-actDescription
                    Issue.ContractType     = lc-contract-type   
                    Issue.Billable         = lc-billable-flag = "on"
                    issue.iclass           = lc-iclass.
                IF lc-emailID <> ""
                    THEN ASSIGN issue.CreateSource = "EMAIL".
                IF ll-customer THEN
                DO:
                    ASSIGN 
                        lc-sla-selected = "slanone".
                    IF customer.DefaultSLAID <> 0 THEN
                    DO:
                        FIND slahead WHERE slahead.SLAID = Customer.DefaultSLAID NO-LOCK NO-ERROR.
                        IF AVAILABLE slahead THEN ASSIGN lc-sla-selected = "sla" + string(ROWID(slahead)).
                    END.
                END.
                ASSIGN 
                    lc-sla-rows = com-CustomerAvailableSLA(lc-global-company,lc-AccountNumber).
                IF lc-sla-selected = "slanone" 
                    OR lc-sla-rows = "" THEN 
                DO:
                    ASSIGN 
                        Issue.link-SLAID = 0
                        Issue.SLAStatus  = "OFF".
                END.
                ELSE
                DO:
                    FIND slahead WHERE ROWID(slahead) = to-rowid(substr(lc-sla-selected,4)) NO-LOCK NO-ERROR.
                    IF AVAILABLE slahead THEN 
                    DO:
                        ASSIGN 
                            Issue.link-SLAID = slahead.SLAID.
                        EMPTY TEMP-TABLE tt-sla-sched.
                        RUN lib/slacalc.p
                            ( Issue.IssueDate,
                            Issue.IssueTime,
                            Issue.link-SLAID,
                            OUTPUT table tt-sla-sched ).
                        ASSIGN
                            Issue.SLADate   = ?
                            Issue.SLALevel  = 0
                            Issue.SLAStatus = "OFF"
                            Issue.SLATime   = 0
                            issue.SLATrip   = ?
                            issue.SLAAmber  = ?.
                        FOR EACH tt-sla-sched NO-LOCK WHERE tt-sla-sched.Level > 0:
                            ASSIGN 
                                Issue.SLADate[tt-sla-sched.Level] = tt-sla-sched.sDate
                                Issue.SLATime[tt-sla-sched.Level] = tt-sla-sched.sTime.
                            ASSIGN 
                                Issue.SLAStatus = "ON".
                        END.
                        IF issue.slaDate[2] <> ? 
                            THEN ASSIGN issue.SLATrip = DATETIME(STRING(Issue.SLADate[2],"99/99/9999") + " " 
                                    + STRING(Issue.SLATime[2],"HH:MM")).

                    END.
                END.
                IF lc-raisedlogin <> htmlib-Null() 
                    THEN ASSIGN issue.RaisedLoginid = lc-raisedlogin.

                IF lc-raisedLogin = ""
                    OR lc-raisedLogin =  htmlib-Null() 
                    AND lc-uadd-loginid <> "" THEN
                DO:
                    RUN ipCreateNewUser.
                    ASSIGN 
                        issue.RaisedLoginid = lc-uadd-loginid.

                END.
                ASSIGN 
                    issue.StatusCode = htmlib-GetAttr("System","DefaultStatus").
                RUN islib-StatusHistory(
                    issue.CompanyCode,
                    issue.IssueNumber,
                    lc-user,
                    "",
                    issue.StatusCode ).
                IF lc-emailid <> "" THEN
                DO:
                    FIND emailh WHERE emailh.EmailID = dec(lc-EmailID) EXCLUSIVE-LOCK NO-ERROR.
                    IF AVAILABLE emailh THEN
                    DO:
                        FOR EACH doch WHERE doch.CompanyCode = lc-global-company
                            AND doch.RelType     = "EMAIL"
                            AND doch.RelKey      = string(emailh.EmailID) EXCLUSIVE-LOCK:
                            ASSIGN
                                doch.RelType  = "ISSUE"  
                                doch.RelKey   = STRING(Issue.IssueNumber)
                                doch.CreateBy = lc-user.
                        END.
                        DELETE emailh.
                    END.
                END.
                islib-DefaultActions(lc-global-company,Issue.IssueNumber).
                IF NOT ll-Customer THEN 
                DO:
                    RUN ip-QuickUpdate.
                END.
                ELSE
                DO:
                    
                    
                    FIND Company WHERE Company.CompanyCode = lc-global-company NO-LOCK NO-ERROR.
                                       
                    ASSIGN 
                        lc-mail = "Issue: " + string(Issue.IssueNumber) 
                                + ' ' + Issue.BriefDescription + "~n" + 
                                "Customer: " + customer.name.
                    IF Issue.LongDescription <> "" 
                        THEN lc-mail = lc-mail + "~n" + Issue.LongDescription.
    
  
                        .
                    ASSIGN 
                        lc-subject = "New Issue Raised By Customer " + string(Issue.IssueNumber) +
                   ' - Customer ' + Customer.Name + ' - ' +  string(NOW,"99/99/9999 hh:mm").

                    DYNAMIC-FUNCTION("mlib-SendEmail",
                        Issue.Company,
                        DYNAMIC-FUNCTION("com-GetHelpDeskEmail","From",issue.company,Issue.AccountNumber),
                        lc-Subject,
                        lc-mail,
                        DYNAMIC-FUNCTION("com-GetHelpDeskEmail","To",issue.company,Issue.AccountNumber)).
                    IF Company.custaddissue <> "" THEN
                    DO:
                        ASSIGN 
                        lc-mail = "Issue: " + string(Issue.IssueNumber) 
                                + ' ' + Issue.BriefDescription + "~n" + 
                                "Customer: " + customer.name.
                        IF Issue.LongDescription <> "" 
                        THEN lc-mail = lc-mail + "~n" + Issue.LongDescription.
    
  
                        .
                        ASSIGN 
                            lc-subject = "Unassigned Issue Raised By Customer " + string(Issue.IssueNumber) +
                            ' - Customer ' + Customer.Name + ' - ' +  string(NOW,"99/99/9999 hh:mm").

                        DYNAMIC-FUNCTION("mlib-SendEmail",
                            Issue.Company,
                            DYNAMIC-FUNCTION("com-GetHelpDeskEmail","From",issue.company,Issue.AccountNumber),
                            lc-Subject,
                            lc-mail,
                            DYNAMIC-FUNCTION("com-GetHelpDeskEmail","To",issue.company,Issue.AccountNumber)).
                        
                    END.    
                
                END.
                    
                IF lc-gotomaint = "" THEN
                DO:
                    FIND customer WHERE customer.CompanyCode = issue.CompanyCode
                        AND customer.AccountNumber = issue.AccountNumber NO-LOCK NO-ERROR.
                    set-user-field("newissue",STRING(issue.IssueNumber)).
                    RELEASE issue.

                    IF lc-issueSource = "custenq" AND NOT ll-customer THEN
                    DO:
                        ASSIGN 
                            lc-enc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",lc-global-user,TODAY,"customer",STRING(ROWID(customer))).
                 
                        set-user-field("mode","view").
                        set-user-field("source","menu").
                        set-user-field("rowid",lc-enc-key).
                        RUN run-web-object IN web-utilities-hdl ("cust/custview.p").

                    END.
                    ELSE RUN run-web-object IN web-utilities-hdl ("iss/confissue.p").
                END.
                ELSE
                DO:
                    set-user-field("mode","update").
                    set-user-field("return","home").
                    set-user-field("rowid",STRING(ROWID(issue))).
                    RELEASE issue.
                    RUN run-web-object IN web-utilities-hdl ("iss/issueframe.p").
                END.
                RETURN.
            END.
        END.
        ELSE 
        /*
        ***
        *** Account Change and post method
        ***
        */
        DO:
            ASSIGN 
                lc-raisedLogin = htmlib-Null()                .
            FIND Customer WHERE customer.CompanyCode = lc-global-company
                AND customer.AccountNumber = lc-AccountNumber   NO-LOCK NO-ERROR.
            IF AVAILABLE customer THEN
            DO:
                ASSIGN 
                    lc-customerview = "on" 
                    lc-uadd-phone   = Customer.telephone.
                .
                IF customer.DefaultSLAID <> 0 THEN
                DO:
                    FIND slahead WHERE slahead.SLAID = customer.DefaultSLAID NO-LOCK NO-ERROR.
                    IF AVAILABLE slahead THEN ASSIGN lc-sla-selected = "sla" + string(ROWID(slahead)).
                END.
            END.
        END.
    END.
    RUN ip-GetCatCode ( OUTPUT lc-list-catcode,OUTPUT lc-list-cname ).
    IF lc-IssueSource = "custenq" THEN
    DO:
        FIND customer WHERE customer.CompanyCode = lc-global-company
            AND customer.AccountNumber = lc-AccountNumber   NO-LOCK NO-ERROR.
        ASSIGN
            lc-list-number = customer.AccountNumber
            lc-list-name   = customer.Name.
        IF request_method = "GET"
            THEN ASSIGN lc-customerview = "on".
    END.
    ELSE RUN ip-GetAccountNumbers ( INPUT lc-user,OUTPUT lc-list-number,OUTPUT lc-list-name ).
    RUN ip-GetOwner ( INPUT lc-accountnumber,OUTPUT lc-list-login,OUTPUT lc-list-lname ).
    RUN ip-GetContract ( INPUT lc-accountnumber,OUTPUT lc-list-ctype,OUTPUT lc-list-cdesc   ).
    RUN ip-GetArea ( OUTPUT lc-list-area,OUTPUT lc-list-aname ).
    ASSIGN
        lc-sla-rows = com-CustomerAvailableSLA(lc-global-company,lc-AccountNumber).

    IF request_method = "get" THEN 
    DO:
        FIND slahead WHERE slahead.SLAID = Customer.DefaultSLAID NO-LOCK NO-ERROR.

        ASSIGN 
            lc-date         = STRING(TODAY,'99/99/9999')
            lc-raisedlogin  = IF ll-customer THEN lc-user ELSE htmlib-Null()
            lc-areacode     = htmlib-Null()
            lc-gotomaint    = "on"
            lc-customerview = "on"
            lc-sla-selected = IF lc-global-company = "MICAR" THEN "slanone" 
                             ELSE IF AVAILABLE slahead THEN  "sla" + string(ROWID(slahead))
                             ELSE "slanoneZZZZ" 
            lc-catcode      = lc-default-catcode.
        IF NOT ll-Customer 
            THEN RUN ip-SetUpQuick.
    END.
    IF lc-issuesource = "email" THEN
    DO:
        FIND emailh WHERE emailh.EmailID = dec(lc-emailid)
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE emailh 
            THEN ASSIGN lc-emailid     = ""
                lc-issuesource = "".
        ELSE
        DO:
            IF request_method = "GET" THEN
                ASSIGN lc-briefdescription = emailh.Subject
                    lc-longdescription  = emailh.mText.
            IF emailh.AccountNumber <> "" THEN
            DO:
                FIND customer
                    WHERE customer.CompanyCode      = lc-global-company
                    AND customer.AccountNumber    = emailh.AccountNumber
                    NO-LOCK NO-ERROR.
                IF AVAILABLE customer THEN
                DO:
                    ASSIGN 
                        lc-customerview  = "on" 
                        lc-sla-rows      = com-CustomerAvailableSLA(lc-global-company,customer.AccountNumber)
                        lc-list-number   = customer.AccountNumber
                        lc-list-name     = customer.name
                        lc-accountnumber = customer.AccountNumber.
                    RUN ip-GetOwner ( INPUT lc-accountnumber,
                        OUTPUT lc-list-login,
                        OUTPUT lc-list-lname ).
                    IF request_method = "GET" THEN
                    DO:
                        FIND FIRST b 
                            WHERE b.CompanyCode = lc-global-company
                            AND b.Email       = emailh.Email
                            AND b.UserClass   = "CUSTOMER"
                            AND b.AccountNumber = customer.AccountNumber
                            NO-LOCK NO-ERROR.
                        IF AVAILABLE b
                            THEN ASSIGN lc-raisedlogin = b.LoginID.
                    END.
                END.
            END.
        END.
    END.
    RUN outputHeader.

    RUN ip-GenHTML.

       
  
END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-Format-Select-Account) = 0 &THEN

FUNCTION Format-Select-Account RETURNS CHARACTER
    ( pc-htm AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

    lc-htm = REPLACE(pc-htm,'<select',
        '<select onChange="ChangeAccount()"'). 


    RETURN lc-htm.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Select-Activity) = 0 &THEN

FUNCTION Format-Select-Activity RETURNS CHARACTER
    ( pc-htm AS CHARACTER  ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

    lc-htm = REPLACE(pc-htm,'<select',
        '<select onChange="ChangeActivityType()"'). 


    RETURN lc-htm.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Select-Desc) = 0 &THEN

FUNCTION Format-Select-Desc RETURNS CHARACTER
    ( pc-htm AS CHARACTER  ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

    lc-htm = REPLACE(pc-htm,'<input',
        '<input onChange="ChangeActivityDesc()"'). 


    RETURN lc-htm.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Select-Duration) = 0 &THEN

FUNCTION Format-Select-Duration RETURNS CHARACTER
    ( pc-htm AS CHARACTER   ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

    lc-htm = REPLACE(pc-htm,'<input',
        '<input onChange="ChangeDuration()"'). 

    RETURN lc-htm.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-Get-Activity) = 0 &THEN

FUNCTION Get-Activity RETURNS INTEGER
    ( pc-inp AS CHARACTER) :
    /*------------------------------------------------------------------------------
      Purpose:  Get-Activity
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN  INTEGER( ENTRY( LOOKUP(  pc-inp , lc-list-activdesc , "|" ),lc-list-actid , "|" ) ).   /* Function return value. */

END FUNCTION.


/*   lc-list-actid     = 1|15|17|19|21|23|25|27|29|31|33|35|37|39                                                                                                                                                                                                               */
/*   lc-list-activtype = Take Call|Travel To|Travel From|Meeting|Telephone Call|Survey|Config/Install|Diagnosis|Project Work|Research|Testing|Client Take-On|Administration|Other                                                                                               */
/*   lc-list-activdesc = Logging Issue|Travelling to Client|Travelling from Client|Meeting with Client|Telephone Contact with Client|Network/Site Survey|Configuration and Installation|Diagnosis of Problem|Project Work|Research|Testing|Client Take-On|Administration|Other  */
/*   lc-list-activtime = 5|1|1|1|1|1|1|1|1|1|1|1|1|1                                                                                                                                                                                                                            */


&ENDIF

&IF DEFINED(EXCLUDE-htmlib-ThisInputField) = 0 &THEN

FUNCTION htmlib-ThisInputField RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pi-size AS INTEGER,
    pc-value AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN 
        SUBSTITUTE(
        '<input class="inputfield" type="text" name="&1" id="&1" size="&2" value="&3">',
        pc-name,
        STRING(pi-size),
        pc-value).

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-Return-Submit-Button) = 0 &THEN

FUNCTION Return-Submit-Button RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pc-value AS CHARACTER,
    pc-post AS CHARACTER
    ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN SUBSTITUTE('<input class="submitbutton" type="button" name="&1" value="&2" onclick="&3"  >',
        pc-name,
        pc-value,
        pc-post
        ).

END FUNCTION.


&ENDIF

