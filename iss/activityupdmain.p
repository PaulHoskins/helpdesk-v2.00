/***********************************************************************

    Program:        iss/activityupdate.p
    
    Purpose:        Issue - Action Activity Add/Update
    
    Notes:
    
    
    When        Who         What
    09/04/2006  phoski      Initial
    10/05/2014  phoski      last activity on issue
    08/12/2014  phoski      Fix Timer
    19/03/2015  phoski      Various DJS issues
    24/03/2015  phoski      No more js prompt on time start/end diffs
    09/05/2015  phoski      Complex Project
    12/03/2016  phoski      Customer view flag is on by default
    01/07/2016  phoski      Only active users for add function
    02/07/2016  phoski      Activity type on issActivity
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


DEFINE VARIABLE lc-issue-rowid  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-action-rowid AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-action-index AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mode         AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-link-label   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-error-field  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg    AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-error        AS INTEGER   NO-UNDO.

DEFINE BUFFER b-table   FOR IssActivity.
DEFINE BUFFER IssAction FOR IssAction.
DEFINE BUFFER issue     FOR Issue.
DEFINE BUFFER WebAction FOR WebAction.

DEFINE BUFFER webStatus FOR webStatus.

DEFINE VARIABLE lf-Audit               AS DECIMAL   NO-UNDO.




/* Action Stuff */

DEFINE VARIABLE lc-actioncode          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ActionNote          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-CustomerView        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-description         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-billing-charge      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-actionstatus        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-assign         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-assname        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-currentassign       AS CHARACTER NO-UNDO.
                               
                               
/* Activity */                 
DEFINE VARIABLE lc-hours               AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mins                AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-secs                AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-hours               AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-mins                AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-StartDate           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-starthour           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-startmin            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-endDate             AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-endhour             AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-endmin              AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ActDescription      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-activity       AS CHARACTER NO-UNDO.  
DEFINE VARIABLE lc-list-actname        AS CHARACTER NO-UNDO.  
DEFINE VARIABLE lc-activitytype        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-activityby          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-notes               AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-actdate             AS CHARACTER NO-UNDO.
 
 
DEFINE VARIABLE lc-list-actid          AS CHARACTER NO-UNDO.  
DEFINE VARIABLE lc-list-activtype      AS CHARACTER NO-UNDO. 
DEFINE VARIABLE lc-list-activdesc      AS CHARACTER NO-UNDO.  
DEFINE VARIABLE lc-list-activtime      AS CHARACTER NO-UNDO. 
                               
                               
DEFINE VARIABLE lc-saved-contract      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-saved-billable      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-saved-activity      AS CHARACTER NO-UNDO.
 
DEFINE VARIABLE lc-SiteVisit           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-timeSecondSet       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-timeMinuteSet       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-timeHourSet         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-DefaultTimeSet      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-manChecked          AS CHARACTER NO-UNDO.


DEFINE VARIABLE lc-save-activityby     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-actdate        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-customerview   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-StartDate      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-starthour      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-startmin       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-endDate        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-endhour        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-endmin         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-DefaultTimeSet AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-hours          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-mins           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-secs           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-sitevisit      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-description    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-notes          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-manChecked     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-actdescription AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-billing-charge AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-timeSecondSet  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-timeMinuteSet  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-save-timeHourSet    AS CHARACTER NO-UNDO.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-Format-Select-Activity) = 0 &THEN

FUNCTION Format-Select-Activity RETURNS CHARACTER
    ( pc-htm AS CHARACTER, pc-index AS INTEGER  )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Select-Duration) = 0 &THEN

FUNCTION Format-Select-Duration RETURNS CHARACTER
    ( pc-htm AS CHARACTER , pc-idx AS INTEGER  )  FORWARD.


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
         HEIGHT             = 10.27
         WIDTH              = 32.14.
/* END WINDOW DEFINITION */
                                                                        */

/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}
{lib/htmlib.i}
{lib/maillib.i}
{lib/ticket.i}



 




/* ************************  Main Code Block  *********************** */


FIND FIRST webStatus
    WHERE webStatus.CompanyCode = lc-global-company
    AND webStatus.CompletedStatus = TRUE NO-LOCK NO-ERROR.


{lib/checkloggedin.i}

/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-ExportAccordion) = 0 &THEN

PROCEDURE ip-ExportAccordion :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/



    {&out}
    '<style type="text/css">' skip
      
      '.clear ~{ /* generic container (i.e. div) for floating buttons */' skip
      'overflow: hidden;'    skip
      'width: 100%;' skip
      '~}' skip

      'a.button ~{' skip
      'background: transparent url(~'/images/toolbar/bg_button_a.gif~') no-repeat scroll top right;' skip
      'color: #444;' skip
      'display: block;' skip
      'float: left;' skip
      'font: normal 12px arial, sans-serif;' skip
      'height: 24px;' skip
      'margin-right: 6px;' skip
      'padding-right: 18px; /* sliding doors padding */' skip
      'text-decoration: none;' skip
      '~}' skip

      'a.button span ~{' skip
      'background: transparent url(~'/images/toolbar/bg_button_span1.gif~') no-repeat;' skip
      'display: block;' skip
      'line-height: 14px;' skip
      'padding: 5px 0 5px 18px;' skip
       'cursor: pointer;' skip
      '~} ' skip

      'a.button:active ~{' skip
      'background-position: bottom right;' skip
      'color: #000;' skip
      'outline: none; /* hide dotted outline in Firefox */' skip
       'cursor: pointer;' skip
      '~}' skip

      'a.button:active span ~{' skip
      'background-position: bottom left;' skip
      'padding: 6px 0 4px 18px; /* push text down 1px */' skip
       'cursor: pointer;' skip
      '~} ' skip

      '.buttonbox ~{' skip
      'border: 0px dotted blue;'  skip
      'padding: 1px; ' skip
      'margin-bottom: 1px;'  skip
      'margin-top: 1px; ' skip
      'font-weight: bold; ' skip
      'background-color: #FFFFFF;' skip
      'position: relative;' skip
      'width: 100%;' skip
      'height: 20px;     ' skip
      '~}' skip


      '.AccordionTitle, .AccordionContent, .AccordionContainer' skip
      '~{' skip
      'position: relative;' skip
      'margin-left:auto;' skip
      'margin-right:auto;' skip
      'width: 650px; /*changeble*/' skip
      'border-bottom: 1px dotted white;' skip
      '~}' skip


      '.AccordionTitle' skip
      '~{' skip
      'height: 20px; /*changeble*/' skip
      'overflow: hidden;' skip
      'cursor: pointer;' skip
      'font-family: Verdana; /*changeble*/' skip
      'font-size: 12px; /*changeble*/' skip
      'font-weight: normal; /*changeble*/' skip
      'vertical-align: middle; /*changeble*/' skip
      'text-align: center; /*changeble*/' skip
      'display: table-cell;' skip
      '-moz-user-select: none;' skip
      'border-top: none; /*changeble*/' skip
      'border-bottom: none; /*changeble*/' skip
      'border-left: none; /*changeble*/' skip
      'border-right: none; /*changeble*/' skip
      'background-color: #0099cc;' skip
      'color: White;' skip
      '~}' skip


      '.AccordionContent' skip
      '~{' skip
      'height: 0px;' skip
      'overflow: hidden; /*display: none;  */' skip
      '~}' skip


      '.AccordionContent_' skip
      '~{' skip
      'height: auto;' skip
      '~}' skip


      '.AccordionContainer' skip
      '~{' skip
      'border-top: solid 1px #C1C1C1; /*changeble*/' skip
      'border-bottom: solid 1px #C1C1C1; /*changeble*/' skip
      'border-left: solid 1px #C1C1C1; /*changeble*/' skip
      'border-right: solid 1px #C1C1C1; /*changeble*/' skip
      '~}' skip


      '.ContentTable' skip
      '~{' skip
      'width: 100%;' skip
      'text-align: center;' skip
      'color: White;' skip
      '~}' skip

      '.ContentCell' skip
      '~{' skip
      'background-color: #666666;' skip
      '~}' skip

      '.ContentTable a:link, a:visited' skip
      '~{' skip
      'color: White;' skip
      'text-decoration: none;' skip
      '~}' skip

      '.ContentTable a:hover' skip
      '~{' skip
      'color: Yellow;' skip
      'text-decoration: none;' skip
      '~}' skip

      '</style>' skip

      '<script type="text/javascript" language="JavaScript">' skip
      'var ContentHeight = 0;' skip
      'var TimeToSlide = 200;' skip
      'var openAccordion = "";' skip
      'var totalAcc = 0 ;' skip
      'var firstTime = ' if lc-mode = 'display' or lc-mode = 'insert' then 'true' else 'false' skip
      
      'function runAccordion(index)' skip
      '~{' skip
      'var nID = "Accordion" + index + "Content";' skip
      'if(openAccordion == nID)' skip
      'nID = "";' skip

      'ContentHeight = document.getElementById("Accordion" + index + "Content"+"_").offsetHeight;' skip
      'setTimeout("animate(" + new Date().getTime() + "," + TimeToSlide + ",~'"' skip
      '+ openAccordion + "~',~'" + nID + "~')", 33);' skip
      'openAccordion = nID;' skip
      '~}' skip

      'function animate(lastTick, timeLeft, closingId, openingId)' skip
      '~{' skip
      'var curTick = new Date().getTime();' skip
      'var elapsedTicks = curTick - lastTick;' skip
      'var opening = (openingId == "") ? null : document.getElementById(openingId);' skip
      'var closing = (closingId == "") ? null : document.getElementById(closingId);' skip

      'if(timeLeft <= elapsedTicks)' skip
      '~{' skip
      'if(opening != null)' skip
      'opening.style.height = ~'auto~';' skip
      'if(closing != null)' skip
      '~{' skip
      '//closing.style.display = ~'none~';' skip
      'closing.style.height = ~'0px~';' skip
      '~}' skip
      'return;' skip
      '~}' skip

      'timeLeft -= elapsedTicks;' skip
      'var newClosedHeight = Math.round((timeLeft/TimeToSlide) * ContentHeight);' skip

      'if(opening != null)' skip
      '~{' skip
      'if(opening.style.display != ~'block~')' skip
      'opening.style.display = ~'block~';' skip
      'opening.style.height = (ContentHeight - newClosedHeight) + ~'px~';' skip
      '~}' skip

      'if(closing != null)' skip
      'closing.style.height = newClosedHeight + ~'px~';' skip
      'setTimeout("animate(" + curTick + "," + timeLeft + ",~'"' skip
      '+ closingId + "~',~'" + openingId + "~')", 33);' skip
      '~}' skip

      'function checkLoad()' skip
      '~{' skip

      'if (window.onLoad)' skip
      '~{' skip
      'window.resizeBy(0, totalAcc * 20);' skip
      '~}' skip
      'else ~{' skip
      'setTimeout("checkLoad();", 1000);' skip
      '~}' skip
/*         'alert(firstTime);' skip */
      'if ( firstTime )' skip
      '~{' skip
      'firstTime = false;' skip
      'fitWindow();' skip
      '~}' skip
      '~}' skip


      'function FitBody() ~{' skip
      'var iSize = getSizeXY();' skip
      'var iScroll = getScrollXY();' skip
/*       'window.alert( 'Width = ' + iSize[0]  +  '   Height = ' + iSize[1] );' skip     */
/*       'window.alert( 'Width = ' + iScroll[0]  +  '   Height = ' + iScroll[1] );' skip */
      'iWidth = iSize[0] + iScroll[0] + 28 ;' skip
      'iHeight = iSize[1] + iScroll[1] + iScroll[1] + 20 ;' skip
/*       'window.alert( 'Width = ' + iWidth  +  '   Height = ' + iHeight );' skip */
      'if (iScroll[1] != 0 ) window.resizeTo(iWidth, iHeight);' skip
      'self.focus();' skip
      '~};' skip

      'function getSizeXY() ~{' skip
      'var myWidth = 0, myHeight = 0;' skip
      'if( typeof( window.innerWidth ) == "number" ) ~{' skip
      '//Non-IE' skip
      'myWidth = window.innerWidth;' skip
      'myHeight = window.innerHeight;' skip
      '//window.alert("NON IE");' skip
      '~} else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) ~{' skip
      '//IE 6+ in standards compliant mode' skip
      'myWidth = document.documentElement.clientWidth;' skip
      'myHeight = document.documentElement.clientHeight;' skip
      '//window.alert("IE 6");' skip
      '~} else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) ~{' skip
      '//IE 4 compatible' skip
      'myWidth = document.body.clientWidth;' skip
      'myHeight = document.body.clientHeight;' skip
      '//window.alert("IE 4");' skip
      '~}' skip
/*       '//window.alert( 'Width = ' + myWidth  +  '   Height = ' + myHeight );' skip */
      'return [ myWidth, myHeight ];' skip
      '~}' skip

      'function getScrollXY() ~{' skip
      'var scrOfX = 0, scrOfY = 0;' skip
      'if( typeof( window.pageYOffset ) == "number" ) ~{' skip
      '//Netscape compliant' skip
      'scrOfY = window.pageYOffset;' skip
      'scrOfX = window.pageXOffset;' skip
      '~} else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) ~{' skip
      '//DOM compliant' skip
      'scrOfY = document.body.scrollTop;' skip
      'scrOfX = document.body.scrollLeft;' skip
      '~} else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) ~{' skip
      '//IE6 standards compliant mode' skip
      'scrOfY = document.documentElement.scrollTop;' skip
      'scrOfX = document.documentElement.scrollLeft;' skip
      '~}' skip
/*       '//window.alert( 'Width = ' + scrOfX  +  '   Height = ' + scrOfY );' skip */
      'return [ scrOfX, scrOfY ];' skip
      '~}' skip
      
      '</script>' skip
    .




END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-ExportJScript) = 0 &THEN

PROCEDURE ip-ExportJScript :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/


    {&out} 
    '<script type="text/javascript" language="JavaScript">' skip
      'var manualTime = false;' skip

      ' function ChangeDuration(Indx) ' skip
      '~{' skip
      '  var tFA = "ff" + Indx + "hours"; ' skip
      '  var tFB = "ff" + Indx + "mins"; ' skip
      '  var tFC = "ff" + Indx + "startdate"; ' skip
      '  var tFD = "ff" + Indx + "enddate"; ' skip
      '  var tFE = Indx + "endhour"; ' skip
      '  var tFF = Indx + "endmin"; ' skip
      '  var tFG = Indx + "starthour"; ' skip
      '  var tFH = Indx + "startmin"; ' skip
      '  var tFX = "mainform" + (Indx < 10 ? "0" : "") + Indx  ; ' skip
      '  var tFZ = Indx + "manualTime"; ' skip
      '  var curHourDuration   = parseInt(document.getElementById(tFA).value,10) ' skip
      '  var curMinDuration    = parseInt(document.getElementById(tFB).value,10) ' skip
      '  var startDate         = parseInt(document.getElementById(tFC).value,10) ' skip
      '  var endDate           = parseInt(document.getElementById(tFD).value,10) ' skip
      '  var endHourOption     = parseInt(document.getElementById(tFE).value,10);' skip
      '  var endMinuteOption   = parseInt(document.getElementById(tFF).value,10);' skip
      '  var startHourOption   = parseInt(document.getElementById(tFG).value,10);' skip
      '  var startMinuteOption = parseInt(document.getElementById(tFH).value,10);' skip
      '  var startTime         =  internalTime(startHourOption,startMinuteOption) ; '  skip
      '  var endTime           =  internalTime(endHourOption,endMinuteOption) ; '  skip
      '  var durationTime      =  internalTime(curHourDuration,curMinDuration) ; '  skip

      '  document.forms[tFX].elements[tFB].value = (curMinDuration < 10 ? "0" : "") + curMinDuration ;' skip
      '  document.getElementById("throbber").src="/images/ajax/ajax-loaded-red.gif"; ' skip
      '  document.forms[tFX].elements[tFZ].checked = true; ' skip
      '  manualTime = true; ' skip   
/*       '  document.forms[tFX].elements[tFB].value = (curMinDuration < 10 ? "0" : "") + curMinDuration ;' skip                                                      */
/*       '  if (manualTime) return;  ' skip                                                                                                                          */
/*       '  if ( (endTime - startTime) != 0  || (endTime - startTime) != durationTime || !manualTime )' skip                                                         */
/*       '  ~{' skip                                                                                                                                                 */
/* /*       '     alert("The duration entered does not match with the Start and End time! ~\n ~\n                              Setting to Manual Time."); ' skip  */ */
/*       '     document.getElementById("throbber").src="/images/ajax/ajax-loaded-red.gif"; ' skip                                                                    */
/*       '     document.forms[tFX].elements[tFZ].checked = true; ' skip                                                                                              */
/*       '     manualTime = true; ' skip                                                                                                                             */
/*       '  ~}' skip                                                                                                                                                 */
      '~}' skip

      ' function PrePost(Indx) ' skip
      '~{' skip
      '  var tFA = "ff" + Indx + "hours"; ' skip
      '  var tFB = "ff" + Indx + "mins"; ' skip
      '  var tFC = "ff" + Indx + "startdate"; ' skip
      '  var tFD = "ff" + Indx + "enddate"; ' skip
      '  var tFE = Indx + "endhour"; ' skip
      '  var tFF = Indx + "endmin"; ' skip
      '  var tFG = Indx + "starthour"; ' skip
      '  var tFH = Indx + "startmin"; ' skip
      '  var tFX = "mainform" + (Indx < 10 ? "0" : "") + Indx  ; ' skip
      '  var tFZ = Indx + "manualTime"; ' skip
      '  var curHourDuration   = parseInt(document.getElementById(tFA).value,10) ' skip
      '  var curMinDuration    = parseInt(document.getElementById(tFB).value,10) ' skip
      '  var startDate         = parseInt(document.getElementById(tFC).value,10) ' skip
      '  var endDate           = parseInt(document.getElementById(tFD).value,10) ' skip
      '  var endHourOption     = parseInt(document.getElementById(tFE).value,10);' skip
      '  var endMinuteOption   = parseInt(document.getElementById(tFF).value,10);' skip
      '  var startHourOption   = parseInt(document.getElementById(tFG).value,10);' skip
      '  var startMinuteOption = parseInt(document.getElementById(tFH).value,10);' skip
      '  var startTime         =  internalTime(startHourOption,startMinuteOption) ; '  skip
      '  var endTime           =  internalTime(endHourOption,endMinuteOption) ; '  skip
      '  var durationTime      =  internalTime(curHourDuration,curMinDuration) ; '  SKIP
      '  document.forms[tFX].submit();  ' skip
      /*** 24/03/2015 - removed 
      '  if (  (endTime - startTime) != 0  && (endTime - startTime) != durationTime )' skip
      '  ~{' skip
      '     var answer = confirm("The duration entered does not match with the Start and End time! ~\n ~\n      Press Cancel if you want to update the times before posting"); ' skip
      '     if (answer) ~{ document.forms[tFX].submit();  ~} ' skip
      '     else  ~{ return false;  ~} ' skip
      '  ~}' skip
      '  else ~{ document.forms[tFX].submit();  ~} ' skip
      **/
      '~}' skip

      'function internalTime(piHours,piMins) ' skip
      '~{' skip
      '  return ( ( piHours * 60 ) * 60 ) + ( piMins * 60 ); ' skip
      '~}' skip.
    
    {&out} 
    '// --  Clock --' skip
      'var timerID = null;' skip
      'var timerRunning = false;' skip
      'var timerStart = null;' skip
      'var timeSet = null;' skip
      'var defaultTime = parseInt(' lc-DefaultTimeSet ',10);' skip
      'var timeSecondSet = parseInt(' lc-timeSecondSet ',10);' skip
      'var timeMinuteSet = parseInt(' lc-timeMinuteSet ',10);' skip
      'var timeHourSet =  ' string(integer(lc-timeHourSet)) ';' SKIP
      'var timerStartseconds = 0;' skip(2)
      
      'function manualTimeSet()~{' skip
      'manualTime = (manualTime == true) ? false : true;' skip
      'if (!manualTime) ~{document.getElementById("throbber").src="/images/ajax/ajax-loader-red.gif"~}' skip
      'else ~{document.getElementById("throbber").src="/images/ajax/ajax-loaded-red.gif"~}' skip
      '~}' skip

      'function stopclock(levelx)~{' skip
      'if(timerRunning)' skip
      'clearTimeout(timerID);' skip
      'timerRunning = false;' skip
      '~}' skip

      'function startclock(levelx)~{' skip
      'stopclock(levelx);' skip
      /*'timeHourSet = 0;' skip */
      
      'document.getElementById("clockface").innerHTML =  "00" +   ((defaultTime < 10) ? ":0" : ":") + defaultTime  + ":00" ' skip
      'var tF = "ff" + levelx + "mins";' skip
      'document.getElementById(tF).value = ((defaultTime < 10) ? "0" : "") + defaultTime ' skip
      'showtime(levelx);' skip
      '~}' skip

      'function showtime(levelx)~{' skip
      'var curMinuteOption;' skip
      'var curHourOption;' skip
      'var now = new Date()' skip
      'var hours = now.getHours()' skip
      'var minutes = now.getMinutes()' skip
      'var seconds = now.getSeconds()' skip
      'var millisec = now.getMilliseconds()' skip
      'var timeValue = "" +   hours' skip
      'var tFH = "ff" + levelx + "hours"' skip
      'var tFM = "ff" + levelx + "mins"' skip
      'var tFEH = levelx + "endhour"' skip
      'var tFEM = levelx + "endmin"'skip
      'timeSecondSet = timeSecondSet + 1' skip
      'if (!manualTime)' skip
      '~{' skip
      'timeValue  += ((minutes < 10) ? ":0" : ":") + minutes' skip
      'timeValue  += ((seconds < 10) ? ":0" : ":") + seconds' skip
      'curHourOption = document.getElementById(tFEH + ((hours == 0) ? "0" : "") + hours) ' skip
      'curHourOption.selected = true' skip
      'curMinuteOption = document.getElementById(tFEM + ((minutes < 10) ? "0" : "") + minutes)' skip
      'curMinuteOption.selected = true' skip
      'if ( timeSecondSet >= 60 ) ~{ timeSecondSet = 0 ; timeMinuteSet = timeMinuteSet + 1; ~}' skip
      'if ( timeMinuteSet >= 60 ) ' SKIP
      '~{ ' SKIP 
      '     timeMinuteSet = 0 ; ' SKIP
      '     timeHourSet = timeHourSet + 1; ' SKIP
      '~}' SKIP
      
      'if ( defaultTime <= timeMinuteSet || defaultTime == 0 || timeHourSet > 0)' skip
      '  ~{' skip
      '     document.getElementById(tFH).value = ((timeHourSet  < 10) ? "0" : "") + timeHourSet' skip
      '     document.getElementById(tFM).value  = ((timeMinuteSet < 10) ? "0" : "") + timeMinuteSet ' skip
      '     document.getElementById("clockface").innerHTML = ((timeHourSet < 10) ? "0" : "") + timeHourSet ' skip
      '       +   ((timeMinuteSet < 10) ? ":0" : ":") + timeMinuteSet  + ((timeSecondSet < 10) ? ":0" : ":") + timeSecondSet ' skip
      '  ~}'  skip
      '~}' SKIP
      'document.getElementById("timeHourSet").value = timeHourSet ;' skip 
      'document.getElementById("timeSecondSet").value = timeSecondSet' skip
      'document.getElementById("timeMinuteSet").value = timeMinuteSet' skip
      'timerRunning = true' skip
      'timerID = setTimeout("showtime(" + levelx + ")",1000)' skip
      '~}' skip
 
      '</script>' skip
    .


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
    DEFINE INPUT PARAMETER zx AS INTEGER NO-UNDO.

    {&out}
    '<br>' skip
    .

    {&out} htmlib-StartInputTable() skip.


    {&out} '<tr><td valign="top" align="right">'
        ( IF LOOKUP("activityby",lc-error-field,'|') > 0 AND li-error = zx
        THEN htmlib-SideLabelError("Activity By")
        ELSE htmlib-SideLabel("Activity By"))
    '</td>' skip
    .

    IF lc-mode = "ADD" THEN
        {&out} '<td valign="top" align="left">'
    htmlib-Select(STRING(zx) + "activityby",lc-list-assign,lc-list-assname,lc-activityby)
    '</td>'.
    else
    {&out} htmlib-TableField(html-encode(com-UserName(lc-activityby)),'left')
           skip.
    {&out} '</tr>' skip.


    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("activitytype",lc-error-field,'|') > 0 AND li-error = zx
        THEN htmlib-SideLabelError("Activity Type")
        ELSE htmlib-SideLabel("Activity Type"))
    '</td>' 
    '<td valign="top" align="left">'
    Format-Select-Activity(htmlib-Select(STRING(zx) + "activitytype",lc-list-actid,lc-list-activtype,lc-saved-activity), zx) skip
             '</td></tr>' skip. 


   
    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("actdate",lc-error-field,'|') > 0 AND li-error = zx
        THEN htmlib-SideLabelError("Date")
        ELSE htmlib-SideLabel("Date"))
    '</td>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<td valign="top" align="left">'
    htmlib-InputField(STRING(zx) + "actdate",10,lc-actdate) 
    htmlib-CalendarLink(STRING(zx) + "actdate")
    '</td>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-actdate),'left')
           skip.
    {&out} '</tr>' skip.

    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("startdate",lc-error-field,'|') > 0 AND li-error = zx
        THEN htmlib-SideLabelError("Start Date")
        ELSE htmlib-SideLabel("Start Date"))
    '</td>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<td valign="top" align="left">'
    htmlib-InputField(STRING(zx) + "startdate",10,lc-startdate) 
    htmlib-CalendarLink(STRING(zx) + "startdate")
    "&nbsp;@&nbsp;"
    htmlib-TimeSelect-By-Id(STRING(zx) + "starthour",lc-starthour,STRING(zx) + "startmin",lc-startmin)
    '</td>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-startdate),'left')
           skip.
    {&out} '</tr>' skip.

    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("enddate",lc-error-field,'|') > 0 AND li-error = zx
        THEN htmlib-SideLabelError("End Date")
        ELSE htmlib-SideLabel("End Date"))
    '</td>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<td valign="top" align="left">'
    REPLACE(htmlib-InputField(STRING(zx) + "enddate",10,lc-enddate),">"," disabled>") 
    REPLACE(htmlib-CalendarLink(STRING(zx) + "enddate"),">",' disabled>')  

    "&nbsp;@&nbsp;"
     
      
    REPLACE(htmlib-TimeSelect-By-Id(STRING(zx) + "endhour",lc-endhour,STRING(zx) + "endmin",lc-endmin),">"," disabled>") 
    '</td>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-enddate),'left')
           skip.
    {&out} '</tr>' skip.



    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("hours",lc-error-field,'|') > 0 AND li-error = zx
        THEN htmlib-SideLabelError("Duration (HH:MM)")
        ELSE htmlib-SideLabel("Duration (HH:MM)"))
    '</td>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<td valign="top" align="left">'
    Format-Select-Duration(htmlib-InputField(STRING(zx) + "hours",4,lc-hours), zx)
    ':'
    Format-Select-Duration(htmlib-InputField(STRING(zx) + "mins",2,lc-mins), zx)
    '</td>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-hours),'left')
           skip.
    {&out} '</tr>' skip.





    IF lc-mode = "add" THEN 
    DO:
    
        {&out} '<tr><td valign="top" align="right">' 
            (IF LOOKUP("manualTime",lc-error-field,'|') > 0 AND li-error = zx
            THEN htmlib-SideLabelError("Manual Time Entry?")
            ELSE htmlib-SideLabel("Manual Time Entry?"))
        '</td>'.
        {&out} '<td valign="top" align="left">'
            '<input class="inputfield" type="checkbox" onclick="javascript:manualTimeSet()" id="' + string(zx) 
            + 'manualTime" name="' + string(zx) + 'manualTime"  ' lc-manChecked ' >' 
        '</td>' skip.
    END.





    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("sitevisit",lc-error-field,'|') > 0 AND li-error = zx
        THEN htmlib-SideLabelError("Site Visit?")
        ELSE htmlib-SideLabel("Site Visit?"))
    '</td>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<td valign="top" align="left">'
    htmlib-CheckBox(STRING(zx) + "sitevisit", IF lc-sitevisit = 'on'
        THEN TRUE ELSE FALSE) 
    '</td>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-sitevisit = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</tr>' skip.
    /**/

    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("customerview",lc-error-field,'|') > 0 AND li-error = zx
        THEN htmlib-SideLabelError("Customer View?")
        ELSE htmlib-SideLabel("Customer View?"))
    '</td>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<td valign="top" align="left">'
    htmlib-CheckBox(STRING(zx) + "customerview", IF lc-customerview = 'on'
        THEN TRUE ELSE FALSE) 
    '</td>' skip.
    else 
    {&out} htmlib-TableField(html-encode(if lc-customerview = 'on'
                                         then 'yes' else 'no'),'left')
           skip.
    
    {&out} '</tr>' skip.


    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("actdescription",lc-error-field,'|') > 0 AND li-error = zx
        THEN htmlib-SideLabelError("Activity Description")
        ELSE htmlib-SideLabel("Activity Description"))
    '</td><td valign="top" align="left">'
    htmlib-ThisInputField(STRING(zx) + "actdescription",40,lc-actdescription) 
    '</td></tr>' skip.



    {&out} '<tr><td valign="top" align="right">' 
    htmlib-SideLabel("Charge for Activity?")
    '</td><td valign="top" align="left">'
    htmlib-CheckBox(STRING(zx) + "billingcharge", IF lc-billing-charge = 'on'
        THEN TRUE ELSE FALSE)
    '</td></tr>' skip.



    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("description",lc-error-field,'|') > 0 AND li-error = zx
        THEN htmlib-SideLabelError("Description")
        ELSE htmlib-SideLabel("Description"))
    '</td>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<td valign="top" align="left">'
    htmlib-InputField(STRING(zx) + "description",40,lc-description) 
    '</td>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-description),'left')
           skip.
    {&out} '</tr>' skip.


    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("notes",lc-error-field,'|') > 0 AND li-error = zx
        THEN htmlib-SideLabelError("Note")
        ELSE htmlib-SideLabel("Note"))
    '</td>' skip
           '<td valign="top" align="left">'
           htmlib-TextArea(string(zx) + "notes",lc-notes,6,40)
          '</td></tr>' skip
           skip.

    {&out} htmlib-EndTable() skip.

    IF lc-error-msg <> "" AND li-error = zx THEN
    DO:
        {&out} '<br><br><center>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</center>' skip.
    END.
    
    IF lc-submit-label <> "" THEN
    DO:
        {&out} '<center>' Return-Submit-Button("submitform",lc-submit-label,"PrePost(" + string(zx) + ")") 
        '</center>' skip.
    END.

    {&out}
    '<br>' skip
    .


    IF NOT CAN-DO("view,delete",lc-mode) AND zx > 0 THEN
    DO:
        {&out}
        htmlib-CalendarScript(STRING(zx) + "actdate") skip
            htmlib-CalendarScript(string(zx) + "startdate") SKIP
        /*
        htmlib-CalendarScript(string(zx) + "enddate") skip
        */.
           
    END.

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
    DEFINE VARIABLE li-int    AS INTEGER NO-UNDO.
    DEFINE VARIABLE ld-startd AS DATE    NO-UNDO.
    DEFINE VARIABLE ld-endd   AS DATE    NO-UNDO.
    DEFINE VARIABLE li-startt AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-endt   AS INTEGER NO-UNDO.
    
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

    /**  
    ASSIGN 
        li-int = int(lc-hours + lc-mins) no-error.
    IF NOT ERROR-STATUS:ERROR 
        AND (li-endt > li-startt AND li-int = 0 )
        THEN RUN htmlib-AddErrorMessage(
            'hours', 
            'You must enter the duration',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    **/
    
    IF lc-actdescription = "" 
        THEN RUN htmlib-AddErrorMessage(
            'actdescription', 
            'You must enter the activity description',
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

    DEFINE BUFFER issue       FOR issue.
    DEFINE BUFFER b-query     FOR issAction.
    DEFINE BUFFER IssActivity FOR IssActivity.

    DEFINE VARIABLE ldt LIKE issue.lastactivity NO-UNDO.
    DEFINE VARIABLE LC  AS CHARACTER FORMAT 'x(20)' NO-UNDO.

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
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-old-duration     LIKE IssActivity.Duration NO-UNDO.
    DEFINE VARIABLE li-amount           LIKE IssActivity.Duration NO-UNDO.
    DEFINE VARIABLE li-duration         AS INTEGER.
    DEFINE VARIABLE li-count            AS INTEGER.
    DEFINE VARIABLE lc-main-title       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-acc-title-left   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-acc-title-right  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-acc-link-label   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-acc-submit-label AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-opener           AS INTEGER   NO-UNDO.
    DEFINE VARIABLE zx                  AS INTEGER   NO-UNDO.

    ASSIGN 
        lc-issue-rowid  = get-value("issuerowid")
        lc-rowid        = get-value("rowid")
        lc-mode         = get-value("mode")
        lc-action-rowid = get-value("actionrowid")
        lc-action-index = get-value("actionindex").


    RUN com-GetActivityType ( lc-global-company , OUTPUT lc-list-actid, OUTPUT lc-list-activtype, OUTPUT lc-list-activdesc, OUTPUT lc-list-activtime ).

    IF lc-mode = 'add' OR lc-mode ='update' OR lc-mode ='delete' THEN RUN process-web-request2(lc-action-index, OUTPUT li-error).

    ASSIGN
        lc-title          = 'Update'
        lc-link-label     = 'Cancel update'
        lc-submit-label   = 'Update Activity'
        lc-timeSecondSet  = "1"
        lc-timeMinuteSet  = "0" /*    entry(1,lc-list-activtime,"|")  */
        lc-DefaultTimeSet = ENTRY(1,lc-list-activtime,"|")
        lc-TimeHourSet = "0"
        lc-saved-activity = "0".


    FIND issue
        WHERE ROWID(issue) = to-rowid(lc-issue-rowid) NO-LOCK.
    
    FIND customer WHERE Customer.CompanyCode = Issue.CompanyCode
        AND Customer.AccountNumber = Issue.AccountNumber
        NO-LOCK NO-ERROR.

    
    RUN com-GetAssignIssue  ( lc-global-company , OUTPUT lc-list-assign , OUTPUT lc-list-assname ).

    ASSIGN 
        lc-main-title = " Activities for Issue " + string(issue.IssueNumber).

    RUN outputHeader.
    
    {&out} htmlib-OpenHeader(lc-main-title) skip.

    RUN ip-ExportAccordion.

    RUN ip-ExportJScript.

    {&out} htmlib-CloseHeader("checkLoad()") skip.

    {&out}
    htmlib-ProgramTitle(lc-main-title) skip.
    
    {&out}
    '<div id="AccordionContainer" class="AccordionContainer">' skip.


    FIND FIRST issAction NO-LOCK WHERE ROWID(issAction) = to-rowid(lc-action-rowid) NO-ERROR.


    FIND WebAction 
        WHERE WebAction.ActionID = issAction.ActionID
        NO-LOCK NO-ERROR.
   
    
    IF NOT AVAILABLE WebAction
    THEN FIND FIRST WebAction WHERE WebAction.CompanyCode = IssAction.CompanyCode NO-LOCK NO-ERROR.

    ASSIGN 
        li-duration = 0.

    FOR EACH IssActivity NO-LOCK
        WHERE issActivity.CompanyCode = issue.CompanyCode
        AND issActivity.IssueNumber = issue.IssueNumber
        AND IssActivity.IssActionId = issAction.IssActionID
        BY issActivity.ActDate 
        BY IssActivity.CreateDate 
        BY issActivity.CreateTime :

        ASSIGN
            li-duration = li-duration + IssActivity.Duration
            li-count    = li-count + 1.

        ASSIGN
            lc-acc-title-left  = issActivity.Description 
            lc-acc-title-right = /*"(" + string(issActivity.Duration,"HH:MM") + ")" */
                                 "(" + com-TimeToString(issActivity.Duration) + ")"
            lc-activityby      = issActivity.ActivityBy 
            lc-actdate         = STRING(issActivity.ActDate )
            lc-StartDate       = STRING(issActivity.StartDate )
            lc-StartHour       = STRING(int(substr(STRING(issActivity.StartTime,"hh:mm"),1,2)))
            lc-StartMin        = substr(STRING(issActivity.StartTime,"hh:mm"),4,2)
            lc-endDate         = STRING(issActivity.EndDate )
            lc-endHour         = STRING(int(substr(STRING(issActivity.endTime,"hh:mm"),1,2)))
            lc-endMin          = substr(STRING(issActivity.endTime,"hh:mm"),4,2)
            lc-sitevisit       = IF issActivity.SiteVisit THEN "on" ELSE ""
            lc-customerview    = IF issActivity.CustomerView THEN "on" ELSE ""  
            lc-description     = issActivity.Description   
            lc-notes           = issActivity.notes 
            lc-rowid           = STRING(ROWID(issActivity))
            lc-action-rowid    = STRING(ROWID(issAction))
            lc-actdescription  = issActivity.ActDescription   
            lc-activitytype    = IF issActivity.typeid <> 0 THEN STRING(issActivity.typeid) ELSE STRING(Get-Activity( issActivity.ActDescription ))
            lc-billing-charge  = IF issActivity.Billable THEN "on" ELSE ""
            lc-saved-activity  = lc-activitytype
            lc-manChecked      = "on"
            zx                 = zx + 1 .
        
        IF issActivity.Duration > 0 THEN
        DO:
            RUN com-SplitTime ( issActivity.Duration, OUTPUT li-hours, OUTPUT li-mins ).
            ASSIGN 
                lc-mins  = STRING(li-mins,"99")
                lc-hours = STRING(li-hours,"99").
        END.

        {&out}
        '<div onclick="runAccordion(' zx ');">' skip
          '  <div class="AccordionTitle" onselectstart="return false;">' skip
          '<span style="float:left;margin-left:20px;">'  lc-acc-title-left  '</span><span style="float:right;margin-right:20px;">' lc-acc-title-right '</span>' skip
          '  </div>' skip
          '</div>' skip
          '<div id="Accordion' zx 'Content" class="AccordionContent">' skip
          '  <div id="Accordion' zx 'Content_" class="AccordionContent_">' skip
           htmlib-StartForm("mainform" + string(zx,"99") ,"post", 
                            selfurl 
                            + "?mode=update"
                            + "&issuerowid=" + lc-issue-rowid 
                            + "&actionrowid=" + lc-action-rowid 
                            + "&actionindex=" + string(zx)
                            + "&rowid=" + lc-rowid
                            + "&timeSecondSet=" + lc-timeSecondSet
                            ).
        /* This is setup IP_PAGE */
        RUN ip-Page(zx) .

        {&out} 
        htmlib-Hidden(STRING(zx) + "savedactivetype",lc-saved-activity) skip
            htmlib-Hidden("actDesc",lc-list-activdesc) skip     
            htmlib-Hidden("actTime",lc-list-activtime) skip 
            htmlib-Hidden("actID",lc-list-actid) skip 
            htmlib-EndForm() skip.
       
        {&out}
        ' </div>' skip
          '</div>' skip.

    END.  /* of for each */

    IF lc-mode = "insert" OR li-error > zx THEN
    DO:

        IF lc-mode = "insert" THEN
            ASSIGN lc-title          = "Add"
                lc-link-label     = "Cancel addition"
                lc-submit-label   = "Add Activity"
                lc-mode           = "add" 
                lc-activityby     = lc-global-user
                lc-actdate        = STRING(TODAY,"99/99/9999")
                lc-customerview   = lc-customerview
                lc-StartDate      = STRING(TODAY,"99/99/9999")
                lc-StartHour      = STRING(int(substr(STRING(TIME,"hh:mm"),1,2)))
                lc-StartMin       = substr(STRING(TIME,"hh:mm"),4,2)
                lc-endDate        = STRING(TODAY,"99/99/9999")        
                lc-endhour        = lc-StartHour    
                lc-endmin         = lc-StartMin
                lc-DefaultTimeSet = ENTRY(1,lc-list-activtime,"|") 
                lc-hours          = "0"
                lc-mins           = lc-DefaultTimeSet  /* if integer(lc-DefaultTimeSet) < 10 then "0" + lc-DefaultTimeSet else  */
                lc-secs           = "0"                              
                lc-sitevisit      = lc-sitevisit
                lc-description    = ""   
                lc-actdescription = ENTRY(1,lc-list-activdesc,"|")  
                lc-notes          = ""
                lc-manChecked     = ""
                lc-billing-charge = IF issue.Billable THEN "on" ELSE ""
                lc-timeSecondSet  = "1"  
                lc-timeMinuteSet  = "0" 
                lc-TimeHourSet    = "0"
                lc-saved-activity = "0"
                zx                = zx + 1
                li-opener         = 2
                lc-customerview   = "on" .
  


        ELSE
            ASSIGN lc-title          = "Add"
                lc-link-label     = "Cancel addition"
                lc-submit-label   = "Add Activity"
                lc-mode           = "add" 
                lc-activityby     = lc-save-activityby       
                lc-actdate        = lc-save-actdate          
                lc-customerview   = lc-save-customerview     
                lc-StartDate      = lc-save-StartDate        
                lc-starthour      = lc-save-starthour        
                lc-startmin       = lc-save-startmin         
                lc-endDate        = lc-save-endDate          
                lc-endhour        = lc-save-endhour          
                lc-endmin         = lc-save-endmin           
                lc-hours          = lc-save-hours            
                lc-mins           = lc-save-mins             
                lc-secs           = lc-save-secs             
                lc-sitevisit      = lc-save-sitevisit        
                lc-description    = lc-save-description      
                lc-notes          = lc-save-notes   
                lc-saved-activity = "0"
                lc-activitytype   = lc-saved-activity   
                lc-manChecked     = lc-save-manChecked       
                lc-actdescription = lc-save-actdescription   
                lc-billing-charge = lc-save-billing-charge   
                lc-timeSecondSet  = lc-save-timeSecondSet    
                lc-timeMinuteSet  = lc-save-timeMinuteSet
                lc-timeHourSet    = lc-save-timeHourSet
                lc-DefaultTimeSet = lc-save-DefaultTimeSet   
                zx                = zx + 1
                li-opener         = 2 .                 

        {&out}
        '<div onclick="runAccordion(' zx ');">' skip
          ' <div class="AccordionTitle" onselectstart="return false;">' skip
          'New Activity' skip
          ' </div>' skip
          '</div>' skip
          '<div id="Accordion' zx 'Content" class="AccordionContent">' skip
          ' <div id="Accordion' zx 'Content_" class="AccordionContent_">' skip
           htmlib-StartForm("mainform" + string(zx,"99") ,"post", 
                            selfurl
                            + "?mode=add"
                            + "&issuerowid=" + lc-issue-rowid 
                            + "&actionrowid=" + lc-action-rowid 
                            + "&actionindex=" + string(zx)
                            + "&timeSecondSet=2"  
                            ).
 
        {&out}
        '<div align="right">' skip
         '<span id="clockface" name="clockface" class="clockface">' skip
         '0:00:00' skip
         '</span><img id="throbber" src="/images/ajax/ajax-loader-red.gif"></div>' skip
         '<tr><td valign="top"><fieldset><legend>Main Issue Entry</legend>' skip
        .

        /* This is create IP_PAGE  */

        RUN ip-Page(zx) .


        {&out} 
        htmlib-Hidden("timeSecondSet",lc-timeSecondSet) skip
            htmlib-Hidden("timeMinuteSet",lc-timeMinuteSet) SKIP
            htmlib-Hidden("timeHourSet",lc-timeHourSet) skip
            htmlib-Hidden("defaultTime",lc-DefaultTimeSet) skip
            htmlib-Hidden(string(zx) + "savedactivetype",lc-saved-activity) skip   
            htmlib-Hidden("actDesc",lc-list-activdesc) skip     
            htmlib-Hidden("actTime",lc-list-activtime) skip 
            htmlib-Hidden("actID",lc-list-actid) skip 
            htmlib-EndForm() skip 
          ' </div>' skip
          '</div>' skip.
    END.
   
    {&out}
    '<! -- END OF CONTAINER -->' skip
      '</div>' skip
    .
  
    {&out}
    '<br><span class="inform"><div class="programtitle"> ' skip
      '<input class="submitbutton" type="button"' skip
      ' onclick="location.href=~'' appurl '/iss/activityupdmain.p?mode=insert&issuerowid=' lc-issue-rowid '&rowid=' lc-rowid
      '&actionrowid='  lc-action-rowid  '~'"' skip
      ' value="Create Activity" />' skip
      '<input class="submitbutton" type="button" onclick="window.close()"' skip
      ' value="Close" />' skip
      '</div></span>' skip.



    {&out} '<script type="text/javascript">' skip.
    IF lc-manChecked = "on" THEN  {&out} 'manualTime = true;' skip.
   else if lc-mode = "add" then   {&out} 'startclock(' string(zx) ');' skip.
    {&out} '</script>' skip.
    
    ASSIGN 
        li-opener = li-opener + zx .

    {&out}
      
    htmlib-Footer() skip.
      
    {&out}
    '<script type="text/javascript">' skip
      'runAccordion(' if li-error > 0 then li-error else zx ');' skip

      'function fitWindow()' skip
      '~{' skip
      'window.resizeBy(0, '  li-opener  ' * 20);' skip
      '~}' skip
      '</script>' skip.  
     

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-process-web-request2) = 0 &THEN

PROCEDURE process-web-request2 :
    /*------------------------------------------------------------------------------
      Purpose:     Process the web request.
      Parameters:  <none>
      emails:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pi-action-index AS INTEGER   NO-UNDO.
    DEFINE OUTPUT PARAMETER pi-error        AS INTEGER   NO-UNDO.
  
    DEFINE VARIABLE li-old-duration LIKE IssActivity.Duration NO-UNDO.
    DEFINE VARIABLE li-amount       LIKE IssActivity.Duration NO-UNDO.
    DEFINE VARIABLE pc-action-index AS CHARACTER NO-UNDO.

    ASSIGN 
        pc-action-index = STRING(pi-action-index).


    IF request_method = "POST" THEN
    DO:
        IF lc-mode <> "delete" THEN
        DO:                           
            ASSIGN 
                lc-save-activityby     = get-value(pc-action-index + "activityby")
                lc-save-actdate        = get-value(pc-action-index + "actdate")
                lc-save-customerview   = get-value(pc-action-index + "customerview")
                lc-save-StartDate      = get-value(pc-action-index + "startdate")
                lc-save-starthour      = get-value(pc-action-index + "starthour")
                lc-save-startmin       = get-value(pc-action-index + "startmin")
                lc-save-endDate        = get-value(pc-action-index + "enddate")
                lc-save-endhour        = get-value(pc-action-index + "endhour")
                lc-save-endmin         = get-value(pc-action-index + "endmin")
                lc-save-hours          = get-value(pc-action-index + "hours")
                lc-save-mins           = get-value(pc-action-index + "mins")
                lc-save-manChecked     = get-value(pc-action-index + "manualTime")
                lc-save-manChecked     = IF lc-save-manChecked =  "on" THEN "checked" ELSE ""
                lc-save-secs           = get-value(pc-action-index + "secs")
                lc-save-sitevisit      = get-value(pc-action-index + "sitevisit")
                lc-save-description    = get-value(pc-action-index + "description")
                lc-save-notes          = get-value(pc-action-index + "notes")
                lc-saved-activity      = get-value(pc-action-index + "activitytype")
                lc-save-actdescription = get-value(pc-action-index + "actdescription")
                lc-save-billing-charge = get-value(pc-action-index + "billingcharge")
                lc-save-timeSecondSet  = get-value("timeSecondSet")
                lc-save-timeMinuteSet  = get-value("timeMinuteSet")
                lc-save-timeHourSet    = get-value("timeHourSet")
                lc-save-DefaultTimeSet = get-value("defaultTime")
                . 
          
            
            ASSIGN 
                lc-activityby     = lc-save-activityby     
                lc-actdate        = lc-save-actdate        
                lc-customerview   = lc-save-customerview   
                lc-StartDate      = lc-save-StartDate      
                lc-starthour      = lc-save-starthour      
                lc-startmin       = lc-save-startmin       
                lc-endDate        = lc-save-endDate        
                lc-endhour        = lc-save-endhour        
                lc-endmin         = lc-save-endmin
                lc-hours          = lc-save-hours          
                lc-mins           = lc-save-mins           
                lc-secs           = lc-save-secs           
                lc-sitevisit      = lc-save-sitevisit      
                lc-description    = lc-save-description    
                lc-notes          = lc-save-notes          
                lc-activitytype   = lc-saved-activity
                lc-manChecked     = lc-save-manChecked     
                lc-actdescription = lc-save-actdescription 
                lc-billing-charge = lc-save-billing-charge 
                lc-timeSecondSet  = lc-save-timeSecondSet  
                lc-timeMinuteSet  = lc-save-timeMinuteSet  
                lc-timeHourSet    = lc-save-timeHourSet  
                lc-DefaultTimeSet = lc-save-DefaultTimeSet 
                .
           
             
          
            FIND issue WHERE ROWID(issue) = to-rowid(lc-issue-rowid) NO-LOCK.
            FIND customer WHERE Customer.CompanyCode = Issue.CompanyCode
                AND Customer.AccountNumber = Issue.AccountNumber
                NO-LOCK NO-ERROR.
            FIND IssAction WHERE ROWID(IssAction) = to-rowid(lc-action-rowid) NO-LOCK.
            FIND WebAction WHERE WebAction.ActionID = IssAction.ActionID NO-LOCK NO-ERROR. 
            RUN com-GetInternalUser ( lc-global-company , OUTPUT lc-list-assign , OUTPUT lc-list-assname ).

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
                        b-table.notes          = lc-notes
                        b-table.description    = lc-description
                        b-table.Actdescription = lc-actdescription
                        b-table.billable       = lc-billing-charge = "on"
                        b-table.ActDate        = DATE(lc-ActDate)
                        b-table.customerview   = lc-customerview = "on"
                        b-table.ContractType   = Issue.ContractType 
                        b-table.SiteVisit      = lc-SiteVisit = "on"
                        b-table.TypeID         = int(lc-activitytype)
                        .   
                    ASSIGN
                        b-table.activityType = com-GetActivityByType(lc-global-company,b-table.TypeID).
                                             . 
                    
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
                    ELSE 
                    DO:
                        ASSIGN 
                            b-table.StartDate = ?
                            b-table.StartTime = 0.
                    END.
                   
                    ASSIGN 
                        b-table.Duration = ( ( int(lc-hours) * 60 ) * 60 ) + 
                        ( int(lc-mins) * 60 ).

                    RUN com-EndTimeCalc
                        (
                        b-table.StartDate,
                        b-table.StartTime,
                        b-table.Duration,
                        OUTPUT b-table.EndDate,
                        OUTPUT b-table.EndTime
                        ).
        
                    IF Issue.Ticket THEN
                    DO:
                        ASSIGN 
                            li-amount = b-table.Duration - li-old-duration.
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
                                tt-ticket.Reference     = b-table.description
                                tt-ticket.TickID        = ?
                                tt-ticket.TxnDate       = b-table.ActDate
                                tt-ticket.TxnTime       = TIME
                                tt-ticket.TxnType       = "ACT"
                                tt-ticket.IssActivityID = b-table.IssActivityID.
                            RUN tlib-PostTicket.
                        END.
                    END.
                END.
            END. 
            ELSE 
            DO:
                pi-error = pi-action-index.
                RETURN.
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
                'var ParentWindow = opener' skip
                'ParentWindow.actionCreated()' skip

                '</script>' skip
                '<body><h1>ActionUpdated</h1></body></html>'.
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
                lc-notes          = b-table.notes
                lc-description    = b-table.description
                lc-activityby     = b-table.ActivityBy
                lc-actdate        = STRING(b-table.ActDate,"99/99/9999")
                lc-customerview   = IF b-table.CustomerView THEN "on" ELSE ""
                lc-sitevisit      = IF b-table.SiteVisit THEN "on" ELSE ""
                lc-actdescription = b-table.actdescription
                lc-billing-charge = IF b-table.billable THEN "on" ELSE ""
                /*                                                      */
                .
            IF b-table.Duration > 0 THEN
            DO:
                RUN com-SplitTime ( b-table.Duration, OUTPUT li-hours, OUTPUT li-mins ).
                IF li-hours > 0
                    THEN ASSIGN lc-hours = STRING(li-hours).
                IF li-mins > 0 
                    THEN ASSIGN lc-mins = STRING(li-mins).

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
            lc-activityby   = lc-global-user
            lc-actdate      = STRING(TODAY,"99/99/9999")
            lc-customerview = "on".
    END.

END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-Format-Select-Activity) = 0 &THEN

FUNCTION Format-Select-Activity RETURNS CHARACTER
    ( pc-htm AS CHARACTER, pc-index AS INTEGER  ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

    lc-htm = REPLACE(pc-htm,'<select',
        '<select onChange="ChangeActivityType(' + string(pc-index) + ')"'). 


    RETURN lc-htm.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Select-Duration) = 0 &THEN

FUNCTION Format-Select-Duration RETURNS CHARACTER
    ( pc-htm AS CHARACTER , pc-idx AS INTEGER  ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

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
    DEFINE VARIABLE aa AS INTEGER NO-UNDO.
    aa = INTEGER( ENTRY( LOOKUP(  pc-inp , lc-list-activdesc , "|" ),lc-list-actid , "|" ) ) NO-ERROR. 
    IF aa = 0 THEN aa = INTEGER( ENTRY( NUM-ENTRIES(  lc-list-actid , "|" ),lc-list-actid , "|" ) ). 
    RETURN aa.   /* Function return value. */

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

