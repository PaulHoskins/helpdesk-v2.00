/***********************************************************************

    Program:        time/diaryframe.p
    
    Purpose:        Hold the diary...
    
    Notes:
    
    
    When        Who         What
    01/09/2010  DJS      Initial
     
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */


/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-mess   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid        AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-max-lines    AS INTEGER   INITIAL 12 NO-UNDO.
DEFINE VARIABLE lr-first-row    AS ROWID     NO-UNDO.
DEFINE VARIABLE lr-last-row     AS ROWID     NO-UNDO.
DEFINE VARIABLE lc-mainText     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-timeText     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-innerText    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sliderText   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-otherText    AS CHARACTER NO-UNDO.
DEFINE VARIABLE timeSPixels     AS CHARACTER NO-UNDO.
DEFINE VARIABLE timeFinish      AS DECIMAL   NO-UNDO.
DEFINE VARIABLE timeFPixels     AS CHARACTER NO-UNDO.
DEFINE VARIABLE daysIssues      AS INTEGER   NO-UNDO.
DEFINE VARIABLE issueWidth      AS INTEGER   NO-UNDO.
DEFINE VARIABLE issueLeft       AS INTEGER   NO-UNDO.
DEFINE VARIABLE timeStart       AS DECIMAL   NO-UNDO.
DEFINE VARIABLE timeEnd         AS DECIMAL   NO-UNDO.
DEFINE VARIABLE offSetCol       AS INTEGER   NO-UNDO.
DEFINE VARIABLE offSetWidth     AS INTEGER   NO-UNDO.
DEFINE VARIABLE offRowid        AS ROWID     NO-UNDO. 
DEFINE VARIABLE p-cx            AS CHARACTER INITIAL "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40" NO-UNDO.
DEFINE VARIABLE p-vx            AS INTEGER   NO-UNDO.
DEFINE VARIABLE p-vz            AS INTEGER   NO-UNDO.
DEFINE VARIABLE p-zx            AS INTEGER   NO-UNDO. 
DEFINE VARIABLE colWheel        AS CHARACTER NO-UNDO.


/* WORKING VARS */
DEFINE VARIABLE vx              AS INTEGER   NO-UNDO.
DEFINE VARIABLE yx              AS INTEGER   NO-UNDO.
DEFINE VARIABLE zx              AS INTEGER   NO-UNDO.
DEFINE VARIABLE mx              AS INTEGER   NO-UNDO.
DEFINE VARIABLE cx              AS INTEGER   NO-UNDO.
DEFINE VARIABLE AMPM            AS CHARACTER FORMAT "xx" EXTENT 2 INITIAL ["AM","PM"] NO-UNDO.
DEFINE VARIABLE ap              AS INTEGER   NO-UNDO.
DEFINE VARIABLE dayDate         AS DATE      NO-UNDO.
DEFINE VARIABLE bubbleNo        AS INTEGER   INITIAL 1 NO-UNDO.
DEFINE VARIABLE dayWidth        AS CHARACTER NO-UNDO.
DEFINE VARIABLE currentDay      AS DATE      NO-UNDO.  
DEFINE VARIABLE viewerDay       AS DATE      NO-UNDO.
DEFINE VARIABLE dayDesc         AS CHARACTER NO-UNDO.
DEFINE VARIABLE dayNum          AS INTEGER   NO-UNDO.
DEFINE VARIABLE dayList         AS CHARACTER FORMAT "x(9)" INITIAL " Sunday , Monday , Tuesday , Wednesday , Thursday , Friday , Saturday ".
DEFINE VARIABLE dayRange        AS INTEGER   NO-UNDO.
DEFINE VARIABLE hourFrom        AS INTEGER   NO-UNDO.
DEFINE VARIABLE hourTo          AS INTEGER   NO-UNDO.
DEFINE VARIABLE coreHourFrom    AS INTEGER   NO-UNDO.
DEFINE VARIABLE coreHourTo      AS INTEGER   NO-UNDO.
DEFINE VARIABLE incWeekend      AS LOG       NO-UNDO.
DEFINE VARIABLE userList        AS CHARACTER NO-UNDO.
DEFINE VARIABLE saveSettings    AS LOG       NO-UNDO.
DEFINE VARIABLE viewShowY       AS INTEGER   NO-UNDO.
DEFINE VARIABLE viewshowX       AS INTEGER   NO-UNDO.

/* PARAM VARS */
DEFINE VARIABLE lc-lodate       AS CHARACTER NO-UNDO. 
DEFINE VARIABLE lc-hidate       AS CHARACTER NO-UNDO. 
DEFINE VARIABLE lc-dispDate     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-dateDate     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-viewerDay    AS CHARACTER NO-UNDO. 
DEFINE VARIABLE lc-dayRange     AS CHARACTER NO-UNDO. 
DEFINE VARIABLE lc-coreHourFrom AS CHARACTER NO-UNDO. 
DEFINE VARIABLE lc-coreHourTo   AS CHARACTER NO-UNDO. 
DEFINE VARIABLE lc-hourFrom     AS CHARACTER NO-UNDO. 
DEFINE VARIABLE lc-hourTo       AS CHARACTER NO-UNDO. 
DEFINE VARIABLE lc-incWeekend   AS CHARACTER NO-UNDO. 
DEFINE VARIABLE lc-mode         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-userList     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-saveSettings AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-blockheight  AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-blockheight  AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-offsetheight AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-blockwidth   AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-viewShowY    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-viewshowX    AS CHARACTER NO-UNDO.

/*  TABLES  */

DEFINE TEMP-TABLE DE LIKE DiaryEvents
    FIELD idRow      AS ROWID
    FIELD eventID    AS CHARACTER FORMAT "xx"
    FIELD overLap    AS CHARACTER FORMAT "x(9)" 
    FIELD comment    AS CHARACTER
    FIELD columnID   AS INTEGER   FORMAT "z9"
    FIELD issueLeft  AS INTEGER
    FIELD issueWidth AS INTEGER.

DEFINE BUFFER bDE          FOR DE.
DEFINE BUFFER bbDE         FOR DE.
DEFINE BUFFER bDiaryEvents FOR DiaryEvents.
DEFINE BUFFER b-query      FOR DiaryEvents.
DEFINE BUFFER b-search     FOR DiaryEvents.
DEFINE QUERY q               FOR b-query SCROLLING.

DEFINE TEMP-TABLE DDEE LIKE DiaryEvents.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-dateFormat) = 0 &THEN

FUNCTION dateFormat RETURNS CHARACTER
    ( params AS DATE )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-fnText) = 0 &THEN

FUNCTION fnText RETURNS CHARACTER
    ( pf-knbid AS DECIMAL,
    pi-count AS INTEGER )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Select-DayDate) = 0 &THEN

FUNCTION Format-Select-DayDate RETURNS CHARACTER
    ( pc-htm AS CHARACTER  )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-timeFormat) = 0 &THEN

FUNCTION timeFormat RETURNS CHARACTER
    (param1 AS INTEGER) FORWARD.


&ENDIF


/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 4.81
         WIDTH              = 37.14.
/* END WINDOW DEFINITION */
                                                                        */

/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}
{lib/htmlib.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */

{lib/checkloggedin.i}

IF CAN-FIND(FIRST DiaryParams NO-LOCK                                    
    WHERE DiaryParams.CompanyCode = lc-global-company           
    AND   DiaryParams.LoginID     = lc-global-user) 
    THEN  FIND FIRST DiaryParams NO-LOCK 
        WHERE DiaryParams.CompanyCode = lc-global-company 
        AND   DiaryParams.LoginID     = lc-global-user NO-ERROR.
ELSE  FIND FIRST DiaryParams NO-LOCK 
        WHERE DiaryParams.CompanyCode = lc-global-company 
        AND   DiaryParams.LoginID     = "system" NO-ERROR.


ASSIGN
    lc-mode             = get-value("mode")
    lc-viewerDay        = get-value("viewerDay")
    lc-dayRange         = get-value("dayRange")
    lc-userList         = get-value("userList")
    lc-coreHourFrom     = get-value("coreHourFrom")
    lc-coreHourTo       = get-value("coreHourTo")
    lc-hourFrom         = get-value("hourFrom")
    lc-hourTo           = get-value("hourTo")
    lc-incWeekend       = get-value("incWeekend")
    lc-viewShowY        = get-value("viewShowY")
    lc-viewShowX        = get-value("viewShowX")
    lc-saveSettings     = get-value("saveSettings").

/*  output to "C:\temp\djs2.txt" append.                 */
/*  put unformatted                                      */
/*  "LoginID           "    DiaryParams.LoginID skip     */
/*  "lc-mode           "    lc-mode             skip     */
/*  "lc-viewerDay      "    lc-viewerDay        skip     */
/*  "lc-dayRange       "    lc-dayRange         skip     */
/*  "lc-coreHourFrom   "    lc-coreHourFrom     skip     */
/*  "lc-coreHourTo     "    lc-coreHourTo       skip     */
/*  "lc-hourFrom       "    lc-hourFrom         skip     */
/*  "lc-hourTo         "    lc-hourTo           skip     */
/*  "lc-incWeekend     "    lc-incWeekend       skip     */
/*  "lc-viewShowY      "    lc-viewShowY        skip     */
/*  "lc-viewShowX      "    lc-viewShowX        skip     */
/*  "lc-saveSettings   "    lc-saveSettings     skip     */
/*  "lc-userList       "    lc-userList         skip(2). */
/*  output close.                                        */


IF lc-mode = "refresh" THEN
    ASSIGN
        viewerDay       = DATE(lc-viewerDay)
        lc-mode         = "refresh"
        dayRange        = INTEGER(lc-dayRange)
        coreHourFrom    = INTEGER(lc-coreHourFrom)
        coreHourTo      = INTEGER(lc-coreHourTo)
        hourFrom        = INTEGER(lc-hourFrom)
        hourTo          = INTEGER(lc-hourTo)
        incWeekend      = lc-incWeekend = "checked"
        viewShowY       = INTEGER(lc-viewShowY)
        viewShowX       = INTEGER(lc-viewShowX)
        saveSettings    = lc-saveSettings = "checked"
        lc-userList     = lc-userList
        .
ELSE 
    ASSIGN 
        viewerDay       = TODAY
        lc-mode         = "view"
        dayRange        = INTEGER(DiaryParams.initialDays)
        coreHourFrom    = INTEGER(substr(DiaryParams.coreHours,1,4))
        coreHourTo      = INTEGER(substr(DiaryParams.coreHours,5,4))
        hourFrom        = INTEGER(substr(DiaryParams.displayHours,1,4))
        hourTo          = INTEGER(substr(DiaryParams.displayHours,5,4))
        incWeekend      = DiaryParams.incWeekends 
        viewShowY       = DiaryParams.viewShowY
        viewShowX       = DiaryParams.viewShowX
        saveSettings    = FALSE
        lc-userList     = IF TRIM(DiaryParams.initialEngineers) = "" AND DiaryParams.LoginID = "system" THEN lc-global-user ELSE TRIM(DiaryParams.initialEngineers)
    
        /*     if DiaryParams.LoginID = "system" then "" else if DiaryParams.initialEngineers <> "" then trim(DiaryParams.initialEngineers) else lc-global-user */
        .




ASSIGN
    lc-lodate       = STRING(viewerDay - dayRange) 
    lc-hidate       = STRING(viewerDay)
    lc-viewerDay    = STRING(viewerDay)
    lc-dayRange     = STRING(dayRange)
    lc-coreHourFrom = STRING(coreHourFrom)
    lc-coreHourTo   = STRING(coreHourTo)
    lc-hourFrom     = STRING(hourFrom)
    lc-hourTo       = STRING(hourTo)
    lc-incWeekend   = IF incWeekend THEN "checked" ELSE ""
    lc-viewShowY    = STRING(viewShowY)
    lc-viewShowX    = STRING(viewShowX)
    lc-saveSettings = IF saveSettings THEN "checked" ELSE ""
    .

/* output to "C:\temp\djs2.txt" append.                  */
/* put unformatted                                       */
/* "LoginID              "     DiaryParams.LoginID skip  */
/* "lc-mode              "    lc-mode            skip    */
/* "lc-viewerDay         "    lc-viewerDay      skip     */
/* "lc-dayRange          "    lc-dayRange       skip     */
/* "lc-coreHourFrom      "    lc-coreHourFrom   skip     */
/* "lc-coreHourTo        "    lc-coreHourTo     skip     */
/* "lc-hourFrom          "    lc-hourFrom       skip     */
/* "lc-hourTo            "    lc-hourTo         skip     */
/* "lc-incWeekend        "    lc-incWeekend     skip     */
/* "lc-lodate            "    lc-lodate         skip     */
/* "lc-hidate            "    lc-hidate         skip     */
/* "lc-userList          "    lc-userList       skip     */
/* "lc-saveSettings      "    lc-saveSettings   skip     */
/* "lc-viewShowY         "    lc-viewShowY       skip    */
/* "lc-viewShowX         "    lc-viewShowX       skip    */
/* "lc-global-company    "    lc-global-company skip     */
/* "lc-global-user       "    lc-global-user    skip(2). */
/* output close.                                         */

CASE viewShowY :
    WHEN 1 THEN 
        ASSIGN 
            li-blockheight  = 20
            li-offsetheight = 18.
    WHEN 2 THEN 
        ASSIGN 
            li-blockheight  = 40
            li-offsetheight = 58.
    WHEN 3 THEN 
        ASSIGN 
            li-blockheight  = 60
            li-offsetheight = 98.
    OTHERWISE   
    ASSIGN 
        li-blockheight  = 20
        li-offsetheight = 18.
END CASE.

CASE viewShowX :
    WHEN 1 THEN 
        ASSIGN 
            li-blockwidth  = 900.
    WHEN 2 THEN 
        ASSIGN 
            li-blockwidth  = 1350.
    WHEN 3 THEN 
        ASSIGN 
            li-blockwidth  = 1800.
    OTHERWISE   
    ASSIGN 
        li-blockwidth  = 900.
END CASE.


                      

DO zx = 1 TO dayRange:
    ASSIGN 
        currentDay = DATE(STRING(viewerDay + (zx - 1)))   /*  date(string(viewerDay + (zx - (round(dayRange / 2,0)))))  */
        dayNum     = WEEKDAY(currentDay).
    IF NOT incWeekend AND (dayNum = 1 OR dayNum = 7) THEN cx = cx + 1.
END.
ASSIGN 
    dayWidth = STRING(ROUND(li-blockwidth / (dayRange - cx),0)).

IF cx > 0  AND INTEGER(dayWidth) < 80 THEN dayWidth = "80".
IF INTEGER(dayWidth) <= 80 THEN
DO: 
    dayWidth = "80".
    li-blockwidth = 80 * (dayRange - cx).
END.


RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ending-JS) = 0 &THEN

PROCEDURE ending-JS :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/



    {&out}
    '<script type="text/javascript" language="javascript">' skip
  ' <!-- ' skip

/* populateIframe */
  'function populateIframe() ~{' skip

 

  'if ( "refresh" == "' lc-mode '" )' skip
  ' ~{ ' skip
 
  'var viewerDay    = document.mainform.elements["viewerDay"].value; ' skip
  'var dayRange     = document.getElementById("xdayRange").value; ' skip
  'var coreHourFrom = document.getElementById("xcoreHourFrom").value; ' skip
  'var coreHourTo   = document.getElementById("xcoreHourTo").value; ' skip
  'var hourFrom     = document.getElementById("xhourFrom").value; ' skip
  'var hourTo       = document.getElementById("xhourTo").value; ' skip
  'var incWeekend   = document.getElementById("xincWeekend").value; ' skip
  'var viewShowY    = document.getElementById("xviewShowY").value; ' skip
  'var viewShowX    = document.getElementById("xviewShowX").value; ' skip
  'var userList     = document.getElementById("xuserList").value; ' skip    
 
  ' document.getElementById("diaryinnerframe").src="'  appurl  '/time/diaryview.p?mode=' lc-mode '&viewerDay=" + viewerDay   + '
  '"&dayRange=" + dayRange + "&coreHourFrom=" + coreHourFrom + "&coreHourTo=" + coreHourTo + '    
  '"&hourFrom=" + hourFrom + "&hourTo=" + hourTo + "&incWeekend=" + incWeekend + "&viewShowY=" + viewShowY + "&viewShowX=" + viewShowX + "&userList=" + userList ;' skip

  ' ~}' skip
  'else ' skip
  ' ~{' skip
  'var viewerDay = document.mainform.elements["viewerDay"].value; ' skip
  ' document.getElementById("diaryinnerframe").src="'  appurl  '/time/diaryview.p?mode=' lc-mode '&viewerDay=" + viewerDay  ;' skip
  '~ }' skip

  '~}' skip

/* Refresh */
  'function RefreshDiary() ~{' skip
  ' var innerDocument = window.frames["diaryinnerframe"].document; ' skip
  ' var innerFrameForm = innerDocument.forms["diaryinnerform"];' skip
  ' innerFrameForm.submit() ;' skip
  '~}' skip

/* Refresh SELF*/
  'function RefreshSelf(mode, viewerDay, dayRange, coreHourFrom, coreHourTo, hourFrom, hourTo, incWeekend, viewShowY, viewShowX, userList )' skip
  '~{' skip
  ' var url = "' appurl '/time/diaryframe.p?mode=refresh&viewerDay=" + viewerDay + '
  '"&dayRange=" + dayRange + "&coreHourFrom=" + coreHourFrom + "&coreHourTo=" + coreHourTo + '    
  '"&hourFrom=" + hourFrom + "&hourTo=" + hourTo + "&incWeekend=" + incWeekend + "&viewShowY=" + viewShowY + "&viewShowX=" + viewShowX + "&userList=" + userList ;' skip
 
  ' window.location = url;' skip
  '~}' skip

/* SaveSettings */
  'function SaveSettings(varObj) ~{' skip
  ' var innerDocument = window.frames["diaryinnerframe"].document; ' skip
  ' var innerFrameForm = innerDocument.forms["diaryinnerform"];' skip
  ' innerFrameForm.elements["submitsource"].value = "saveSettings";' skip
  ' innerFrameForm.elements["saveSettings"].value = varObj ? "checked" : "" ;' skip
  ' innerFrameForm.submit() ;' skip
  '~}' skip

/* ChangeDates */
  'function ChangeDates() ~{' skip
  ' var innerDocument = window.frames["diaryinnerframe"].document; ' skip
  ' var innerFrameForm = innerDocument.forms["diaryinnerform"];' skip
/*                                                         */
/*     'var myCal = Calendar; ' skip                       */
/*     'alert(myCal.cal.dateClicked ); ' skip              */
/*                                                         */
/*   ' if ( ! cal.dateClicked  ) ~{ return;    ~} ; ' skip */

  ' innerFrameForm.elements["submitsource"].value = "dateChange";' skip
  ' innerFrameForm.elements["viewerDay"].value = document.forms["mainform"].ffviewerDay.value;' skip
  ' innerFrameForm.submit() ;' skip
  '~}' skip

/* ChangeDays */
  'function ChangeDays(newVal) ~{' skip
  ' var innerDocument = window.frames["diaryinnerframe"].document; ' skip
  ' var innerFrameForm = innerDocument.forms["diaryinnerform"];' skip
  ' if (innerFrameForm) ~{' skip
  '  innerFrameForm.elements["submitsource"].value = "daysChange";' skip
  '  innerFrameForm.elements["dayRange"].value = newVal;' skip
  '  innerFrameForm.submit() ;' skip
  ' ~}' skip
  '~}' skip

/* ChangeUsers */
  'function ChangeUsers(userName) ~{' skip
  ' var innerDocument = window.frames["diaryinnerframe"].document; ' skip
  ' var innerFrameForm = innerDocument.forms["diaryinnerform"];' skip
  ' innerFrameForm.elements["submitsource"].value = "userChange";' skip
  ' var newuserList = "";' skip
  ' for(var i=0; i < document.mainform.scripts.length; i++) ~{ ' skip
  '  if(document.mainform.scripts[i].checked)' skip
  '  newuserList +=  document.mainform.scripts[i].value + "," ;' skip
  '  ~}' skip
  ' innerFrameForm.elements["userList"].value = newuserList ;' skip
  ' innerFrameForm.submit() ;' skip
  '~}' skip

/* ChangeWeekend */
  'function ChangeWeekend() ~{' skip
  ' var innerDocument = window.frames["diaryinnerframe"].document; ' skip
  ' var innerFrameForm = innerDocument.forms["diaryinnerform"];' skip
  ' innerFrameForm.elements["submitsource"].value = "weekendChange";' skip
  ' innerFrameForm.elements["incWeekend"].value = document.forms["mainform"].incWeekend.checked ? "checked" : "" ;' skip
  ' innerFrameForm.submit() ;' skip
  '~}' skip

/* TodaysDate  */
  'function TodaysDate() ~{' skip
  ' var innerDocument = window.frames["diaryinnerframe"].document; ' skip
  ' var innerFrameForm = innerDocument.forms["diaryinnerform"];' skip
  ' innerFrameForm.elements["submitsource"].value = "dateChange";' skip
  ' innerFrameForm.elements["viewerDay"].value = "' today '";' skip
  ' document.mainform.elements["viewerDay"].value = "' today '";' skip
  ' innerFrameForm.submit() ;' skip
  '~}' skip

/* ChangeSizeY */
  'function ChangeSizeY(newVal) ~{' skip
  ' var innerDocument = window.frames["diaryinnerframe"].document; ' skip
  ' var innerFrameForm = innerDocument.forms["diaryinnerform"];' skip
  ' innerFrameForm.elements["submitsource"].value = "ChangeSizeY";' skip
  ' innerFrameForm.elements["viewShowY"].value = newVal  ;' skip
  ' innerFrameForm.submit() ;' skip
  '~}' skip

/* ChangeSizeX */
  'function ChangeSizeX(newVal) ~{' skip
  ' var innerDocument = window.frames["diaryinnerframe"].document; ' skip
  ' var innerFrameForm = innerDocument.forms["diaryinnerform"];' skip
  ' innerFrameForm.elements["submitsource"].value = "ChangeSizeX";' skip
  ' innerFrameForm.elements["viewShowX"].value = newVal  ;' skip
  ' innerFrameForm.submit() ;' skip
  '~}' skip

/* ChangeUserColour  */
  'function ChangeUserColour(userVX, userID, colorHex) ~{' skip
  ' document.getElementById("userVX").value = userVX; ' skip
  ' document.getElementById("userID").value = userID; ' skip
  ' document.getElementById("colorHex").value = colorHex; ' skip
  ' document.getElementById("colwheel").style.display = "block"; ' skip
  ' document.getElementById("colwheel").style.top = "81px"; ' skip
  ' document.getElementById("colwheel").style.left = "208px"; ' skip
  ' document.getElementById("colwheel").style.float = "right"; ' skip
  ' document.getElementById("colwheel").style.zIndex = 999; ' skip
  ' document.getElementById("colwheel").innerHTML = ~'' + colWheel + '~'; ' skip
  ' document.getElementById("colwheel").style.background = "transparent"; ' skip
  '~}' skip

/* FixUserColour */
  'function FixUserColour(userNum, colourNum) ~{' skip
  ' document.getElementById("colwheel").innerHTML = ""; ' skip
  ' var userID =  document.getElementById("userID").value;' skip
  ' var innerDocument = window.frames["diaryinnerframe"].document; ' skip
  ' var innerFrameForm = innerDocument.forms["diaryinnerform"];' skip
  ' innerFrameForm.elements["submitsource"].value = "changeColour";' skip
  ' innerFrameForm.elements["changeColour"].value = userID + "|" + colourNum ;' skip
  ' innerFrameForm.submit() ;' skip
  '~}' skip

/* PopulateIframe */
  ' populateIframe(); ' skip

  ' var spinCtrl = new SpinControl();' skip
  ' spinCtrl.Tag = "left";' skip
  ' spinCtrl.SetMaxValue(45);' skip
  ' spinCtrl.SetMinValue(1);' skip
  ' spinCtrl.SetCurrentValue(' dayRange ');' skip
  ' var el = document.getElementById("spinCtrlContainer");' skip
  ' el.appendChild(spinCtrl.GetContainer());' skip
  ' spinCtrl.StartListening();' skip
  ' // #' lc-global-user '#   #' lc-userList '# '  skip
  ' // -->' skip 
  '</script>' skip
    .




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
  
    DEFINE VARIABLE vx            AS INTEGER NO-UNDO.
    DEFINE VARIABLE lc-checked    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE userColour    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE userVX        AS INTEGER  NO-UNDO.

    ASSIGN 
        colWheel = 
'<iframe id="colWheel_iframe" src="/colourpick.html" allowtransparency="true" scrolling="no" marginwidth="0" marginheight="0" frameborder="0" vspace="0" hspace="0" '
  + ' style="overflow:hidden; background:transparent; width:100%; height:100%; display:block; border:0px solid blue;"></iframe>'. 

    RUN outputHeader.

    {&out} htmlib-OpenHeader("Diary View") skip.

    {&out}
    '<style>' skip
      '.hi ~{ color: red; font-size: 10px; margin-left: 15px; font-style: italic;~}' skip
      '</style>' skip 
      '<link href="/style/diary.css" type="text/css" rel="stylesheet" />' skip.

    {&out}
    '<script type="text/javascript" language="javascript">' skip

     'function setSize() ~{' skip
     'var frameW' skip
     ' if ( document.frames ) ~{frameW = document.frames["diaryinnerframe"].document.getElementById("Calendar1").width + "px"; ~}' skip
     ' else ~{ frameW = document.getElementById("diaryinnerframe").contentDocument.getElementById("Calendar1").width ; ~}' skip
     'var frameH = document.getElementById("fixedTimeDiv").offsetHeight + 17 + "px";' skip
     'var iframe = document.getElementById("diaryinnerframe");' skip
/*      'alert(frameW); ' skip */
     'iframe.style.height = frameH;' skip
     'iframe.style.width  = frameW;' skip
     '~}' skip
     '</script>' skip.
   
    
    {&out} htmlib-JScript-Maintenance() skip.

    {&out} htmlib-JScript-Spinner() skip.
 
    {&out} htmlib-CalendarInclude() skip.

    {&out} '<script type="text/javascript" language="javascript">' skip  /* this moves calendar to corect position rather than default */
           ' <!-- ' skip
           'Calendar.prototype.showAt = function (x, y) ~{ ' skip
           'var s = this.element.style; ' skip
           's.left = 7 + "px"; ' skip
           's.top = 102 + "px"; ' skip
           's.zIndex = 299; ' skip
           'this.show(); ' skip
           '~}; ' skip
           ' // -->' skip 
           '</script>' skip.


    {&out} htmlib-CloseHeader("") skip.

    {&out} htmlib-StartForm("mainform","post", appurl + '/time/diaryframe.p' ) skip.

    {&out} htmlib-ProgramTitle("Engineers Time Recording") skip.
    
    {&out} htmlib-Hidden("submitsource","null").

    {&out} 
    '<input type="hidden" id="userVX" value="">' skip
    '<input type="hidden" id="userID" value="">' skip
    '<input type="hidden" id="colorHex" value="">' skip
    '<div id="diaryscreen" style="clear:both;"   > ' skip
    ' <br><br><br><br>' skip
      '<table cellpadding="0" cellspacing="0" border="0"  width="100%" >' skip
        '<tr valign="top" align="left" >' skip
          '<td width="200px" height="650px" valign="top" align="left" >' skip
    .

    {&out} '<table valign="top" align="left"  width="200px" cellpadding="0" cellspacing="0" border="0" >' skip
          ' <tr >' skip
          '  <td valign="top" align="left" width="200px"  colspan="3" >' skip.
             
    {&out} '<div class="sidelabel"   >'
    htmlib-CalendarInputField("viewerDay",10,lc-viewerDay) 
    htmlib-CalendarLink("viewerDay")
    '&nbsp; Diary Date</div>' skip.
    {&out}
    '</td>'
    '</tr>'
    '<tr>'
    '<td colspan="3" valign="middle" align="left" height="20px" width="200px" >'
    '<div id="spinCtrlContainer" style="position:relative;border:0; width:50px;height:20px;z-index:99;"  >'
    '</div><div class="sidelabel"  style="position:absolute;border:0;margin-left:50px;margin-top:-15px; width:200px;height:20px;" >&nbsp; Days shown</div>'
    '</td>' skip
              '</tr>'
              '<tr>' skip
                '<td colspan="3" valign="top" align="left"><input class="inputfield" type="checkbox" name="incWeekend" value="" ' lc-incWeekend ' onClick="ChangeWeekend()" >' skip
                '<span class="sidelabel">Show Weekends?</span></td>' skip
              '</tr>' skip
             

              '<tr>' skip
                '<td colspan="3" valign="top" align="left">' skip
                   '<span><input class="inputfield" type="radio" name="ChangeSizeY1" value="" ' if viewShowY = 1 then "checked" else "" ' onClick="ChangeSizeY(1)" >S</span>' skip
                   '<span><input class="inputfield" type="radio" name="ChangeSizeY2" value="" ' if viewShowY = 2 then "checked" else "" ' onClick="ChangeSizeY(2)" >M</span>' skip
                   '<span><input class="inputfield" type="radio" name="ChangeSizeY3" value="" ' if viewShowY = 3 then "checked" else "" ' onClick="ChangeSizeY(3)" >L</span>' skip
                '<span class="sidelabel">&nbsp; Hour Size</span></td>' skip
              '</tr>' skip

              '<tr>' skip
                '<td colspan="3" valign="top" align="left">' skip
                   '<span><input class="inputfield" type="radio" name="ChangeSizeX1" value="" ' if viewShowX = 1 then "checked" else "" ' onClick="ChangeSizeX(1)" >S</span>' skip
                   '<span><input class="inputfield" type="radio" name="ChangeSizeX2" value="" ' if viewShowX = 2 then "checked" else "" ' onClick="ChangeSizeX(2)" >M</span>' skip
                   '<span><input class="inputfield" type="radio" name="ChangeSizeX3" value="" ' if viewShowX = 3 then "checked" else "" ' onClick="ChangeSizeX(3)" >L</span>' skip
                '<span class="sidelabel">&nbsp; Day Width</span></td>' skip
              '</tr>' skip

                  '<tr>' skip
                '<td valign="TOP" align="left" colspan="3">' skip
                '<hr>' skip
                '</td>' skip
             '</tr>' skip

    /*              '</table></tr><tr><table>' skip */
    .


    FOR EACH webUser NO-LOCK
        WHERE webuser.company = lc-global-company
        AND webuser.UserClass MATCHES "*internal*"
        AND webuser.superuser = TRUE
        AND webuser.Disabled = FALSE
      
        :
        FIND FIRST WebStdTime OF WebUser NO-LOCK NO-ERROR .

        IF NOT AVAILABLE WebStdTime THEN NEXT.

        ASSIGN 
            userColour = IF AVAILABLE WebStdTime THEN WebStdTime.StdColour ELSE "#FFFFFF"
            userVX     = userVX + 1.

        IF LOOKUP(TRIM(webUser.LoginID),lc-userList) > 0  THEN lc-checked = "checked".
        ELSE lc-checked = "".

        {&out}  '<tr>' skip
                '<td width="25px" valign="top" align="left" >' skip
                  '<input class="inputfield" type="checkbox" name="scripts" value="' WebUser.LoginID '" ' lc-checked ' onClick="ChangeUsers(this.name);" >' skip
                '</td>' skip
                '<td width="25px" >' skip
                  '<div id="userColor_' string(userVX) '" style="width:20px;height:10px;background-color:' userColour ';" onclick="ChangeUserColour(' string(userVX) ',~'' WebUser.LoginID '~',~'' userColour '~');">' skip
                '<td width="180px" valign="middle" align="left">' skip
                  '<span class="sidelabel" width="200px" >' webUser.name '</span>' skip
                '</td>' skip
              '</tr>' skip .
    END.


    {&out}  '<tr>' skip
                '<td valign="TOP" align="left" colspan="3">' skip
                '<hr>' skip
                '</td>' skip
              '</tr>' skip
              '<tr>' skip.

    FIND FIRST WebStdTime WHERE WebStdTime.loginID = lc-global-user NO-LOCK NO-ERROR .
    IF AVAILABLE WebStdTime THEN 
    DO:
        {&out} 
        '<td valign="top" align="left" colspan="3" width="200px" >' skip
                  ' <input type="button" class="prefsbutton" onclick="SaveSettings(false)" value="Delete Prefs" />'  skip
    
                  '<input type="button" class="prefsbutton" onclick="SaveSettings(true)" value="Save Prefs" /> '  skip
                '</td>' skip 
              '</tr>' skip

        /*               '<tr>' skip                                                                                                                                                           */
        /*                 '<td valign="top" align="left"><input class="inputfield" type="checkbox" name="scripts" value="DavidShilling" checked onClick="ChangeUsers(this.name)" ></td>' skip */
        /*                 '<td valign="middle" align="left"><span class="sidelabel">David Shilling</span></td>' skip                                                                          */
        /*               '</tr>' skip                                                                                                                                                          */
        /*               '<tr>' skip                                                                                                                                                           */
        /*                 '<td valign="top" align="left"><input class="inputfield" type="checkbox" name="scripts" value="Ian Bibby" onClick="ChangeUsers(this.name)" ></td>' skip             */
        /*                 '<td valign="middle" align="left"><span class="sidelabel">Ian Bibby</span></td>' skip                                                                               */
        /*               '</tr>' skip                                                                                                                                                          */
        .
    END.

    {&out}
    '</table>' skip

 
          '</td>' skip
          '<td width="56px" align="left">' skip
    .

    RUN timeBar.

    {&out}
    '</td>'

    '<td>' skip    /*  ' string(li-blockwidth) 'px */
          '<!--[if gt IE 6 ]>'
            '<!-- gt IE6 --><iframe id="diaryinnerframe" name="diaryinnerframe" src="" onload="setSize()" style="position:relative;overflow:hidden;width:' string(li-blockwidth) 'px;height:650px;" frameborder="0" '  
            ' marginwidth=0 marginheight=0 hspace=0 vspace=0 scrolling=no  >' skip
            '</iframe >' skip
          '<![endif]-->'

          '<!--[if lte IE 6 ]>'
            '<!-- lte IE6 --><iframe id="diaryinnerframe" name="diaryinnerframe" src="" onload="setSize()" style="position:relative;overflow:hidden;width:' string(li-blockwidth) 'px;height:650px;" frameborder="0" '
            ' marginwidth=0 marginheight=0 hspace=0 vspace=0 scrolling=no >' skip
            '</iframe >' skip
          '<![endif]-->'

          '<!--[if !IE]>-->'
            '<!-- ! IE --><iframe id="diaryinnerframe" name="diaryinnerframe" src="" onload="setSize()" style="position:relative;overflow:hidden;width:' string(li-blockwidth) 'px;height:650px;" frameborder="0" '
            ' marginwidth=0 marginheight=0 hspace=0 vspace=0 scrolling=no >' skip
            '</iframe >' skip
          '<!--<![endif]-->'

          '</td>' skip
        '</tr>' skip
      '</table>' skip
     '</div>' skip
    .



    {&out} htmlib-CalendarScript("viewerDay") skip.

    {&out} '<div id="colwheel" style="position:absolute;display:none;width:250px;height:280px;background:transparent;"></div>' skip.

    {&out} htmlib-Hidden("xmode",lc-mode) skip.
    {&out} htmlib-Hidden("xstartDay",lc-viewerDay) skip.
    {&out} htmlib-Hidden("xdayRange",lc-dayRange) skip.
    {&out} htmlib-Hidden("xcoreHourFrom",lc-coreHourFrom) skip.
    {&out} htmlib-Hidden("xcoreHourTo",lc-coreHourTo) skip.
    {&out} htmlib-Hidden("xhourFrom",lc-hourFrom) skip.
    {&out} htmlib-Hidden("xhourTo",lc-hourTo) skip.
    {&out} htmlib-Hidden("xincWeekend",lc-incWeekend) skip.
    {&out} htmlib-Hidden("xviewShowY",lc-viewShowY) skip.
    {&out} htmlib-Hidden("xviewShowX",lc-viewShowX) skip.
    {&out} htmlib-Hidden("xuserList",lc-userList) skip.
    {&out} htmlib-EndForm() skip.

    RUN ending-JS.

    {&OUT} htmlib-Footer() skip.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-timeBar) = 0 &THEN

PROCEDURE timeBar :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/


    {&out}

    '<div id="fixedTimeDiv" style="position:relative;top:0px;left:0px;width:56px;z-index:100;">' skip


  

        '<table id="timeCells" cellpadding="0" cellspacing="0" border="0" width="0" style="border-left:1px solid #000000;border-right:1px solid #000000;border-bottom:1px solid #000000;">'  skip
          '<tr style="height:1px;background-color:#000000;">'  skip
            '<td>'  skip
            '</td>' skip
          '</tr>'  skip
          '<tr style="height:21px;">'  skip
            '<td valign="bottom" style="background-color:#ECE9D8;cursor:default;">'  skip
              '<div style="display:block;border-bottom:1px solid #000000;text-align:right;">'  skip 
                '<div style="padding:2px;font-size:6pt;">' skip
                  '&nbsp;' skip
                '</div>'  skip
              '</div>'  skip
            '</td>'  skip
          '</tr>'  skip.

    DO vx = 01 TO 24 :
        IF vx * 100 >= hourFrom AND vx * 100 <= hourTo THEN /* or how ever many hours to do... */
        DO:
            IF vx > 11 THEN ASSIGN ap = 2.
            ELSE ASSIGN ap = 1.
            IF vx > 12 THEN ASSIGN yx = vx - 12.
            ELSE ASSIGN yx = vx.

            {&out}

            '<tr style="height:' (li-blockheight * 2) 'px;">' skip
            '<td valign="bottom" style="background-color:#ECE9D8;cursor:default;">' skip
             '<div id="idMenuFixedInViewport" >' skip
              '<div id="TT" style="display:block;border-bottom:1px solid #ACA899;height:' (li-blockheight * 1.5) 'px;text-align:right;">' skip
                '<div style="padding:2px;font-family:Tahoma;font-size:16pt;vertical-align:top;">' skip
          string(yx)   skip
                  '<span style="font-size:10px; vertical-align: super; ">&nbsp;' skip
          string(AMPM[ap])    skip
                  '</span>' skip
                '</div>' skip
              '</div>' skip
            '</div>' skip
            '</td>' skip
          '</tr>'  skip.
        END.
    END.

    {&out}
    '</table>' skip
     '</div>' skip
    .



END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-dateFormat) = 0 &THEN

FUNCTION dateFormat RETURNS CHARACTER
    ( params AS DATE ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-day     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-month   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-year    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-mthdesc AS CHARACTER INITIAL "January,February,March,April,May,June,July,August,September,October,November,December"  NO-UNDO.

    lc-day = STRING(DAY(params)).
    lc-month = ENTRY(MONTH(params),lc-mthdesc).
    lc-year = STRING(YEAR(params)).




    RETURN STRING((IF LENGTH(lc-day) = 1 THEN "&nbsp;" + lc-day ELSE lc-day) + " " + lc-month + " " + lc-year).


END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-fnText) = 0 &THEN

FUNCTION fnText RETURNS CHARACTER
    ( pf-knbid AS DECIMAL,
    pi-count AS INTEGER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER knbText  FOR knbText.  
    DEFINE VARIABLE li-count    AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-found    AS INTEGER NO-UNDO.
    DEFINE VARIABLE lc-return   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-char     AS CHARACTER NO-UNDO.

    FIND knbText WHERE knbText.knbID = pf-knbID
        AND knbText.dType = "I" NO-LOCK NO-ERROR.
    IF NOT AVAILABLE knbText THEN RETURN "&nbsp;".


    DO li-count = 1 TO NUM-ENTRIES(knbText.dData,"~n"):

        ASSIGN 
            lc-char = ENTRY(li-count,knbText.dData,"~n").
        IF TRIM(lc-char) = "" THEN NEXT.

       
        IF li-found = 0
            THEN ASSIGN lc-return = RIGHT-TRIM(lc-char).
        ELSE ASSIGN lc-return = lc-return + "<br>" + right-trim(lc-char).

        ASSIGN 
            li-found = li-found + 1.

        IF li-found = pi-count THEN LEAVE.

    END.

    RETURN lc-return.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Select-DayDate) = 0 &THEN

FUNCTION Format-Select-DayDate RETURNS CHARACTER
    ( pc-htm AS CHARACTER  ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

    lc-htm = REPLACE(pc-htm,'<select',
        '<select onChange="ChangeDates()"'). 


    RETURN lc-htm.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-timeFormat) = 0 &THEN

FUNCTION timeFormat RETURNS CHARACTER
    (param1 AS INTEGER):
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE hh AS CHARACTER NO-UNDO.
    DEFINE VARIABLE mm AS CHARACTER NO-UNDO.
    DEFINE VARIABLE ss AS CHARACTER NO-UNDO.
    DEFINE VARIABLE aa AS CHARACTER NO-UNDO.
 
    ASSIGN 
        hh = STRING(int(substr(STRING(param1,"9999"),1,2)))
        mm  = substr(STRING(param1,"9999"),3,2).
    RETURN STRING(STRING(hh) + ":" + string(mm) ).

END FUNCTION.


&ENDIF

