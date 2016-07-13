/***********************************************************************

    Program:        time/diaryview.p
    
    Purpose:        Display the diary...
    
    Notes:
    
    
    When        Who         What
    01/09/2010  DJS         Initial
     
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

 


/* PARAM VARS */

DEFINE VARIABLE userList        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submitsource AS CHARACTER NO-UNDO.
DEFINE VARIABLE dayRange        AS INTEGER   NO-UNDO.
DEFINE VARIABLE hourFrom        AS INTEGER   NO-UNDO.
DEFINE VARIABLE hourTo          AS INTEGER   NO-UNDO.
DEFINE VARIABLE coreHourFrom    AS INTEGER   NO-UNDO.
DEFINE VARIABLE coreHourTo      AS INTEGER   NO-UNDO.
DEFINE VARIABLE incWeekend      AS LOG       NO-UNDO.
DEFINE VARIABLE saveSettings    AS LOG       NO-UNDO.
DEFINE VARIABLE changeColour    AS CHARACTER NO-UNDO.
DEFINE VARIABLE viewShowY       AS INTEGER   NO-UNDO.
DEFINE VARIABLE viewshowX       AS INTEGER   NO-UNDO.

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
/* def var p-cx              as char initial "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40"  no-undo.  */
DEFINE VARIABLE p-vx            AS INTEGER   NO-UNDO.
DEFINE VARIABLE p-vz            AS INTEGER   NO-UNDO.
DEFINE VARIABLE p-zx            AS INTEGER   NO-UNDO. 


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
DEFINE VARIABLE lc-changeColour AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-blockheight  AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-blockheight  AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-offsetheight AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-blockwidth   AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-viewShowY    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-viewshowX    AS CHARACTER NO-UNDO.

/*  TABLES  */

DEFINE TEMP-TABLE NewEvents LIKE DiaryEvents
    FIELD idRow      AS ROWID
    FIELD eventID    AS INTEGER   FORMAT "999"
    FIELD overLap    AS CHARACTER FORMAT "x(9)" 
    FIELD comment    AS CHARACTER
    FIELD columnID   AS INTEGER   FORMAT "zz9"
    FIELD issueLeft  AS INTEGER
    FIELD issueWidth AS INTEGER
    FIELD issRowid   AS CHARACTER
    FIELD actRowid   AS CHARACTER
    FIELD issClosed  AS CHARACTER
    FIELD userColour AS CHARACTER
    FIELD duration   AS CHARACTER
    .

DEFINE TEMP-TABLE DE LIKE NewEvents.

DEFINE BUFFER bDE  FOR DE.
DEFINE BUFFER bbDE FOR DE.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-fnText) = 0 &THEN

FUNCTION fnText RETURNS CHARACTER
    ( pf-knbid AS DECIMAL,
    pi-count AS INTEGER )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-timeFormat) = 0 &THEN

FUNCTION timeFormat RETURNS CHARACTER
    (param1 AS INTEGER) FORWARD.


&ENDIF


/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 4.69
         WIDTH              = 35.57.
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
    lc-submitsource     = get-value("submitsource")
    lc-userList         = get-value("userList")
    lc-viewerDay        = get-value("viewerDay")     
    lc-dayRange         = get-value("dayRange")      
    lc-coreHourFrom     = get-value("coreHourFrom")  
    lc-coreHourTo       = get-value("coreHourTo")    
    lc-hourFrom         = get-value("hourFrom")      
    lc-hourTo           = get-value("hourTo")       
    lc-incWeekend       = get-value("incWeekend") 
    lc-saveSettings     = get-value("saveSettings") .
lc-changeColour     = get-value("changeColour") .
lc-viewShowY        = get-value("viewShowY") .
lc-viewShowX        = get-value("viewShowX") .


/* output to "C:\temp\djs.txt" append.                   */
/* put unformatted                                       */
/* "LoginID              "     DiaryParams.LoginID skip  */
/* "lc-mode              "    lc-mode           skip     */
/* "lc-submitsource      "    lc-submitsource   skip     */
/* "lc-viewerDay         "    lc-viewerDay      skip     */
/* "lc-dayRange          "    lc-dayRange       skip     */
/* "lc-coreHourFrom      "    lc-coreHourFrom   skip     */
/* "lc-coreHourTo        "    lc-coreHourTo     skip     */
/* "lc-hourFrom          "    lc-hourFrom       skip     */
/* "lc-hourTo            "    lc-hourTo         skip     */
/* "lc-incWeekend        "    lc-incWeekend     skip     */
/* "lc-userList          "    lc-userList       skip     */
/* "lc-saveSettings      "    lc-saveSettings   skip     */
/* "lc-changeColour      "    lc-changeColour   skip     */
/* "lc-viewShowY         "    lc-viewShowY      skip     */
/* "lc-viewShowX         "    lc-viewShowX      skip     */
/* "lc-global-company    "    lc-global-company skip     */
/* "lc-global-user       "    lc-global-user    skip(2). */
/* output close.                                         */


IF lc-submitsource = "dateChange" THEN
    ASSIGN viewerDay = DATE(substr(lc-viewerDay,1,2)  + "/" +  substr(lc-viewerDay,4,2) + "/" +  substr(lc-viewerDay,7) ).

IF lc-submitsource = "daysChange" THEN
    ASSIGN dayRange  = INTEGER(lc-dayRange).

IF lc-submitsource = "userChange" THEN
    ASSIGN userList  = lc-userList.

IF lc-submitsource = "changeSizeY" THEN
    ASSIGN viewShowY = INTEGER(lc-viewShowY).

IF lc-submitsource = "changeSizeX" THEN
    ASSIGN viewShowX = INTEGER(lc-viewShowX).

IF lc-submitsource  = "weekendChange" THEN
    ASSIGN incWeekend = IF lc-incWeekend = "checked" THEN TRUE ELSE FALSE.

IF lc-submitsource    = "saveSettings" THEN
    ASSIGN saveSettings = IF lc-saveSettings = "checked" THEN TRUE ELSE FALSE.  

IF lc-submitsource = "changeColour" THEN
DO:
    ASSIGN 
        changeColour = "".
    RUN updateColour(lc-changeColour).
END.

IF lc-mode = "refresh" THEN
    ASSIGN
        viewerDay     = DATE(substr(lc-viewerDay,1,2)  + "/" +  substr(lc-viewerDay,4,2) + "/" +  substr(lc-viewerDay,7) )  
        lc-mode       = "".
ELSE
    ASSIGN
        viewerDay     = TODAY.


IF lc-mode = "view" THEN
    ASSIGN
        dayRange      = INTEGER(DiaryParams.initialDays)
        coreHourFrom  = INTEGER(substr(DiaryParams.coreHours,1,4))
        coreHourTo    = INTEGER(substr(DiaryParams.coreHours,5,4))
        hourFrom      = INTEGER(substr(DiaryParams.displayHours,1,4))
        hourTo        = INTEGER(substr(DiaryParams.displayHours,5,4))
        incWeekend    = DiaryParams.incWeekends 
        saveSettings  = saveSettings
        userList      = IF TRIM(DiaryParams.initialEngineers) = "" AND DiaryParams.LoginID = "system" THEN lc-global-user ELSE TRIM(DiaryParams.initialEngineers)
        viewShowY     = DiaryParams.viewShowY
        viewShowX     = DiaryParams.viewShowX
        .
ELSE
    ASSIGN 
        viewerDay     = DATE(substr(lc-viewerDay,1,2)  + "/" +  substr(lc-viewerDay,4,2) + "/" +  substr(lc-viewerDay,7) )  
        dayRange      = INTEGER(lc-dayRange)
        coreHourFrom  = INTEGER(lc-coreHourFrom)
        coreHourTo    = INTEGER(lc-coreHourTo)
        hourFrom      = INTEGER(STRING(lc-hourFrom,"9999"))
        hourTo        = INTEGER(STRING(lc-hourTo,"9999"))
        incWeekend    = IF lc-incWeekend = "checked" THEN TRUE ELSE FALSE
        saveSettings  = IF lc-saveSettings = "checked" THEN TRUE ELSE FALSE
        userList      = lc-userList
        viewShowY     = INTEGER(lc-viewShowY)
        viewShowX     = INTEGER(lc-viewShowX)
        .


ASSIGN
    lc-lodate       =  STRING(viewerDay)                    /*   string(viewerDay + (0 - (round(dayRange / 2,0))) )         */
    lc-hidate       =  STRING(viewerDay + dayRange)         /*   string(viewerDay + (dayRange - (round(dayRange / 2,0))) )  */
    lc-mode         = "update"
    lc-viewerDay    = STRING(viewerDay)
    lc-dayRange     = STRING(dayRange)
    lc-coreHourFrom = STRING(coreHourFrom)
    lc-coreHourTo   = STRING(coreHourTo)
    lc-hourFrom     = STRING(hourFrom)
    lc-hourTo       = STRING(hourTo)
    lc-incWeekend   = IF incWeekend THEN "checked" ELSE ""
    lc-saveSettings = IF saveSettings THEN "checked" ELSE ""
    lc-userList     = userList
    lc-viewShowY    = IF viewShowY = 0 THEN STRING(DiaryParams.viewShowY) ELSE STRING(viewShowY)
    lc-viewShowX    = IF viewShowX = 0 THEN STRING(DiaryParams.viewShowX) ELSE STRING(viewShowX)
    .




/* output to "C:\temp\djs.txt" append.                   */
/* put unformatted                                       */
/* "lc-mode              "    lc-mode           skip     */
/* "lc-submitsource      "    lc-submitsource   skip     */
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
/* "lc-changeColour      "    lc-changeColour   skip     */
/* "lc-viewShowY         "    viewShowY         skip     */
/* "lc-viewShowX         "    viewShowX         skip     */
/* "lc-global-company    "    lc-global-company skip     */
/* "lc-global-user       "    lc-global-user    skip(2). */
/* output close.                                         */

IF lc-submitsource = "saveSettings" THEN
DO:
    IF saveSettings THEN
    DO:
  
        FIND FIRST DiaryParams EXCLUSIVE-LOCK 
            WHERE DiaryParams.CompanyCode = lc-global-company 
            AND   DiaryParams.LoginID     = lc-global-user NO-ERROR.
        IF NOT AVAILABLE DiaryParams THEN
        DO:
            CREATE DiaryParams.
            ASSIGN 
                DiaryParams.CompanyCode = lc-global-company
                DiaryParams.LoginID     = lc-global-user.
        END.
        ASSIGN  
            DiaryParams.coreHours        = STRING(STRING(INTEGER(lc-coreHourFrom),"9999") + string(INTEGER(lc-coreHourTo),"9999") )
            DiaryParams.displayHours     = STRING(STRING(INTEGER(lc-HourFrom),"9999") + string(INTEGER(lc-HourTo),"9999") )
            DiaryParams.viewHours        = STRING(STRING(INTEGER(lc-HourFrom),"9999") + string(INTEGER(lc-HourTo),"9999") )
            DiaryParams.incWeekends      = incWeekend
            DiaryParams.initialDays      = dayRange
            DiaryParams.initialEngineers = lc-userList
            DiaryParams.viewShowY        = viewShowY
            DiaryParams.viewShowX        = viewShowX.
    END.
    ELSE 
        IF saveSettings = FALSE THEN
        DO:
            FIND FIRST DiaryParams EXCLUSIVE-LOCK 
                WHERE DiaryParams.CompanyCode = lc-global-company 
                AND   DiaryParams.LoginID     = lc-global-user NO-ERROR.
            IF AVAILABLE DiaryParams THEN DELETE DiaryParams.
        END.
    FIND FIRST DiaryParams NO-LOCK 
        WHERE DiaryParams.CompanyCode = lc-global-company 
        AND   DiaryParams.LoginID     = "system" NO-ERROR.
END.

FOR EACH webuser NO-LOCK
    WHERE webuser.companycode = lc-global-company
    AND   LOOKUP(webuser.loginid,lc-userList,",") > 0 :
  
    FIND WebStdTime OF WebUser NO-LOCK NO-ERROR .

    FOR EACH IssActivity NO-LOCK
        WHERE IssActivity.CompanyCode = webuser.CompanyCode
        AND IssActivity.ActivityBy  = webuser.loginid
        AND ( ( issactivity.StartDate >= date(lc-lodate) AND issactivity.StartDate <= date(lc-hidate) )  
        OR  ( issactivity.EndDate >= date(lc-lodate) AND issactivity.EndDate <= date(lc-hidate) ) ) :

        FIND FIRST issAction NO-LOCK OF issActivity NO-ERROR.
        FIND FIRST issue NO-LOCK WHERE issue.CompanyCode = webuser.CompanyCode
            AND issue.IssueNumber = IssActivity.IssueNumber NO-ERROR.

        CREATE NewEvents.
        ASSIGN
            NewEvents.ID          = STRING(issactivity.IssueNumber)
            NewEvents.EventData   = issactivity.Description 
            NewEvents.Name        = issactivity.ActivityBy   
            NewEvents.StartDate   = issactivity.StartDate
            NewEvents.StartTime   = INTEGER(   STRING(substr( STRING(issactivity.StartTime ,"HH:MM"),1,2) + substr( STRING(issactivity.StartTime ,"HH:MM"),4,2),"9999" ))
            NewEvents.Duration    = com-TimeToString(issactivity.Duration)
            NewEvents.EndDate     = issactivity.EndDate
            NewEvents.EndTime     = INTEGER(   STRING(substr( STRING(issactivity.EndTime ,"HH:MM"),1,2) + substr( STRING(issactivity.EndTime ,"HH:MM"),4,2),"9999" ))
            NewEvents.EventRowid  = IF AVAILABLE issue THEN       STRING(ROWID(issue)) ELSE ""
            NewEvents.issRowid    = IF AVAILABLE issAction THEN   STRING(ROWID(issAction)) ELSE ""
            NewEvents.actRowid    = IF AVAILABLE issactivity THEN STRING(ROWID(issactivity)) ELSE ""
            NewEvents.issClosed   = IF AVAILABLE Issue THEN Issue.StatusCode ELSE ""
            NewEvents.userColour  = IF AVAILABLE WebStdTime THEN WebStdTime.StdColour ELSE "#000000"
            .
        IF  NewEvents.StartTime + 5  > NewEvents.EndTime  THEN NewEvents.EndTime = NewEvents.StartTime + 5.
    /*       else if  NewEvents.EndTime - NewEvents.StartTime <  integer(   string(substr(NewEvents.Duration,1,index(NewEvents.Duration,":") - 1) + substr(NewEvents.Duration,index(NewEvents.Duration,":") + 1,2),"9999" ) ) */
    /*         then NewEvents.EndTime = NewEvents.StartTime +  integer(   string(substr(NewEvents.Duration,1,index(NewEvents.Duration,":") - 1) + substr(NewEvents.Duration,index(NewEvents.Duration,":") + 1,2),"9999" ) ).  */
    /*       if NewEvents.StartTime < hourFrom then NewEvents.StartTime = hourFrom + 100.  */
    /*       if NewEvents.EndTime > hourTo then NewEvents.EndTime = hourTo - 100.          */
    END.             
END.               


ASSIGN
    hourFrom        = INTEGER(substr(DiaryParams.displayHours,1,4))
    hourTo          = INTEGER(substr(DiaryParams.displayHours,5,4)).

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


IF lc-submitsource = "changeSizeY" OR lc-submitsource = "changeSizeX" THEN
DO:
    RUN refresh-web-request.
    RETURN.
END.
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-createEvents) = 0 &THEN

PROCEDURE createEvents :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
  
    EMPTY TEMP-TABLE DE NO-ERROR.
    p-vx = 0.
    p-vz = 0.
    p-zx = 0.
    timeEnd = 0.
    FOR EACH NewEvents NO-LOCK WHERE NewEvents.StartDate = currentDay  
        BREAK BY NewEvents.StartTime :
        CREATE DE.
        BUFFER-COPY NewEvents TO DE. 
      
        ASSIGN 
            p-vx          = p-vx + 1
            DE.eventID    = p-vx /* integer(entry(p-vx,p-cx)) */
            DE.issueWidth = 1
            DE.overLap    = STRING(p-vx)
            DE.columnID   = 1.
    END.


    FOR EACH DE WHERE  DE.StartDate = currentDay BY DE.eventID :
        FOR EACH bDE WHERE bDE.StartDate  = currentDay
            AND   bDE.StartTime >= DE.StartTime
            AND   bDE.eventID   <> DE.eventID
            BY bDE.eventID :
            IF  ( bDE.StartTime >= DE.StartTime AND bDE.EndTime  <= DE.EndTime )
                OR (bDE.StartTime <= DE.EndTime AND bDE.StartTime  >= DE.StartTime)
                THEN ASSIGN bDE.ColumnID = DE.ColumnID + 1.
            ELSE ASSIGN bDE.ColumnID = IF DE.ColumnID > 1 THEN bDE.ColumnID ELSE 1.
        END.
    END.
  
    FOR EACH DE WHERE DE.Startdate = currentDay BY DE.StartTime  :
        FOR EACH bDE WHERE bDE.Startdate = currentDay
            AND bDE.eventID <> DE.eventID
            AND ( bDE.StartTime >= DE.StartTime
            OR   (bDE.StartTime <= DE.EndTime AND bDE.StartTime  >= DE.StartTime) )
            BY bDE.StartTime :
            IF bDE.EndTime  <= DE.EndTime  AND bDE.StartTime <= DE.EndTime THEN ASSIGN DE.overLap = IF LOOKUP(STRING(bDE.eventID),DE.overLap) > 0 THEN DE.overLap ELSE DE.overLap + "," + string(bDE.eventID).
            ELSE
                IF  bDE.StartTime >= DE.EndTime AND bDE.eventID < DE.eventID THEN ASSIGN bDE.overLap = IF LOOKUP(STRING(DE.eventID),bDE.overLap) > 0 THEN bDE.overLap ELSE bDE.overLap + "," + string(DE.eventID).
                ELSE
                    IF  DE.EndTime >= bDE.StartTime AND bDE.eventID > DE.eventID THEN ASSIGN DE.overLap = IF LOOKUP(STRING(bDE.eventID),DE.overLap) > 0 THEN DE.overLap ELSE DE.overLap + "," + string(bDE.eventID).
                    ELSE
                        IF bDE.StartTime <= DE.EndTime AND bDE.StartTime  >= DE.StartTime THEN ASSIGN DE.overLap = IF LOOKUP(STRING(bDE.eventID),DE.overLap) > 0 THEN DE.overLap ELSE bDE.overLap + "," + string(bDE.eventID).
        END.
    END.
    FOR EACH DE WHERE DE.Startdate = currentDay BY DE.StartTime  :
        FOR EACH bDE WHERE bDE.Startdate = currentDay
            AND   bDE.eventID <> DE.eventID
            AND  (bDE.StartTime <= DE.EndTime AND bDE.StartTime  >= DE.StartTime)
            BY bDE.StartTime :
            ASSIGN 
                bDE.overLap =  IF LOOKUP(STRING(bDE.eventID),DE.overLap) > 0 THEN bDE.overLap ELSE bDE.overLap + "," + DE.overLap  .
        END.
    END.
  
  
    FOR EACH DE WHERE DE.Startdate = currentDay BY DE.StartTime   :
        INNER:
        FOR EACH bDE WHERE bDE.Startdate = currentDay  BY bDE.columnID :
            IF LOOKUP(STRING(bDE.eventID),DE.overLap) > 0
                THEN
            DO:
                IF bDE.columnID > DE.issueWidth
                    THEN
                DO:
                    DE.issueWidth = bDE.columnID.
                END.
                ELSE IF bDE.issueWidth > DE.issueWidth
                        THEN
                    DO:
                        DE.issueWidth = bDE.issueWidth.
                    END.
            END.
        END.
        IF DE.issueWidth < DE.columnID THEN DE.issueWidth = DE.columnID.
        DE.issueLeft = DE.columnID.
    END.
  
  
  


END PROCEDURE.


/*                                                                                                             */
/*       if   (DE.StartTime <= bDE.StartTime) and (DE.StartTime < bDE.EndTime)                                 */
/*       then assign DE.overLap = DE.overLap + "," + string(bDE.eventID).                                      */
/*                                                                                                             */
/*       else                                                                                                  */
/*       if  ((DE.StartTime > bDE.StartTime) and (DE.StartTime > bDE.EndTime)) and DE.columnID < bDE.columnID  */
/*       then assign DE.overLap = DE.overLap + "," + string(bDE.eventID).                                      */
/*                                                                                                             */
/*       else                                                                                                  */
/*       if DE.columnID <> bDE.columnID                                                                        */
/*       then  assign DE.overLap = DE.overLap + "," + string(bDE.eventID).                                     */
/*                                                                                                             */


/*  for each DE where DE.Startdate = currentDay by DE.StartTime  :                                                                                                                       */
/*                                                                                                                                                                                       */
/*     for each bDE where bDE.Startdate = currentDay                                                                                                                                     */
/*                  and   bDE.EndTime >= DE.EndTime by bDE.StartTime :                                                                                                                   */
/*                                                                                                                                                                                       */
/*       if ( (((DE.StartTime < bDE.StartTime) and (DE.StartTime < bDE.EndTime)) or ((DE.StartTime > bDE.StartTime) and (DE.StartTime > bDE.EndTime))) and DE.columnID < bDE.columnID )  */
/*       then do:                                                                                                                                                                        */
/*                                                                                                                                                                                       */
/*             assign DE.overLap = DE.overLap + "," + string(bDE.eventID).                                                                                                               */
/*                                                                                                                                                                                       */
/*       end.                                                                                                                                                                            */
/*       else if DE.columnID <> bDE.columnID then do:                                                                                                                                    */
/*           assign DE.overLap = DE.overLap + "," + string(bDE.eventID).                                                                                                                 */
/*       end.                                                                                                                                                                            */
/*       else do:                                                                                                                                                                        */
/*           assign DE.overLap = DE.overLap.                                                                                                                                             */
/*       end.                                                                                                                                                                            */
/*     end.                                                                                                                                                                              */
/*   end.                                                                                                                                                                                */


&ENDIF

&IF DEFINED(EXCLUDE-diaryHeader) = 0 &THEN

PROCEDURE diaryHeader :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/



    {&out}

    /* '<link type="text/css" rel="stylesheet" href="demo.css" />' skip */
 
    '<script type="text/javascript">' skip
' var myWidth=' string(li-blockwidth)  ';' skip
' var myHeight=10;' skip
' var isIE = false;' skip
' var ActionAjax = "' appurl '/time/diaryview.p"' skip
skip

 

/* FIX DIV POSITION */
'function fixTimeDiv(div) ~{' skip
'  var obj = document.getElementById(div);' skip 
'  var cw = document.body.clientWidth;' skip
'  var ch = document.body.clientHeight;' skip
'  var x = document.body.scrollLeft;' skip
'  var y = document.body.scrollTop;' skip
'  var w = obj.offsetWidth;' skip
'  var h = obj.offsetHeight;' skip
/*   'alert( " X = " + x + "  CW = "  + cw  + "  W = " + w + " Total = " + ( cw + x - (cw  +  w - 60)  ) );'  */
'  if ( isIE == true ) ~{' skip
'    obj.style.left = cw + x - (cw +  w - 60);' skip
'    obj.style.top =  15;' skip
'  ~}' skip
'  else ~{' skip
'    obj.style.left = cw + x - (cw + w - 54);' skip
'    obj.style.top = 15;' skip
'  ~}' skip
'~}' skip
skip

/* Select Event */
'function eventSelect(thisRow,actRow,issRow)' skip
' ~{' skip
'    window.open(~'' appurl '/iss/activityupdate.p?mode=updatesingle&issuerowid=~' + thisRow + ~'&actionrowid=~' + actRow + ~'&rowid=~' + issRow + ~'~',~'mywindow~',~'width=600,height=400~');' skip
' ~}' skip
skip


/* SCROLL WINDOW */
'function scrollWindow()' skip
' ~{' skip
'   window.location.hash = "moveHere";' skip
' ~}' skip
skip
'</script>' skip


 /* STYLE ADDITION */
'<STYLE TYPE="text/css">' skip
'<!--' skip
'* html .minwidth ~{' skip
'    border-left:' dayWidth 'px; ' skip
'         _width:' dayWidth 'px; ' skip  /* IE6 hack */
'          width:' dayWidth 'px; ' skip
'      min-width:' dayWidth 'px; ' skip
'~}' skip
'-->' skip
'</STYLE>' skip

'<style type="text/css" media="screen" >' skip
'body ~{' skip
'       width: ' string(li-blockwidth)  skip
'       background-color: #FFFFFF;' skip
'       color: #000000;' skip
'       font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;' skip
'       font-size: 11px;' skip
'       font-style: normal;' skip
'       font-variant: normal;' skip
'       font-weight: normal;' skip
'       margin: 0px 0px 0px 0px;' skip
'~}' skip
'.programtitle ~{' skip
'       background-color: #F2EFE9;' skip
'       color: Blue;' skip
'       text-align: center;' skip
'       width: 100%;' skip
'       word-spacing: 2px;' skip
'       font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;' skip
'       font-weight: bold;' skip
'       font-size: 14px;' skip
'~}' skip
'.button ~{' skip
'       font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;' skip
'       font-weight:normal;' skip
'       font-size:100%;' skip
'       color:#000000;' skip
'       background-color:#ffffff;' skip
'       border-color:#6699ff;' skip
'       margin-top:2pt;' skip
'       margin-left: .5em;' skip
'~}' skip
 skip 

'</style>' skip
  '</head>' skip
 skip
    .
 

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-insertEvents) = 0 &THEN

PROCEDURE insertEvents :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE timeStart     AS DECIMAL    NO-UNDO.
    DEFINE VARIABLE timeSPixels   AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE timeFinish    AS DECIMAL    NO-UNDO.
    DEFINE VARIABLE timeFPixels   AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE daysIssues    AS INTEGER    NO-UNDO.
    DEFINE VARIABLE issueWidth    AS INTEGER    NO-UNDO.
    DEFINE VARIABLE issueLeft     AS INTEGER    NO-UNDO.
    DEFINE VARIABLE startMin      AS INTEGER    NO-UNDO.
    DEFINE VARIABLE startMax      AS INTEGER    NO-UNDO.
    DEFINE VARIABLE offSetCol     AS INTEGER    NO-UNDO.
    DEFINE VARIABLE offSetWidth   AS INTEGER    NO-UNDO.
    DEFINE VARIABLE offRowid      AS ROWID  NO-UNDO.
    DEFINE VARIABLE closedColour  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE userColour    AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE thisEndTime   AS INTEGER    NO-UNDO.

    /* Down to XXX will be iterations through the database... */

    /* assign timeStart = truncate(hourFrom / 100,0) + dec(hourFrom modulo 100 / 60).  */

    DO zx = 1 TO dayRange:

        ASSIGN 
            currentDay = DATE(STRING(viewerDay + (zx - 1)))  /* date(string(viewerDay + (zx - (round(dayRange / 2,0))))) */
            dayNum     = WEEKDAY(currentDay).
        IF NOT incWeekend AND (dayNum = 1 OR dayNum = 7) THEN NEXT.
        IF CAN-FIND(FIRST NewEvents WHERE NewEvents.StartDate = currentDay)
            THEN
        DO:
            {&out} '<td width="'  + dayWidth  + 'px"  style="height:1px;text-align:left;">'  skip.
          
            RUN createEvents.

            FOR EACH DE WHERE DE.StartDate = currentDay BY DE.StartTime :

                IF DE.StartTime + 100 <= hourFrom THEN timeStart = hourFrom + 100. 
                ELSE timeStart = DE.StartTime + 100.
                IF DE.EndTime - 100  >= hourTo THEN timeFinish = hourTo - 100. 
                ELSE timeFinish = DE.EndTime + 100.
                ASSIGN 
                    bubbleNo     = bubbleNo + 1
                    timeStart    = TRUNCATE(timeStart / 100,0) + dec(timeStart MODULO 100 / 60) /* convert time to decimal  */

                    timeSPixels  = STRING(ROUND(((timeStart - (hourFrom / 100)) * (li-blockheight * 2)) - li-offsetheight,2))

                    timeFinish   = TRUNCATE(timeFinish / 100,0) + dec(timeFinish MODULO 100 / 60) /* convert time to decimal  */
                    timeFPixels  = STRING(ROUND(((timeFinish - timeStart) * (li-blockheight * 2)),0))
                    timeFPixels  = IF INTEGER(timeFPixels) < 16 THEN "16" ELSE timeFPixels

                    issueWidth   = ROUND(TRUNCATE(100 / DE.issueWidth,0) - 1,2)                   
                    issueLeft    = (DE.issueleft - 1) * (issueWidth + 1)
                    closedColour = IF DE.IssClosed BEGINS "CLOS" THEN "green" ELSE "red"  
                    userColour   = DE.userColour
                    .

                {&out}  /* CCC */
                '<div id="CCC"  style="display:block;margin-right:5px;position:relative;height:1px;font-size:1px;margin-top:-1px;">' skip .


                {&out}  /* DDD */
                '<div id="DDD"  onselectstart="return false;" onclick="javascript:event.cancelBubble=true;' /*  'eventSelect(~'' + DE.EventRowid  + '~',~'' + NewEvents.issRowid + '~',~'' + NewEvents.actRowid + '~');' */
                '"' 
                ' style="-moz-user-select:none;-khtml-user-select:none;user-select:none;cursor:pointer;position:absolute;font-family:Tahoma;font-size:8pt;white-space:nowrap;'
                ' left:' + string(issueLeft)  + '%;top:' + timeSPixels + 'px;width:' + string(issueWidth) + '%;height:' + timeFPixels + 'px;background-color:#000000;">' skip
             /*                      ^^^^^ hour position                                                               */
                  '<div  id="EEE" ' 
                  ' onclick="eventSelect(~'' + DE.EventRowid  + '~',~'' + DE.issRowid + '~',~'' + DE.actRowid + '~')";'
                  ' onmouseover="this.style.backgroundColor=~'#DCDCDC~';event.cancelBubble=true;"'
                  ' onmouseout="this.style.backgroundColor=~'#FFFFFF~';event.cancelBubble=true;"'
                  ' title="'
          string(DE.Name + " - "  + DE.ID + " - " + timeFormat(DE.StartTime) + " - " + timeFormat(DE.EndTime) +  " - " + DE.EventData ). /* Full details here */
                timeFPixels = STRING(INTEGER(timeFPixels) - 2 ).     /* fix the inner height */
                issueWidth  = IF issueWidth < 70 THEN 98 ELSE 99.    /* fix the inner width */
                {&out}
                    '" style="width:' + string(issueWidth) + '%;margin-top:1px;display:block;height:' 
                    + timeFPixels +
                    /* ^^^^  time spread of box                                                        vvvvv main box border        */
                    'px;background-color:#FFFFFF;border-left:1px solid ' + userColour + ';border-right:2px solid ' + closedColour + ';overflow:hidden;">' skip
                    /*                                                         vvvv time spread of box                  */
                     '<div id="INNER" style="float:left;width:5px;height:' + timeFPixels + 'px;margin-top:0px;' 
                     'background-color:' + userColour + ';font-size:1px;"></div>' skip
                    /*                 ^^^^  big bar colour                 */
                     '<div id="ione" style="float:left;width:1px;background-color:#000000;height:100%;"></div>' skip
                     '<div id="itwo" style="float:left;width:2px;height:100%;"></div>' skip
                     '<div id="ithree" style="padding:1px;">' skip
      string(DE.Name + "<br>" + timeFormat(DE.StartTime) + " - " + timeFormat(DE.EndTime) +  "<br>" + DE.EventData )  skip /* Box detail here */
                    '</div>' skip
                  '</div>' skip
                '</div>' skip.

                {&out}  /* EEE */
                '</div>'  skip.
            END.
            {&out}  '</td>' skip.
 
        END.
        ELSE
        DO:
            {&out}  /* BBB */
            '<td width="'  + dayWidth  + 'px" style="height:1px;text-align:left;">'  skip
              '<div id="BBB" style="display:block;margin-right:5px;position:relative;height:1px;font-size:1px;margin-top:-1px;">'  skip
              '</div>'  skip
            '</td>' skip.
        END.
    END.


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-mainDiary) = 0 &THEN

PROCEDURE mainDiary :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/


    /* START OF PAGE */



    lc-blockheight = STRING(li-blockheight) + "px".

    /* run timeBar. */

    {&out}   /* MAIN OUTER TABLE BEGIN */
    '<table id="Calendar1" cellpadding="0" cellspacing="0" border="0" width="' STRING(li-blockwidth)  'px" >'  skip
    '<tr>'  skip
      '<td valign="top">'   

    .
    {&out} 
    '<div id="CalInner" style="position:absolute;top:0px;left:0px;;border-right:1px solid #000000;">' skip
'<table id="CalendarInner" cellpadding="0" cellspacing="0" border="0" width="100%" style="border-bottom:1px solid #000000;text-align:left;">'  skip
  '<tr>'  skip
    '<td valign="top">'  skip
    '</td>' skip
    '<td width="100%" valign="top">'  skip.

    {&out}   /* AAA */
    '<table cellpadding="0" cellspacing="0" border="0" width="100%" style="border-left:1px solid #000000;">'  skip
        '<tr style="height:1px;background-color:#000000;">' skip .

    RUN insertEvents.

    /*   below here should be constant .....*/


    /* COLUMN DATE ENTRY  */
    {&out}  
    '</tr>' skip
        '<tr style="background-color:#ECE9D8;height:21px;">'  skip.

    DO zx = 1 TO dayRange:
    
        ASSIGN 
            dayDate = viewerDay + int(zx - 1)   /*  viewerDay + int(zx - (round(dayRange / 2,0))) */
            dayNum  = WEEKDAY(dayDate)
            dayDesc = ENTRY(dayNum,dayList)
            dayDesc = IF dayRange > 7 THEN substr(dayDesc,1,4) ELSE dayDesc
            .
        IF NOT incWeekend AND (dayNum = 1 OR dayNum = 7) THEN NEXT.

        {&out}
        '<td class="minwidth" valign="bottom" style="background-color:#ECE9D8;cursor:default;border-right:1px solid #000000;">'.
     
        IF dayDate = TODAY THEN  
            {&out}  '<a name="moveHere" />'  skip
                  '<div   class="minwidth" style="display:block;background-color:yellow;border-bottom:1px solid #000000;text-align:center;height:20px; ">'.

     else {&out}  '<div   class="minwidth" style="display:block;border-bottom:1px solid #000000;text-align:center;height:20px; ">'.

        {&out}         '<div >' skip
             
                    '<div   style="padding:2px;font-family:Tahoma;font-size:10pt;width:90%;">' skip
                      '<div   style="position:relative; font-family:Tahoma;font-size:10pt;float:left;left:-10px;width:30px;">' skip
                        string(day(dayDate))  skip
                      '</div>' skip
                      '<span style="position:relative;left:-18px;">' + dayDesc  + '</span>' skip
                                 '</div>' skip
                    '</div>' skip
                                '</div>' skip
                                '</td>'   .   
    END.

    {&out}
    '</tr>'  .


    /* HOUR CELL ENTRY  */
        
    DO vx = 01 TO 24 :
  
        IF vx * 100 >= hourFrom AND vx * 100 <= hourTo THEN  /* or how ever many hours to do... */
        DO:
  
            {&out}
            '<!-- empty cells -->' skip
          '<tr>'   skip.
  
            DO zx = 0 TO dayRange:
                ASSIGN 
                    dayDate = viewerDay + int(zx)   /*  viewerDay + int(zx - (round(dayRange / 2,0))) */
                    dayNum  = WEEKDAY(dayDate)
                    dayDesc = STRING(viewerDay + zx) + " - " + string(vx).    /* string(viewerDay + (zx - (round(dayRange / 2,0)))) + " - " + string(vx). */
      
                IF NOT incWeekend AND (dayNum = 1 OR dayNum = 7) THEN NEXT.

                {&out}
                '<td onclick="javascript:alert(~''
                dayDesc 
                ':00~');"'.
                IF vx * 100 < coreHourFrom OR vx * 100  > coreHourTo OR dayNum = 1 OR dayNum = 7 THEN
                    {&out} ' onmouseover="this.style.backgroundColor=~'#99FFCC~';"'
                ' onmouseout="this.style.backgroundColor=~'#CCFFCC~';"'
                ' valign="bottom" style="background-color:#CCFFCC;cursor:pointer;border-right:1px solid #000000;height:' lc-blockheight ';">'
                    .
        else
          {&out} ' onmouseover="this.style.backgroundColor=~'#FFED95~';"'
                 ' onmouseout="this.style.backgroundColor=~'#FFFFD5~';"'
                 ' valign="bottom" style="background-color:#FFFFD5;cursor:pointer;border-right:1px solid #000000;height:' lc-blockheight ';">'
                .
                {&out}
                '<div style="display:block;height:14px;border-bottom:1px solid #EAD098;z-index:50;">'
                '<span style="font-size:1px">&nbsp;</span>'
                '</div>'
                '</td>' skip.
            END.
      
            {&out}
            '</tr>' skip 
          '<tr style="height:' lc-blockheight ';">'  skip .
  
            DO zx = 0 TO dayRange:
                ASSIGN 
                    dayDate = viewerDay + int(zx)   /*  viewerDay + int(zx - (round(dayRange / 2,0))) */
                    dayNum  = WEEKDAY(dayDate)
                    dayDesc = STRING(viewerDay + zx) + " - " + string(vx).    /* string(viewerDay + (zx - (round(dayRange / 2,0)))) + " - " + string(vx). */
      
                IF NOT incWeekend AND (dayNum = 1 OR dayNum = 7) THEN NEXT.

                {&out}
                '<td onclick="javascript:alert(~'' 
                dayDesc
                ':30~');"'.


                IF vx * 100 < coreHourFrom OR vx * 100  > coreHourTo OR dayNum = 1 OR dayNum = 7 THEN
                    {&out} ' onmouseover="this.style.backgroundColor=~'#99FFCC~';"'
                ' onmouseout="this.style.backgroundColor=~'#CCFFCC~';"'
                ' valign="bottom" style="background-color:#CCFFCC;cursor:pointer;border-right:1px solid #000000;height:' lc-blockheight ';">'
                    .
        else
          {&out} ' onmouseover="this.style.backgroundColor=~'#FFED95~';"'
                 ' onmouseout="this.style.backgroundColor=~'#FFFFD5~';"'
                 ' valign="bottom" style="background-color:#FFFFD5;cursor:pointer;border-right:1px solid #000000;height:' lc-blockheight ';">'
                .
                {&out}
                '<div style="display:block;height:14px;border-bottom:1px solid #EAD098;z-index:50;">'
                '<span style="font-size:1px">&nbsp;</span>'
                '</div>'
                '</td>' skip.
            END.
   
            {&out}
            '</tr>' skip .
        END.
    END.
        

    {&out}
    '</table>'  skip   
    '</td>'       skip   
  '</tr>'         skip   
'</table>'        skip
'</div>'          skip
'</table>'        skip
    .


    {&out}
    '<!--[if IE ]>' skip
  ' <script>' skip
  '   isIE = true;' skip
  ' </script>' skip
  '<![endif]-->' skip
    /*   '<script type="text/javascript">' skip                            */
    /*   '  fixTimeDiv("fixedTimeDiv");' skip                              */
    /*   '  window.setInterval(~'fixTimeDiv("fixedTimeDiv")~', 500);' skip */
    /*   '  scrollWindow();' skip                                          */
    /*   '</script>'                                                       */
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

    RUN outputHeader.

    {&out} htmlib-OpenHeader("Diary View") skip.
 
    {&out}
    '<style>' skip
           '.hi ~{ color: red; font-size: 10px; margin-left: 15px; font-style: italic;~}' skip
           '</style>' skip 
           '<link href="/style/diary.css" type="text/css" rel="stylesheet" />' skip.

    RUN diaryHeader.

    {&out} htmlib-CloseHeader("") skip.
 
    {&out} '<div id="diaryinner" style="clear:both;" >' skip.
    
    RUN mainDiary.

    {&out} '</div>' skip.

    {&out} htmlib-StartForm("diaryinnerform","post", appurl + '/time/diaryview.p' ) skip.
    {&out} htmlib-Hidden("mode",lc-mode) skip.
    {&out} htmlib-Hidden("submitsource","null") skip.
    {&out} htmlib-Hidden("userList",lc-userList) skip.
    {&out} htmlib-Hidden("viewerDay",lc-viewerDay) skip.
    {&out} htmlib-Hidden("dayRange",lc-dayRange) skip.
    {&out} htmlib-Hidden("coreHourFrom",lc-coreHourFrom) skip.
    {&out} htmlib-Hidden("coreHourTo",lc-coreHourTo) skip.
    {&out} htmlib-Hidden("hourFrom",lc-hourFrom) skip.
    {&out} htmlib-Hidden("hourTo",lc-hourTo) skip.
    {&out} htmlib-Hidden("incWeekend",lc-incWeekend) skip.
    {&out} htmlib-Hidden("saveSettings",lc-saveSettings) skip.
    {&out} htmlib-Hidden("changeColour",lc-changeColour) skip.
    {&out} htmlib-Hidden("viewShowY",lc-viewShowY) skip.
    {&out} htmlib-Hidden("viewShowX",lc-viewShowX) skip.

    {&out} htmlib-EndForm() skip.
 
    {&out} htmlib-Footer() skip.
    

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-refresh-web-request) = 0 &THEN

PROCEDURE refresh-web-request :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    RUN outputHeader.
  
 
    {&out} '<script language="javascript">' skip
         ' parent.RefreshSelf("' lc-mode '", "'
                                lc-viewerDay        '", "'  
                                lc-dayRange         '", "'  
                                lc-coreHourFrom     '", "'  
                                lc-coreHourTo       '", "'  
                                lc-hourFrom         '", "'  
                                lc-hourTo           '", "'  
                                lc-incWeekend       '", "'  
                                lc-viewShowY        '", "'  
                                lc-viewShowX        '", "' 
                                lc-userList         '" ); ' skip
         '</script>' skip  .

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

    '<div id="fixedTimeDiv" style="position:absolute;top:0px;left:0px;width:56px;z-index:100;">' skip

  '<input type="button" onclick="scrollWindow()" value="Today" />'  skip 
  

        '<table cellpadding="0" cellspacing="0" border="0" width="0" style="border-left:1px solid #000000;border-right:1px solid #000000;border-bottom:1px solid #000000;">'  skip
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
        IF vx * 100 > hourFrom AND vx * 100 < hourTo THEN /* or how ever many hours to do... */
        DO:
            IF vx > 11 THEN ASSIGN ap = 2.
            ELSE ASSIGN ap = 1.
            IF vx > 12 THEN ASSIGN yx = vx - 12.
            ELSE ASSIGN yx = vx.

            {&out}

            '<tr style="height:40px;">' skip
            '<td valign="bottom" style="background-color:#ECE9D8;cursor:default;">' skip
             '<div id="idMenuFixedInViewport" >' skip
              '<div style="display:block;border-bottom:1px solid #ACA899;height:39px;text-align:right;">' skip
                '<div style="padding:2px;font-family:Tahoma;font-size:16pt;">' skip
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

&IF DEFINED(EXCLUDE-updateColour) = 0 &THEN

PROCEDURE updateColour :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER pc-input   AS CHARACTER   NO-UNDO.

    DEFINE VARIABLE pc-user             AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE pc-colour           AS CHARACTER   NO-UNDO.

    ASSIGN 
        pc-user = ENTRY(1,pc-input,"|")
        pc-colour = ENTRY(2,pc-input,"|").
              
    FIND FIRST WebStdTime WHERE WebStdTime.CompanyCode = lc-global-company
        AND   WebStdTime.loginID = pc-user NO-ERROR.

    IF AVAILABLE WebStdTime THEN
        ASSIGN WebStdTime.StdColour = pc-colour.

              
END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

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

