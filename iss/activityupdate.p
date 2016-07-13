/***********************************************************************

    Program:        iss/activityupdate.p
    
    Purpose:        Issue - Action Activity Add/Update
    
    Notes:
    
    
    When        Who         What
    09/04/2006  phoski      Initial
    10/05/2015  phoski      last activity on issue
    02/07/2016  phoski      Activity type on issActivity
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


DEFINE VARIABLE lc-issue-rowid  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-action-rowid AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mode         AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-error-field  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg    AS CHARACTER NO-UNDO.
                                
DEFINE BUFFER b-table   FOR IssActivity.
DEFINE BUFFER IssAction FOR IssAction.
DEFINE BUFFER issue     FOR Issue.
DEFINE BUFFER WebAction FOR WebAction.

DEFINE VARIABLE lf-Audit          AS DECIMAL   NO-UNDO.
                                


/* Action Stuff */

DEFINE VARIABLE lc-actioncode     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ActionNote     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-CustomerView   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-billing-charge AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-actionstatus   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-assign    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-assname   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-currentassign  AS CHARACTER NO-UNDO.
                          
DEFINE VARIABLE lc-activityby     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-notes          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-description    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-actdate        AS CHARACTER NO-UNDO.

 
/* Activity */
DEFINE VARIABLE lc-hours          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mins           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-secs           AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-hours          AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-mins           AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-StartDate      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-starthour      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-startmin       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-endDate        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-endhour        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-endmin         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ActDescription AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-actid     AS CHARACTER NO-UNDO.  
DEFINE VARIABLE lc-list-activtype AS CHARACTER NO-UNDO. 
DEFINE VARIABLE lc-list-activdesc AS CHARACTER NO-UNDO.  
DEFINE VARIABLE lc-list-activtime AS CHARACTER NO-UNDO. 
DEFINE VARIABLE lc-activitytype   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-saved-contract AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-saved-billable AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-saved-activity AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-SiteVisit      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-timeSecondSet  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-manChecked     AS CHARACTER NO-UNDO.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-Format-Select-Activity) = 0 &THEN

FUNCTION Format-Select-Activity RETURNS CHARACTER
    ( pc-htm AS CHARACTER  )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Select-Duration) = 0 &THEN

FUNCTION Format-Select-Duration RETURNS CHARACTER
    ( pc-htm AS CHARACTER   )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Select-Time) = 0 &THEN

FUNCTION Format-Select-Time RETURNS CHARACTER
    ( pc-htm AS CHARACTER, pc-idx AS INTEGER  )  FORWARD.


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
         HEIGHT             = 10.19
         WIDTH              = 33.29.
/* END WINDOW DEFINITION */
                                                                        */

/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}
{lib/htmlib.i}
{lib/maillib.i}
{lib/ticket.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-ExportJScript) = 0 &THEN

PROCEDURE ip-ExportJScript :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    IF lc-timeSecondSet = "" THEN lc-timeSecondSet = "2".

    DEFINE BUFFER webStatus    FOR webStatus.

    FIND FIRST webStatus
        WHERE webStatus.CompanyCode = lc-global-company
        AND webStatus.CompletedStatus = TRUE NO-LOCK NO-ERROR.

    /*     {&out}                                                                                 */
    /*         '<script language="JavaScript" src="/scripts/js/tree.js"></script>' skip           */
 
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
       '  var startTime         =  internalTime(startHourOption,startMinuteOption) ; '  skip
       '  var endTime           =  internalTime(endHourOption,endMinuteOption) ; '  skip
       '  var durationTime      =  internalTime(curHourDuration,curMinDuration) ; '  skip
       '  document.mainform.manualTime = true; ' skip
       '  document.mainform.ffmins.value = (curMinDuration < 10 ? "0" : "") + curMinDuration ;' skip
       '~}' skip

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
       '  var startTime         =  internalTime(startHourOption,startMinuteOption) ; '  skip
       '  var endTime           =  internalTime(endHourOption,endMinuteOption) ; '  skip
       '  var durationTime      =  internalTime(curHourDuration,curMinDuration) ; '  skip
      '  var startTime         =  internalTime(startHourOption,startMinuteOption) ; '  skip
      '  var endTime           =  internalTime(endHourOption,endMinuteOption) ; '  skip
      '  var durationTime      =  internalTime(curHourDuration,curMinDuration) ; '  skip
      '  if (  (endTime - startTime) != 0  && (endTime - startTime) != durationTime )' skip
      '  ~{' skip
      '     var answer = confirm("The duration entered does not match with the Start and End time! ~\n ~\n      Press Cancel if you want to update the times before posting"); ' skip
      '     if (answer) ~{ document.forms["mainform"].submit();  ~} ' skip
      '     else  ~{ return false;  ~} ' skip
      '  ~}' skip
      '  else ~{ document.forms["mainform"].submit();  ~} ' skip
      '~}' skip


      '// INTERNAL TIME ' skip
      'function internalTime(piHours,piMins) ' skip
      '~{' skip
      '  return ( ( piHours * 60 ) * 60 ) + ( piMins * 60 ); ' skip
      '~}' skip
      '// SPLIT TIME ' skip
      'function splitTime(piTime) ' skip
      '~{' skip
      ' var retTime = new Array; ' skip
      ' var secHours = 3600 ; ' skip
      ' var secs = 0 ; ' skip
      ' var piHours = 0 ; ' skip
      ' var piMins = 0 ; ' skip
      ' secs = piTime % secHours ; ' skip
      ' piMins = Math.floor(secs / 60,0) ; ' skip
      ' piTime = piTime - secs ; ' skip
      ' piHours = Math.floor(piTime / secHours,0) ; ' skip
      ' retTime[0] = piHours ; ' skip
      ' retTime[1] = piMins ; ' skip
      ' return (retTime); ' skip
      '~}' skip
      '// CHANGE DATES ' skip
     'function chgDates(piVal,piIdx) ' skip
     '~{' skip
     '  var daysInMonth=new Array(31,28,31,30,31,30,31,31,30,31,30,31); ' skip
     '  var start = new Date(piVal);  ' skip
     '  if (start != "") ' skip
     '  ~{ ' skip
     '    var y= start.getFullYear(); ' skip
     '    // check for leap year (see if year divided by four leaves a remainder). If it is a leap year, add one day to February ' skip
     '    var remainder = y % 4; ' skip
     '    if (remainder == 0)  ' skip
     '    ~{ ' skip
     '      daysInMonth[1]=29;  ' skip
     '    ~} ' skip
     '    var m = start.getMonth(); ' skip
     '    var x = start.getDate() ; ' skip
     '    x = x + parseInt(piIdx,10); ' skip
     '    // check for roll over into next month, and then check that for roll into next year.         ' skip
     '    if (x > daysInMonth[m]) ' skip
     '    ~{ ' skip
     '      x = x - daysInMonth[m]; ' skip
     '      m++; ' skip
     '      if (m > 11) ' skip
     '      ~{ ' skip
     '        m=0; ' skip
     '        y++; ' skip
     '      ~} ' skip
     '    ~} ' skip
     '    // increment month to real month, not "Array" month ' skip
     '    m++;  ' skip
     '    if (x<10) ' skip
     '    x="0"+x ' skip
     '    if (m<10) ' skip
     '    m="0"+m ' skip
     '    var myDate = x+"/"+m+"/"+y; ' skip
     '    return(myDate); ' skip
     '  ~} ' skip
     '~} ' skip



/*                                                                                                                               */
/*       '// --  Clock --' skip                                                                                                  */
/*       'var timerID = null;' skip                                                                                              */
/*       'var timerRunning = false;' skip                                                                                        */
/*       'var timerStart = null;' skip                                                                                           */
/*       'var timeSet = null;' skip                                                                                              */
/*       'var timeSecondSet = ' lc-timeSecondSet ';' skip                                                                        */
/*       'var timeMinuteSet = 0;' skip                                                                                           */
/*       'var timeHourSet = 0;' skip                                                                                             */
/*       'var manualTime = true;' skip                                                                                           */
/*       'var timerStartseconds = 0;' skip                                                                                       */
/*                                                                                                                               */
/*       'function manualTimeSet()~{' skip                                                                                       */
/*       'manualTime = (manualTime == true) ? false : true;' skip                                                                */
/*       'if (!manualTime) ~{document.getElementById("throbber").src="/images/ajax/ajax-loader-red.gif"~}' skip                  */
/*       'else ~{document.getElementById("throbber").src="/images/ajax/ajax-loaded-red.gif"~}' skip                              */
/*       '~}' skip                                                                                                               */
/*                                                                                                                               */
/*       'function stopclock()~{' skip                                                                                           */
/*       'if(timerRunning)' skip                                                                                                 */
/*       'clearTimeout(timerID);' skip                                                                                           */
/*       'timerRunning = false;' skip                                                                                            */
/*       '~}' skip                                                                                                               */
/*                                                                                                                               */
/*       'function startclock()~{' skip                                                                                          */
/*       'stopclock();' skip                                                                                                     */
/*       'showtime();' skip                                                                                                      */
/*       'timeSecondSet = ' lc-timeSecondSet ';' skip                                                                            */
/*       'timeMinuteSet = 0;' skip                                                                                               */
/*       'timeHourSet = 0;' skip                                                                                                 */
/*       '~}' skip                                                                                                               */
/*       'function showtime()~{' skip                                                                                            */
/*       'var curMinuteOption;' skip                                                                                             */
/*       'var curHourOption;' skip                                                                                               */
/*       'var now = new Date()' skip                                                                                             */
/*       'var hours = now.getHours()' skip                                                                                       */
/*       'var minutes = now.getMinutes()' skip                                                                                   */
/*       'var seconds = now.getSeconds()' skip                                                                                   */
/*       'var millisec = now.getMilliseconds()' skip                                                                             */
/*       'var timeValue = "" +   hours' skip                                                                                     */
/*       'timeSecondSet = timeSecondSet + 1' skip                                                                                */
/*       'if (!manualTime )' skip                                                                                                */
/*       '~{'                                                                                                                    */
/*       'timeValue  += ((minutes < 10) ? ":0" : ":") + minutes' skip                                                            */
/*       'timeValue  += ((seconds < 10) ? ":0" : ":") + seconds' skip                                                            */
/*       'curHourOption = document.getElementById("endhour"  + ((minutes < 10) ? "0" : "") + hours) ' skip                       */
/*       'curHourOption.selected = true' skip                                                                                    */
/*       'curMinuteOption = document.getElementById("endmin" + ((minutes < 10) ? "0" : "") + minutes)' skip                      */
/*       'curMinuteOption.selected = true' skip                                                                                  */
/*       'if ( timeSecondSet >= 60 ) ~{ timeSecondSet = 0 ; timeMinuteSet = timeMinuteSet + 1; ~}' skip                          */
/*       'if ( timeMinuteSet >= 60 ) ~{ timeMinuteSet = 0 ; timeHourSet = timeHourSet + 1; ~}' skip                              */
/*       'document.mainform.ffhours.value = ((timeHourSet  < 10) ? "0" : "") + timeHourSet' skip                                 */
/*       'document.mainform.ffmins.value = ((timeMinuteSet < 10) ? "0" : "") + timeMinuteSet ' skip                              */
/*       'document.getElementById("clockface").innerHTML = ((timeHourSet < 10) ? "0" : "") + timeHourSet '                       */
/*       ' +   ((timeMinuteSet < 10) ? ":0" : ":") + timeMinuteSet  + ((timeSecondSet < 10) ? ":0" : ":") + timeSecondSet ' skip */
/*       '~}'                                                                                                                    */
/*       'document.getElementById("timeSecondSet").value = timeSecondSet + 2;' skip                                              */
/*       'timerRunning = true;' skip                                                                                             */
/*       'timerID = setTimeout("showtime()",1000);' skip */
/*                                                       */
/*       '~}' skip                                       */
      '</script>' skip.


/*     {&out}                                                                                 */
/*         '<script language="JavaScript" src="/scripts/js/tree.js"></script>' skip           */
/*         '<script language="JavaScript" src="/scripts/js/prototype.js"></script>' skip      */
/*         '<script language="JavaScript" src="/scripts/js/scriptaculous.js"></script>' skip. */

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

&IF DEFINED(EXCLUDE-ip-Page) = 0 &THEN

PROCEDURE ip-Page :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    {&out} htmlib-StartInputTable() skip.


    {&out} '<tr><td valign="top" align="right"'
        ( IF LOOKUP("activityby",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Activity By")
        ELSE htmlib-SideLabel("Activity By"))
    '</td>' skip
    .

    IF lc-mode = "ADD" THEN
        {&out} '<td valign="top" align="left">'
    htmlib-Select("activityby",lc-list-assign,lc-list-assname,
        lc-activityby)
    '</td>'.
    else
    {&out} htmlib-TableField(html-encode(com-UserName(lc-activityby)),'left')
           skip.
    {&out} '</tr>' skip.
   
    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("actdate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Date")
        ELSE htmlib-SideLabel("Date"))
    '</td>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<td valign="top" align="left">'
    htmlib-InputField("actdate",10,lc-actdate) 
    htmlib-CalendarLink("actdate")
    '</td>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-actdate),'left')
           skip.
    {&out} '</tr>' skip.


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
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<td valign="top" align="left">'
    htmlib-InputField("startdate",10,lc-startdate) 
    htmlib-CalendarLink("startdate")
    "&nbsp;@&nbsp;"
    htmlib-TimeSelect("starthour",lc-starthour,"startmin",lc-startmin)
    '</td>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-startdate),'left')
           skip.
    {&out} '</tr>' skip.

    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("enddate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("End Date")
        ELSE htmlib-SideLabel("End Date"))
    '</td>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<td valign="top" align="left">'
    htmlib-InputField("enddate",10,lc-enddate) 
    htmlib-CalendarLink("enddate")
    "&nbsp;@&nbsp;"
    htmlib-TimeSelect-By-Id("endhour",lc-endhour,"endmin",lc-endmin)
    '</td>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-enddate),'left')
           skip.
    {&out} '</tr>' skip.



    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("hours",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Duration (HH:MM)")
        ELSE htmlib-SideLabel("Duration (HH:MM)"))
    '</td>'.
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<td valign="top" align="left">'
    Format-Select-Duration(htmlib-InputField("hours",4,lc-hours))
    ':'
    Format-Select-Duration(htmlib-InputField("mins",2,lc-mins))
    '</td>' skip.
   else 
   {&out} htmlib-TableField(html-encode(lc-hours),'left')
          skip.
    {&out} '</tr>' skip.
    


    /*     if lc-mode = "add" then do:                                                                                                    */
    /*                                                                                                                                    */
    /*     {&out} '<tr><td valign="top" align="right">'                                                                                   */
    /*             (if lookup("manualTime",lc-error-field,'|') > 0                                                                        */
    /*             then htmlib-SideLabelError("Manual Time Entry?")                                                                       */
    /*             else htmlib-SideLabel("Manual Time Entry?"))                                                                           */
    /*             '</td>'.                                                                                                               */
    /*                                                                                                                                    */
    /*                                                                                                                                    */
    /*     {&out} '<td valign="top" align="left">'                                                                                        */
    /*             '<input class="inputfield" type="checkbox" onclick="javascript:manualTimeSet()" name="manualTime" ' lc-manChecked ' >' */
    /*             '</td>' skip.                                                                                                          */
    /*     end.                                                                                                                           */

    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("sitevisit",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Site Visit?")
        ELSE htmlib-SideLabel("Site Visit?"))
    '</td>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<td valign="top" align="left">'
    htmlib-CheckBox("sitevisit", IF lc-sitevisit = 'on'
        THEN TRUE ELSE FALSE) 
    '</td>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-sitevisit = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</tr>' skip.
    /**/

    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("customerview",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Customer View?")
        ELSE htmlib-SideLabel("Customer View?"))
    '</td>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<td valign="top" align="left">'
    htmlib-CheckBox("customerview", IF lc-customerview = 'on'
        THEN TRUE ELSE FALSE) 
    '</td>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-customerview = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</tr>' skip.


    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("actdescription",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Activity Description")
        ELSE htmlib-SideLabel("Activity Description"))
    '</td><td valign="top" align="left">'
    htmlib-ThisInputField("actdescription",40,lc-actdescription) 
    '</td></tr>' skip.


    {&out} '<tr><td valign="top" align="right">' 
    htmlib-SideLabel("Charge for Activity?")
    '</td><td valign="top" align="left">'
    htmlib-CheckBox("billingcharge", IF lc-billing-charge = 'on'
        THEN TRUE ELSE FALSE)
    '</td></tr>' skip.


    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("description",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Description")
        ELSE htmlib-SideLabel("Description"))
    '</td>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<td valign="top" align="left">'
    htmlib-InputField("description",40,lc-description) 
    '</td>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-description),'left')
           skip.
    {&out} '</tr>' skip.


    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("notes",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Note")
        ELSE htmlib-SideLabel("Note"))
    '</td>' skip
           '<td valign="top" align="left">'
           htmlib-TextArea("notes",lc-notes,6,40)
          '</td></tr>' skip
           skip.

    {&out} htmlib-EndTable() skip.

    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<br><br><center>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</center>' skip.
    END.
    {&out} '<center>' skip.

    IF lc-submit-label <> "" THEN
    DO:
        {&out}
        Return-Submit-Button("submitform",lc-submit-label,"PrePost()")  skip.

    END.
    /*     if lc-mode = "updatesingle" then */
    /*     do:                              */
    {&out} 
    '<input class="submitbutton" type="button" onclick="window.close()"' skip
        ' value="Close" />' skip .

    /*     end. */
    {&out} '</center>' skip
      '<div style="display:none;">' skip
      '<input class="inputfield" type="checkbox" name="manualTime" id="manualTime" ' lc-manChecked ' >' skip
      '</div>' skip       
    .

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


    DEFINE VARIABLE ld-date     AS DATE     NO-UNDO.
    DEFINE VARIABLE li-int      AS INTEGER      NO-UNDO.
    DEFINE VARIABLE ld-startd   AS DATE     NO-UNDO.
    DEFINE VARIABLE ld-endd     AS DATE     NO-UNDO.
    DEFINE VARIABLE li-startt   AS INTEGER      NO-UNDO.
    DEFINE VARIABLE li-endt     AS INTEGER      NO-UNDO.
    
    ASSIGN
        ld-date = DATE(lc-actdate) no-error.

    IF ERROR-STATUS:ERROR
        OR ld-date = ? 
        THEN RUN htmlib-AddErrorMessage(
            'actdate', 
            'The date is invalid',
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

    IF lc-enddate <> "" THEN
    DO:
        ASSIGN 
            ld-endd = DATE(lc-enddate) no-error.
        IF ERROR-STATUS:ERROR
            OR ld-endd = ? THEN
        DO:
            RUN htmlib-AddErrorMessage(
                'enddate', 
                'The end date is invalid',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).

        END.
    END.
    ELSE ASSIGN ld-endd = ?.

    IF ld-endd <> ?
        AND ld-startd = ? THEN
    DO:
        RUN htmlib-AddErrorMessage(
            'enddate', 
            'You must enter a start date if you enter an end date',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    END.

    IF ( ld-endd <> ? AND ld-startd <> ? ) THEN
    DO:
        IF ( ld-startd > ld-endd ) 
            THEN RUN htmlib-AddErrorMessage(
                'enddate', 
                'The end date can not be before the start date',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).
        ASSIGN
            li-startt = DYNAMIC-FUNCTION("com-InternalTime",
                                         int(lc-starthour),
                                         int(lc-startmin)
                                         ).
        li-endt = DYNAMIC-FUNCTION("com-InternalTime",
            int(lc-endhour),
            int(lc-endmin)
            ).
        IF ld-endd = ld-startd
            AND li-endt < li-startt THEN
        DO:
            RUN htmlib-AddErrorMessage(
                'enddate', 
                'The end time can not be before the start time',
                INPUT-OUTPUT pc-error-field,
                INPUT-OUTPUT pc-error-msg ).

        END.
    END.

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

    IF lc-description = "" 
        THEN RUN htmlib-AddErrorMessage(
            'description', 
            'You must enter the description',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ipResetLastActivity) = 0 &THEN

PROCEDURE ipResetLastActivity :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pr-issue      AS ROWID            NO-UNDO.

    DEFINE BUFFER issue        FOR issue.
    DEFINE BUFFER b-query      FOR issAction.
    DEFINE BUFFER IssActivity  FOR IssActivity.

    DEFINE VARIABLE ldt LIKE issue.lastactivity NO-UNDO.
    DEFINE VARIABLE LC  AS CHARACTER FORMAT 'x(20)'.

    DO TRANSACTION:
    
        FIND issue WHERE ROWID(issue) = pr-issue EXCLUSIVE-LOCK.


        ldt = ?.
        LC = "".

        FOR EACH b-query NO-LOCK
            WHERE b-query.CompanyCode = issue.companyCode
            AND b-query.IssueNumber = issue.IssueNumber
            , EACH IssActivity NO-LOCK
            WHERE issActivity.CompanyCode = b-query.CompanyCode
            AND issActivity.IssueNumber = b-query.IssueNumber
            AND IssActivity.IssActionId = b-query.IssActionID
            AND IssActivity.StartDate <> ?

            BY IssActivity.StartDate DESCENDING
            BY IssActivity.StartTime DESCENDING

            :
            /*
            ldt = DATETIME(IssActivity.StartDate,STRING(IssActivity.StartTime,"HH:MM").
            */

            LC = STRING(IssActivity.StartDate,"99/99/9999") + " " + STRING(IssActivity.StartTime,"HH:MM").
            ldt = DATETIME(LC).

            LEAVE.
        END.
        ASSIGN
            issue.LastActivity = ldt.


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

    DEFINE VARIABLE li-old-duration     LIKE IssActivity.Duration       NO-UNDO.
    DEFINE VARIABLE li-amount           LIKE IssActivity.Duration       NO-UNDO.

    {lib/checkloggedin.i}

    ASSIGN 
        lc-issue-rowid  = get-value("issuerowid")
        lc-rowid        = get-value("rowid")
        lc-mode         = get-value("mode")
        lc-action-rowid = get-value("actionrowid").



 

    FIND issue
        WHERE ROWID(issue) = to-rowid(lc-issue-rowid) NO-LOCK.
    
    FIND customer WHERE Customer.CompanyCode = Issue.CompanyCode
        AND Customer.AccountNumber = Issue.AccountNumber
        NO-LOCK NO-ERROR.
    FIND IssAction
        WHERE ROWID(IssAction) = to-rowid(lc-action-rowid) NO-LOCK.
    FIND WebAction
        WHERE WebAction.ActionID = IssAction.ActionID NO-LOCK NO-ERROR.

    

    RUN com-GetActivityType ( lc-global-company , OUTPUT lc-list-actid, OUTPUT lc-list-activtype, OUTPUT lc-list-activdesc, OUTPUT lc-list-activtime ).
    RUN com-GetInternalUser ( lc-global-company , OUTPUT lc-list-assign , OUTPUT lc-list-assname ).

    CASE lc-mode:
        WHEN 'add'
        THEN 
            ASSIGN 
                lc-title = 'Add'
                lc-link-label = "Cancel addition"
                lc-submit-label = "Add Activity"
                lc-manChecked = "" .
        WHEN 'Update' 
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Activity'
                lc-manChecked = "checked".
        WHEN 'Updatesingle'
        THEN 
            ASSIGN 
                lc-title = 'Update'
                lc-link-label = 'Cancel update'
                lc-submit-label = 'Update Activity'
                lc-manChecked = "checked".


    END CASE.

    ASSIGN
        lc-title = lc-title + " Activity - Issue " + string(issue.IssueNumber) +
        ' - Action ' + html-encode(WebAction.Description).


    

    IF request_method = "POST" THEN
    DO:

        IF lc-mode <> "delete" THEN
        DO:                           
            ASSIGN 
                lc-activityby       = get-value("activityby")
                lc-actdate          = get-value("actdate")             
                lc-StartDate        = get-value("startdate")
                lc-starthour        = get-value("starthour")
                lc-startmin         = get-value("startmin")
                lc-endDate          = get-value("enddate")
                lc-endhour          = get-value("endhour")
                lc-endmin           = get-value("endmin")            
                lc-hours            = get-value("hours")
                lc-mins             = get-value("mins")
                lc-sitevisit        = get-value("sitevisit")
                lc-customerview     = get-value("customerview")
                lc-description      = get-value("description")         
                lc-notes            = get-value("notes")  
                lc-activitytype     = get-value("activitytype")
                lc-billing-charge   = get-value("billingcharge")
                lc-timeSecondSet    = get-value("timeSecondSet")
                .
            
               
            RUN ip-Validate( OUTPUT lc-error-field,
                OUTPUT lc-error-msg ).

            IF lc-error-msg = "" THEN
            DO:
                
                IF lc-mode = 'update' OR lc-mode = 'updatesingle' THEN
                DO:
                    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid)
                        EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                    IF LOCKED b-table 
                        THEN  RUN htmlib-AddErrorMessage(
                            'none', 
                            'This record is locked by another user',
                            INPUT-OUTPUT lc-error-field,
                            INPUT-OUTPUT lc-error-msg ).
                    ELSE ASSIGN li-old-duration = b-table.Duration.
                END.
                ELSE
                DO:
                    CREATE b-table.
                    ASSIGN 
                        b-table.IssActionID = IssAction.IssActionID
                        b-table.CompanyCode = lc-global-company
                        b-table.IssueNumber = issue.IssueNumber
                        b-table.CreateDate  = TODAY
                        b-table.CreateTime  = TIME
                        b-table.CreatedBy   = lc-global-user
                        b-table.ActivityBy  = lc-ActivityBy
                        b-table.activityType = lc-activitytype
                        .

                    DO WHILE TRUE:
                        RUN lib/makeaudit.p (
                            "",
                            OUTPUT lf-audit
                            ).
                        IF CAN-FIND(FIRST IssActivity
                            WHERE IssActivity.IssActivityID = lf-audit NO-LOCK)
                            THEN NEXT.
                        ASSIGN
                            b-table.IssActivityID = lf-audit.
                        LEAVE.
                    END.
                   
                END.
                IF lc-error-msg = "" THEN
                DO:
                    ASSIGN 
                        b-table.notes            = lc-notes
                        b-table.description      = lc-description
                        b-table.ActDate          = DATE(lc-ActDate)
                        b-table.customerview     = lc-customerview = "on"
                        b-table.SiteVisit        = lc-SiteVisit = "on"
                        b-table.Billable         = lc-billing-charge  = "on"
                        b-table.TypeID         = int(lc-activitytype)
                        .   
                    ASSIGN
                        b-table.activityType = com-GetActivityByType(lc-global-company,b-table.TypeID).
                        

                    IF lc-startdate <> "" THEN
                    DO:
                        ASSIGN 
                            b-table.StartDate = DATE(lc-StartDate).

                        ASSIGN 
                            b-table.StartTime = DYNAMIC-FUNCTION("com-InternalTime",
                                         int(lc-starthour),
                                         int(lc-startmin)
                                         ).
                    END.
                    ELSE ASSIGN b-table.StartDate = ?
                            b-table.StartTime = 0.

                    IF lc-enddate <> "" THEN
                    DO:
                        ASSIGN 
                            b-table.EndDate = DATE(lc-endDate).
    
                        ASSIGN 
                            b-table.Endtime = DYNAMIC-FUNCTION("com-InternalTime",
                                        int(lc-endhour),
                                        int(lc-endmin)
                                        ).
                        
                    END.
                    ELSE ASSIGN b-table.EndDate = ?
                            b-table.EndTime = 0.


                    ASSIGN 
                        b-table.Duration = 
                        ( ( int(lc-hours) * 60 ) * 60 ) + 
                        ( int(lc-mins) * 60 ).

                    IF Issue.Ticket THEN
                    DO:
                        ASSIGN
                            li-amount = 
                                b-table.Duration - li-old-duration.
                        IF li-amount <> 0 THEN
                        DO:
                            EMPTY TEMP-TABLE tt-ticket.
                            CREATE tt-ticket.
                            ASSIGN
                                tt-ticket.CompanyCode       =   issue.CompanyCode
                                tt-ticket.AccountNumber     =   issue.AccountNumber
                                tt-ticket.Amount            =   li-Amount * -1
                                tt-ticket.CreateBy          =   lc-global-user
                                tt-ticket.CreateDate        =   TODAY
                                tt-ticket.CreateTime        =   TIME
                                tt-ticket.IssueNumber       =   Issue.IssueNumber
                                tt-ticket.Reference         =   b-table.description
                                tt-ticket.TickID            =   ?
                                tt-ticket.TxnDate           =   b-table.ActDate
                                tt-ticket.TxnTime           =   TIME
                                tt-ticket.TxnType           =   "ACT"
                                tt-ticket.IssActivityID     =   b-table.IssActivityID.
                            RUN tlib-PostTicket.


                        END.

                    END.
                END.
            END.
        END.
        ELSE
        DO:
            FIND b-table WHERE ROWID(b-table) = to-rowid(lc-action-rowid)
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
            RUN ipResetLastActivity ( ROWID(issue)).
            RUN outputHeader.
            {&out} 
            '<html>' skip
                '<script language="javascript">' skip
                'function CloseOut() ~{ ' skip
                ' var ParentWindow = opener' skip
                ' ParentWindow.parent.RefreshDiary() ' skip
                ' window.close() ' skip
                ' ~} ' skip
                '</script>' skip  
                '<style type="text/css">' skip
                'h1 ~{ ' skip
                'color: #0033CC;   ' skip
                '~}' skip
                '</style>' skip
                '<body width="100%">' skip
                '<div  style="font-color:#E0E3E7;margin-left:auto;margin-right:auto;margin-top:80px;text-align:center;"><h1>ActionUpdated</h1><br />' skip

                '<center><input class="submitbutton" type="button" onclick="CloseOut()" value="Close" ></center></div>' skip 
                '</body></html>' skip
            .
            RETURN.
        END.
    END.

    IF lc-mode <> 'add' THEN
    DO:
        FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
        
        IF CAN-DO("view,delete",lc-mode)
            OR request_method <> "post"
            THEN 
        DO:
            ASSIGN 
                lc-notes           = b-table.notes
                lc-description     = b-table.description
                lc-activityby      = b-table.ActivityBy
                lc-actdate         = STRING(b-table.ActDate,"99/99/9999")
                lc-customerview    = IF b-table.CustomerView THEN "on" ELSE ""
                lc-sitevisit       = IF b-table.SiteVisit THEN "on" ELSE ""
                lc-billing-charge  = IF b-table.Billable THEN "on" ELSE ""
                lc-actdescription  = b-table.ActDescription 
                lc-saved-activity  = IF b-table.typeid <> 0 THEN STRING(b-table.Typeid) ELSE STRING(Get-Activity( b-table.ActDescription ))
                      .
            IF b-table.Duration > 0 THEN
            DO:
                RUN com-SplitTime ( b-table.Duration, OUTPUT li-hours, OUTPUT li-mins ).
                ASSIGN 
                    lc-hours = STRING(INTEGER(li-hours),"zz99")
                    lc-mins  = STRING(INTEGER(li-mins),"99").
 

            END.

            IF b-table.StartDate <> ? THEN
            DO:
                ASSIGN 
                    lc-startdate = STRING(b-table.StartDate,"99/99/9999").
                IF b-table.StartTime <> 0 THEN
                DO:
                    ASSIGN 
                        lc-StartHour = STRING(int(substr(STRING(b-table.StartTime,"hh:mm"),1,2)))
                        lc-StartMin  = substr(STRING(b-table.StartTime,"hh:mm"),4,2).
                END.
            END.

            IF b-table.endDate <> ? THEN
            DO:
                ASSIGN 
                    lc-enddate = STRING(b-table.endDate,"99/99/9999").
                IF b-table.endTime <> 0 THEN
                DO:
                    ASSIGN 
                        lc-endHour = STRING(int(substr(STRING(b-table.endTime,"hh:mm"),1,2)))
                        lc-endMin  = substr(STRING(b-table.endTime,"hh:mm"),4,2).
                END.
            END.
        END.
    END.
    
    IF request_method = "GET" AND lc-mode = "ADD" THEN
    DO:
        ASSIGN 
            lc-customerview     = IF Customer.ViewActivity THEN "on" ELSE ""   
            lc-activityby       = lc-global-user
            lc-actdate          = STRING(TODAY,"99/99/9999")
            lc-actdescription   = "ACTIVITYDESC"  
            lc-activitytype     = "ACTIVITYTYPE"  
            lc-billing-charge   = IF IssAction.Billable THEN "on" ELSE "" 
            lc-timeSecondSet    = "2"
            lc-mins             = "2"
            lc-startdate        = STRING(TODAY,"99/99/9999")
            lc-StartHour        = STRING(int(substr(STRING(TIME,"hh:mm"),1,2)))
            lc-StartMin         = substr(STRING(TIME,"hh:mm"),4,2)
            lc-enddate          = STRING(TODAY,"99/99/9999")
            lc-endHour          = STRING(int(substr(STRING(TIME,"hh:mm"),1,2)))
            lc-endMin           = substr(STRING(TIME,"hh:mm"),4,2).

    END.

    RUN outputHeader.
    
    {&out} htmlib-OpenHeader(lc-title) skip.

    RUN ip-ExportJScript.

    {&out} htmlib-CloseHeader("") skip.

    {&out}
    htmlib-StartForm("mainform","post", selfurl)
    htmlib-ProgramTitle(lc-title) skip.


  
    IF lc-mode <> "update" AND lc-mode <> "updatesingle" THEN
    DO:
        {&out}
        '<div align="right">' skip
          '<span id="clockface" class="clockface">' skip
          '....Initializing....' skip
          '</span><img id="throbber" src="/images/ajax/ajax-loader-red.gif"></div>' skip
          '<tr><td valign="top"><fieldset><legend>Main Issue Entry</legend>' skip
        .
    END.
    RUN ip-Page.

    {&out} htmlib-Hidden("issuerowid",lc-issue-rowid) skip
           htmlib-Hidden("mode",lc-mode) skip
           htmlib-Hidden("rowid",lc-rowid) skip
           htmlib-Hidden("actionrowid",lc-action-rowid) skip
           htmlib-Hidden("timeSecondSet",lc-timeSecondSet) skip.


    {&out} htmlib-Hidden("savedactivetype",lc-saved-activity) skip   
           htmlib-Hidden("actDesc",lc-list-activdesc) skip     
           htmlib-Hidden("actTime",lc-list-activtime) skip 
           htmlib-Hidden("actID",lc-list-actid) skip .


    {&out} htmlib-EndForm() skip.


    IF NOT CAN-DO("view,delete",lc-mode)  THEN
    DO:
        {&out}
        htmlib-CalendarScript("actdate") skip
            htmlib-CalendarScript("startdate") skip
            htmlib-CalendarScript("enddate") skip.
    END.
    IF lc-mode <> "update" AND lc-mode <> "updatesingle" THEN
    DO:
        {&out}
        '<script type="text/javascript">' skip
      'startclock();' skip
      '</script>' skip.
    END.

    {&out}
    htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

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

&IF DEFINED(EXCLUDE-Format-Select-Time) = 0 &THEN

FUNCTION Format-Select-Time RETURNS CHARACTER
    ( pc-htm AS CHARACTER, pc-idx AS INTEGER  ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

    IF pc-idx = 1 THEN
        lc-htm = REPLACE(pc-htm,'<select',
            '<select onChange="ChangeDuration(' + string(pc-idx) + ')"'). 
    ELSE
        lc-htm = REPLACE(pc-htm,'<input',
            '<input onChange="ChangeDuration(' + string(pc-idx) + ')"'). 

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

