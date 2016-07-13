/***********************************************************************

    Program:        time/diaryevent.p
    
    Purpose:        KB Search
    
    Notes:
    
    
    When        Who         What
    01/09/2010  DJS         Initial
     
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-mess  AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.

DEFINE VARIABLE li-max-lines   AS INTEGER   INITIAL 12 NO-UNDO.
DEFINE VARIABLE lr-first-row   AS ROWID     NO-UNDO.
DEFINE VARIABLE lr-last-row    AS ROWID     NO-UNDO.
DEFINE VARIABLE li-count       AS INTEGER   NO-UNDO.
DEFINE VARIABLE ll-prev        AS LOG       NO-UNDO.
DEFINE VARIABLE ll-next        AS LOG       NO-UNDO.
DEFINE VARIABLE lc-search      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-smessage    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-otherp AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-char        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-nopass      AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-code        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-desc        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-knbcode     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-type        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-type-code   AS CHARACTER
    INITIAL "T|I|C" NO-UNDO.
DEFINE VARIABLE lc-type-desc   AS CHARACTER
    INITIAL "Title|Text|Both Title And Text" NO-UNDO.

DEFINE VARIABLE lc-mainText    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-timeText    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-innerText   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-sliderText  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-otherText   AS CHARACTER NO-UNDO.



DEFINE TEMP-TABLE DE LIKE DiaryEvents
    FIELD idRow      AS ROWID
    FIELD eventID    AS CHARACTER FORMAT "xx"
    FIELD overLap    AS CHARACTER FORMAT "x(9)" 
    FIELD comment    AS CHARACTER
    FIELD columnID   AS INTEGER   FORMAT "z9"
    FIELD issueLeft  AS INTEGER
    FIELD issueWidth AS INTEGER.

DEFINE BUFFER bDE  FOR DE.
DEFINE BUFFER bbDE FOR DE.
 
DEFINE VARIABLE timeSPixels AS CHARACTER NO-UNDO.
DEFINE VARIABLE timeFinish  AS DECIMAL   NO-UNDO.
DEFINE VARIABLE timeFPixels AS CHARACTER NO-UNDO.
DEFINE VARIABLE daysIssues  AS INTEGER   NO-UNDO.
DEFINE VARIABLE issueWidth  AS INTEGER   NO-UNDO.
DEFINE VARIABLE issueLeft   AS INTEGER   NO-UNDO.
DEFINE VARIABLE timeStart   AS DECIMAL   NO-UNDO.
DEFINE VARIABLE timeEnd     AS DECIMAL   NO-UNDO.
DEFINE VARIABLE offSetCol   AS INTEGER   NO-UNDO.
DEFINE VARIABLE offSetWidth AS INTEGER   NO-UNDO.
DEFINE VARIABLE offRowid    AS ROWID     NO-UNDO. 

/*
def var p-cx        as char initial "1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z"  no-undo.

*/
DEFINE VARIABLE p-cx        AS CHARACTER INITIAL "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40" NO-UNDO.
DEFINE VARIABLE p-vx        AS INTEGER   NO-UNDO.
DEFINE VARIABLE p-vz        AS INTEGER   NO-UNDO.
DEFINE VARIABLE p-zx        AS INTEGER   NO-UNDO.


DEFINE BUFFER bDiaryEvents FOR DiaryEvents.
DEFINE BUFFER b-query      FOR DiaryEvents.
DEFINE BUFFER b-search     FOR DiaryEvents.
DEFINE QUERY q FOR b-query SCROLLING.


DEFINE VARIABLE lc-lodate AS CHARACTER.
DEFINE VARIABLE lc-hidate AS CHARACTER.


DEFINE TEMP-TABLE DDEE LIKE DiaryEvents.


/* WORKING VARS */
DEFINE VARIABLE vx           AS INTEGER   NO-UNDO.
DEFINE VARIABLE yx           AS INTEGER   NO-UNDO.
DEFINE VARIABLE zx           AS INTEGER   NO-UNDO.
DEFINE VARIABLE mx           AS INTEGER   NO-UNDO.
DEFINE VARIABLE cx           AS INTEGER   NO-UNDO.
DEFINE VARIABLE AMPM         AS CHARACTER FORMAT "xx" EXTENT 2 INITIAL ["AM","PM"] NO-UNDO.
DEFINE VARIABLE ap           AS INTEGER   NO-UNDO.
DEFINE VARIABLE dayDate      AS DATE      NO-UNDO.
DEFINE VARIABLE bubbleNo     AS INTEGER   INITIAL 1 NO-UNDO.
DEFINE VARIABLE dayWidth     AS CHARACTER NO-UNDO.
                            
DEFINE VARIABLE currentDay   AS DATE      NO-UNDO.  
DEFINE VARIABLE viewerDay    AS DATE      NO-UNDO.
DEFINE VARIABLE dayDesc      AS CHARACTER NO-UNDO.
DEFINE VARIABLE dayNum       AS INTEGER   NO-UNDO.
DEFINE VARIABLE dayList      AS CHARACTER FORMAT "x(9)"
    INITIAL " Sunday , Monday , Tuesday , Wednesday , Thursday , Friday , Saturday ".


/* PARAM VARS */
DEFINE VARIABLE dayRange     AS INTEGER   NO-UNDO.
DEFINE VARIABLE hourFrom     AS INTEGER   NO-UNDO.
DEFINE VARIABLE hourTo       AS INTEGER   NO-UNDO.
DEFINE VARIABLE coreHourFrom AS INTEGER   NO-UNDO.
DEFINE VARIABLE coreHourTo   AS INTEGER   NO-UNDO.
DEFINE VARIABLE incWeekend   AS LOG       NO-UNDO.




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
         HEIGHT             = 14.15
         WIDTH              = 60.57.
/* END WINDOW DEFINITION */
                                                                        */

/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}
{lib/htmlib.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */

FIND FIRST DiaryParams NO-LOCK.
lc-lodate    = STRING(TODAY - 10).  
lc-hidate    = STRING(TODAY) .


FOR EACH issue NO-LOCK
    WHERE issue.CompanyCode = "ouritdept"
    /*           and issue.AccountNumber >= "1"   */
    /*           and issue.AccountNumber <= "999" */
    AND issue.AssignTo >= "A"
    AND issue.AssignTo <= "C"
    /*           and issue.AreaCode >= ""         */
    /*           and issue.AreaCode <= "zzzzzzz"  */
    /*           and issue.CatCode  >= ""         */
    /*           and issue.CatCode  <= "zzzzzzz"  */
    /*                                              */
    AND issue.CreateDate >= date(lc-lodate)  
    AND issue.CreateDate <= date(lc-hidate)  
    :

    CREATE DDEE.
    ASSIGN 
        DDEE.EventData  = Issue.BriefDescription 
        DDEE.ID         = STRING(Issue.IssueNumber)
        DDEE.Name       = Issue.AssignTo   
        DDEE.StartDate  = Issue.AssignDate
        DDEE.StartTime  = INTEGER(   STRING(substr( STRING(Issue.AssignTime ,"HH:MM"),1,2) + substr( STRING(Issue.AssignTime ,"HH:MM"),4,2),"9999" ))
        DDEE.EndDate    = Issue.CompDate
        DDEE.EndTime    = DDEE.StartTime + 100
        DDEE.EventRowid = STRING(ROWID(issue))

        .

END.
     
  

ASSIGN 
    viewerDay    = TODAY  
    dayRange     = 3
    coreHourFrom = INTEGER(substr(DiaryParams.coreHours,1,4))
    coreHourTo   = INTEGER(substr(DiaryParams.coreHours,5,4))
    hourFrom     = 0500
    hourTo       = 2000
    incWeekend   = FALSE
    dayWidth     = STRING(IF dayRange > 15 THEN 75 ELSE ROUND(1200 / dayRange,0))
       
    .
                      
DO zx = 1 TO dayRange:
    ASSIGN 
        currentDay = DATE(STRING(viewerDay + (zx - (ROUND(dayRange / 2,0)))))
        dayNum     = WEEKDAY(currentDay).
    IF dayNum = 1 OR dayNum = 7 THEN cx = cx + 1.
END.
IF cx > 0 THEN dayWidth = STRING(IF dayRange > 15 THEN 85 ELSE ROUND(1200 / (dayRange - cx),0)).
                      


RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-createDaySlider) = 0 &THEN

PROCEDURE createDaySlider :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    lc-sliderText =  
        '<div id="bars" style="margin-top:20px; margin-left:50%; margin-right:50%; width:100%;z-index:100 ">'  +
        '<div  style="margin-left:auto; margin-right:auto; width:250px; ">'  +
        '<div >'  +
        '<img src="C:/Inetpub/wwwroot/TSWeb/images/minus-sign.png" alt="" style="right:20px; float: left;" />'  +
        '</div>'  +
        '<div >'  +
        '<img src="C:/Inetpub/wwwroot/TSWeb/images/plus-sign.png" alt="" style="float: right;" />'  +
        '</div>'  +

        '<div id="track1" style="margin-left:auto; margin-right:auto; width:200px; height:9px;">'  +
        '<div id="track1-left">'  +
        '</div>'  +
        '<div id="handle1" style="width:19px; height:20px;">'  +
        '<img src="C:/Inetpub/wwwroot/TSWeb/images/slider-images-handle.png" alt="" style="float: left;" />'  +
        '</div>'  +
        '</div>'  +
        /*     '<div id="div-1" style="position:absolute; top:0px; left:2px; " >'  +                                                                 */
        /*       '<input type="button" id=printbutton value="Print"    name="ButtonPrint" onclick="javascript:window.print()"  class="button">'  +   */
        /*     '</div>'  +                                                                                                                           */
        /*     '<div id="div-1a" style="position:absolute; top:0px; right:2px; width:57px;" >'  +                                                    */
        /*       '<input   type="button" id=closebutton value="Close"    name="ButtonClose" onclick="javascript:window.close()"  class="button">'  + */
        /*     '</div>'  +                                                                                                                           */
        '</div>'  +
        '</div>'  +
        '</div>'  
        .

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-createEvents) = 0 &THEN

PROCEDURE createEvents :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    p-vx = 0.

    DO WHILE p-vx <> p-vz :
        p-zx = p-zx + 1.
        FOR EACH DE WHERE INTEGER(DE.columnID) < 1
            BREAK BY DE.StartTime :
            IF DE.StartTime >= timeEnd THEN ASSIGN timeEnd     = DE.EndTime
                    DE.columnID = p-zx
                    p-vx        = p-vx + 1.
        END.
        timeEnd = 0.
    END.

    FOR EACH DE BY DE.StartTime  :
        FOR EACH bDE WHERE  bDE.EndTime >= DE.EndTime :
            IF ( (((DE.StartTime < bDE.StartTime) AND (DE.StartTime < bDE.EndTime)) OR ((DE.StartTime > bDE.StartTime) AND (DE.StartTime > bDE.EndTime))) AND DE.columnID <> bDE.columnID )
                THEN 
            DO:
                IF( (((DE.EndTime < bDE.StartTime) AND (DE.EndTime < bDE.EndTime)) OR ((DE.EndTime > bDE.StartTime) AND (DE.EndTime > bDE.EndTime))) AND DE.columnID <> bDE.columnID )
                    THEN 
                DO:
                    IF bDE.columnID > DE.columnID THEN ASSIGN DE.overLap = DE.overLap.
                    ELSE IF bDE.eventID < DE.eventID THEN ASSIGN DE.overLap = DE.overLap + ","  + string(bDE.eventID).
                END.
                ELSE 
                DO:
                    ASSIGN 
                        DE.overLap = DE.overLap + "," + string(bDE.eventID).
                END.
            END.
            ELSE IF DE.columnID <> bDE.columnID THEN 
                DO:
                    ASSIGN 
                        DE.overLap = DE.overLap + "," + string(bDE.eventID).
                END.
                ELSE 
                DO:
                    ASSIGN 
                        DE.overLap = DE.overLap.
                END.
        END.
    END.

    FOR EACH DE BY DE.StartTime :

        INNER:
        FOR EACH bDE :
            IF LOOKUP(bDE.eventID,DE.overLap) > 0 
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


&ENDIF

&IF DEFINED(EXCLUDE-diaryHeader) = 0 &THEN

PROCEDURE diaryHeader :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/


    {&out}

    '<link type="text/css" rel="stylesheet" href="demo.css" />' skip
 
'<script src="C:/Inetpub/wwwroot/TSWeb/javascripts/prototype.js" type="text/javascript"></script>' skip
'<script src="C:/Inetpub/wwwroot/TSWeb/javascripts/slider.js" type="text/javascript"></script>' skip
'<script type="text/javascript">' skip
' var myWidth=1200;' skip
' var myHeight=10;' skip
' var isIE = false;' skip
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
/*   'alert( " Y = " + y + "  CW = "  + cw  + "  W = " + w + " Total = " + ( cw + x - (cw  +  w - 60)  ) );'  */
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
'function eventSelect(newRow)' skip
' ~{' skip
'window.open(~'temp.html~',~'mywindow~',~'width=800,height=600~');' skip
' ~}' skip
skip


/* SCROLL WINDOW */
'function scrollWindow()' skip
' ~{' skip
  'window.location.hash = "moveHere";'
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

'<style type="text/css" media="screen" >' skip

	/* put the left rounded edge on the track */
'	#track1-left ~{' skip
'		position: absolute;' skip
'		width: 5px;' skip
'		height: 9px;' skip
'		background: transparent url(C:/Inetpub/wwwroot/TSWeb/images/slider-images-track-left.png) no-repeat top left;' skip
'		zindex:9999;' skip
'	~}' skip

	/* put the track and the right rounded edge on the track */
'	#track1 ~{' skip
'		background: transparent url(C:/Inetpub/wwwroot/TSWeb/images/slider-images-track-right.png) no-repeat top right;' skip

'	~}' skip
'body ~{' skip
'	background-color: #F2EFE9;' skip
'	color: #000000;' skip
'	font-family: Verdana, Arial, Helvetica, sans-serif;' skip
'	font-size: 11px;' skip
'	font-style: normal;' skip
'	font-variant: normal;' skip
'	font-weight: normal;' skip
'	margin: 0px 0px 0px 0px;' skip
'~}' skip
'.programtitle ~{' skip
'	background-color: #F2EFE9;' skip
'	color: Blue;' skip
'	text-align: center;' skip
'	width: 100%;' skip
'	word-spacing: 2px;' skip
'	font: Verdana;' skip
'	font-weight: bold;' skip
'	font-size: 14px;' skip
'~}' skip
'.button ~{' skip
'	FONT-FAMILY: Verdana, Helvetica, Arial, San-Serif;' skip
'	font-weight:normal;' skip
'	font-size:100%;' skip
'	color:#000000;' skip
'	background-color:#ffffff;' skip
'	border-color:#6699ff;' skip
'	margin-top:2pt;' skip
'	margin-left: .5em;' skip
'~}' skip
 skip 

'</STYLE>' skip
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
    DEFINE VARIABLE timeStart   AS DECIMAL   NO-UNDO.
    DEFINE VARIABLE timeSPixels AS CHARACTER NO-UNDO.
    DEFINE VARIABLE timeFinish  AS DECIMAL   NO-UNDO.
    DEFINE VARIABLE timeFPixels AS CHARACTER NO-UNDO.
    DEFINE VARIABLE daysIssues  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE issueWidth  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE issueLeft   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE startMin    AS INTEGER   NO-UNDO.
    DEFINE VARIABLE startMax    AS INTEGER   NO-UNDO.
    DEFINE VARIABLE offSetCol   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE offSetWidth AS INTEGER   NO-UNDO.
    DEFINE VARIABLE offRowid    AS ROWID     NO-UNDO.


    /* Down to XXX will be iterations through the database... */

    /* assign timeStart = truncate(hourFrom / 100,0) + dec(hourFrom modulo 100 / 60).  */

    DO zx = 1 TO dayRange:

        ASSIGN 
            currentDay = DATE(STRING(viewerDay + (zx - (ROUND(dayRange / 2,0)))))
            dayNum     = WEEKDAY(currentDay).
 

        IF dayNum = 1 OR dayNum = 7 THEN NEXT.


        IF CAN-FIND(FIRST DDEE WHERE DDEE.StartDate = currentDay)
            THEN
        DO:
            lc-innerText = lc-innerText +  /* CCC */
                '<td width="'  + dayWidth  + 'px"  style="height:1px;text-align:left;">'  .
    

            EMPTY TEMP-TABLE DE NO-ERROR.
            p-vx = 0.
            p-vz = 0.
            p-zx = 0.

  
            FOR EACH DDEE NO-LOCK 
                WHERE DDEE.StartDate = currentDay
                BREAK BY DDEE.StartTime :
          
                CREATE DE.
                BUFFER-COPY DDEE TO DE.

                ASSIGN 
                    p-vx          = p-vx + 1
                    DE.eventID    = ENTRY(p-vx,p-cx)
                    DE.issueWidth = 1.

                IF FIRST(DDEE.StartTime) 
                    THEN ASSIGN timeEnd     = DDEE.EndTime
                        DE.columnID = 1 .
                ELSE ASSIGN p-vz = p-vz + 1.
            END.

            RUN createEvents.
  
            FOR EACH DE BY DE.columnID:
  
                ASSIGN 
                    bubbleNo    = bubbleNo + 1
                    timeStart   = TRUNCATE(DE.StartTime / 100,0) + dec(DE.StartTime MODULO 100 / 60) /* convert time to decimal  */
                    timeSPixels = STRING(((timeStart - (hourFrom / 100)) * 40) - 18)
                    timeFinish  = TRUNCATE(DE.EndTime / 100,0) + dec(DE.EndTime MODULO 100 / 60) /* convert time to decimal  */
                    timeFPixels = STRING(((timeFinish - timeStart) * 40)  )                 
                    issueWidth  = TRUNCATE(100 / DE.issueWidth,0) - 1                   
                    issueLeft   = (DE.issueleft - 1) * (issueWidth + 1)
                    .
 
                lc-innerText = lc-innerText +  /* CCC */
                    '<div id="AA"  style="display:block;margin-right:5px;position:relative;height:1px;font-size:1px;margin-top:-1px;">'  .


                lc-innerText = lc-innerText +  /* DDD */
                    '<div id="BB" onselectstart="return false;" onclick="javascript:event.cancelBubble=true;eventSelect("'   + DE.EventRowid  +  '");"' +
                    ' style="-moz-user-select:none;-khtml-user-select:none;user-select:none;cursor:pointer;' +
                    ' position:absolute;font-family:Tahoma;font-size:8pt;white-space:no-wrap;' +

                    'left:' + string(issueLeft)  + '%;top:' + timeSPixels + 'px;width:' + string(issueWidth) + '%;height:' + timeFPixels + 'px;background-color:#000000;">' +

                    /*                      ^^^^^ hour position                                                               */
                    '<div id="CC" ' +
                    ' onmouseover="this.style.backgroundColor=' +
                    '#DCDCDC' + 
                    ';event.cancelBubble=true;"' +
                    ' onmouseout="this.style.backgroundColor=' + 
                    '#FFFFFF' + 
                    ';event.cancelBubble=true;"' +
                    ' title="' +
                    string(DE.Name + " - " + timeFormat(DE.StartTime) + " - " + timeFormat(DE.EndTime) +  " - " + DE.EventData ) /* Full details here */
                    .
                timeFPixels = STRING(INTEGER(timeFPixels) - 2 ). /* fix the inner height */
                issueWidth  = IF issueWidth < 70 THEN 98 ELSE 99.                  /* fix the inner width */
                lc-innerText = lc-innerText +
                    '" style="width:' + string(issueWidth) + '%;margin-top:1px;display:block;height:' + timeFPixels + 'px;background-color:#FFFFFF;border-left:1px solid #000000;border-right:1px solid #000000;overflow:hidden;">' +
                    /*                                     vvvv^^^^  time spread of box                  */
                    '<div id="INNER" style="float:left;width:5px;height:' + timeFPixels + 'px;margin-top:0px;background-color:Blue;font-size:1px;"></div>' +
                    '<div style="float:left;width:1px;background-color:#000000;height:100%;"></div>' +
                    '<div style="float:left;width:2px;height:100%;"></div>' +
                    '<div style="padding:1px;">' +
                    string(DE.Name + "<br>" + timeFormat(DE.StartTime) + " - " + timeFormat(DE.EndTime) +  "<br>" + DE.EventData )  + /* Box detail here */
                    '</div>' +
                    '</div>' +
                    '</div>' .

                lc-innerText = lc-innerText +  /* EEE */
                    '</div>'  .
              
            END.
            lc-innerText = lc-innerText +  '</td>' .
 
        END.
        ELSE
        DO:
            lc-innerText = lc-innerText +  /* BBB */
                '<td width="'  + dayWidth  + 'px" style="height:1px;text-align:left;">'  +
                '<div style="display:block;margin-right:5px;position:relative;height:1px;font-size:1px;margin-top:-1px;">'  +
                '</div>'  +
                '</td>' .
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

 

    RUN timeBar.

    lc-innerText =   /* MAIN OUTER TABLE BEGIN */
        '<table id="Calendar1" cellpadding="0" cellspacing="0" border="0" width="1200px" >'  +
        '<tr>'  +
        '<td valign="top">'   

        .
    lc-innerText = lc-innerText + 
        '<div style="position:absolute;top:39px;left:44px;;border-right:1px solid #000000;">' +
        '<table id="CalendarInner" cellpadding="0" cellspacing="0" border="0" width="100%" style="border-bottom:1px solid #000000;text-align:left;">'  +
        '<tr>'  +
        '<td valign="top">'  +
        '</td>' +
        '<td width="100%" valign="top">'  .

    lc-innerText = lc-innerText +   /* AAA */
        '<table cellpadding="0" cellspacing="0" border="0" width="100%" style="border-left:1px solid #000000;">'  +
        '<tr style="height:1px;background-color:#000000;">'  .

    RUN insertEvents.

    /*   below here should be constant .....*/


    /* COLUMN DATE ENTRY  */
    lc-mainText =  
        '</tr>' +
        '<tr style="background-color:#ECE9D8;height:21px;">'  .

    DO zx = 1 TO dayRange:
    
        ASSIGN 
            dayDate = viewerDay + int(zx - (ROUND(dayRange / 2,0)))
            dayNum  = WEEKDAY(dayDate)
            dayDesc = ENTRY(dayNum,dayList)
            dayDesc = IF dayRange > 9 THEN substr(dayDesc,1,4) ELSE dayDesc
            .
        IF dayNum = 1 OR dayNum = 7 THEN NEXT.

        lc-mainText = lc-mainText +
            '<td valign="bottom" style="background-color:#ECE9D8;cursor:default;border-right:1px solid #000000; ">'.
     
        IF dayDate = TODAY THEN  
            lc-mainText = lc-mainText +  '<a name="moveHere" />'  +
                '<div id="two" class="minwidth" style="display:block;background-color:yellow;border-bottom:1px solid #000000;text-align:center;height:20px; ">'.

        ELSE lc-mainText = lc-mainText +  '<div id="two" class="minwidth" style="display:block;border-bottom:1px solid #000000;text-align:center;height:20px; ">'.

        lc-mainText = lc-mainText +         '<div >' +
             
            '<div id="four" style="padding:2px;font-family:Tahoma;font-size:10pt;width:90%">' +
            '<div id="three" style="position:relative; font-family:Tahoma;font-size:10pt;float:left;left:-12px;width:30px">' +
            string(DAY(dayDate))  +
            '</div>' +
            '<span style="position:relative;left:-20px;">' + dayDesc  + '</span>' +
            '</div>' +
            '</div>' +
            '</div>' +
            '</td>'   .   
    END.

    lc-mainText = lc-mainText +
        '</tr>'  .


    /* HOUR CELL ENTRY  */
        
    DO vx = 01 TO 24 :
  
        IF vx * 100 > hourFrom AND vx * 100 < hourTo THEN  /* or how ever many hours to do... */
        DO:
  
            lc-mainText = lc-mainText +
                '<!-- empty cells -->' +
                '<tr>'   .
  
            DO zx = 1 TO dayRange:
                ASSIGN 
                    dayDate = viewerDay + int(zx - (ROUND(dayRange / 2,0)))
                    dayNum  = WEEKDAY(dayDate)
                    dayDesc = STRING(viewerDay + (zx - (ROUND(dayRange / 2,0)))) + " - " + string(vx).
      
                IF dayNum = 1 OR dayNum = 7 THEN NEXT.

                lc-mainText = lc-mainText +
                    '<td onclick="javascript:alert(' + 
                    '\"' +  dayDesc  + ':00' + 
                    '\"' + 
                    ');"'.
             
                IF vx * 100 < coreHourFrom OR vx * 100  > coreHourTo OR dayNum = 1 OR dayNum = 7 THEN
                    lc-mainText = lc-mainText + ' onmouseover="this.style.backgroundColor=' + 
                        '#99FFCC' + 
                        ';"' +
                        ' onmouseout="this.style.backgroundColor=' + 
                        '#CCFFCC' + 
                        ';"' +
                        ' valign="bottom" style="background-color:#CCFFCC;cursor:pointer;cursor:hand;border-right:1px solid #000000;height:20px;">' 
                        .
                ELSE
                    lc-mainText = lc-mainText + ' onmouseover="this.style.backgroundColor=' + 
                        '#FFED95' + 
                        ';"' +
                        ' onmouseout="this.style.backgroundColor=' + 
                        '#FFFFD5' + 
                        ';"' +
                        ' valign="bottom" style="background-color:#FFFFD5;cursor:pointer;cursor:hand;border-right:1px solid #000000;height:20px;">' 
                        .
                lc-mainText = lc-mainText +
                    '<div style="display:block;height:14px;border-bottom:1px solid #EAD098;z-index:50;">' +
                    '<span style="font-size:1px">&nbsp;</span>' +
                    '</div>' +
                    '</td>'  .
            END.
      
            lc-mainText = lc-mainText +
                '</tr>'  + 
                '<tr style="height:20px;">'  .
  
            DO zx = 1 TO dayRange:
                ASSIGN 
                    dayDate = viewerDay + int(zx - (ROUND(dayRange / 2,0)))
                    dayNum  = WEEKDAY(dayDate)
                    dayDesc = STRING(viewerDay + (zx - (ROUND(dayRange / 2,0)))) + " - " + string(vx).
      
                IF dayNum = 1 OR dayNum = 7 THEN NEXT.

                lc-mainText = lc-mainText +
                    '<td onclick="javascript:alert(' + 
                    '\"' +  dayDesc  + ':30' + 
                    '\"' + 
                    ');"'.
 

                IF vx * 100 < coreHourFrom OR vx * 100  > coreHourTo OR dayNum = 1 OR dayNum = 7 THEN
                    lc-mainText = lc-mainText + ' onmouseover="this.style.backgroundColor=' + 
                        '#99FFCC' + 
                        ';"' +
                        ' onmouseout="this.style.backgroundColor=' + 
                        '#CCFFCC' + 
                        ' ;"' +
                        ' valign="bottom" style="background-color:#CCFFCC;cursor:pointer;cursor:hand;border-right:1px solid #000000;height:20px;">'
                        .
                ELSE
                    lc-mainText = lc-mainText + ' onmouseover="this.style.backgroundColor=' + 
                        '#FFED95' + 
                        ';"' +
                        ' onmouseout="this.style.backgroundColor=' + 
                        '#FFFFD5' + 
                        ';"' +
                        ' valign="bottom" style="background-color:#FFFFD5;cursor:pointer;cursor:hand;border-right:1px solid #000000;height:20px;">' 
                        .
                lc-mainText = lc-mainText +
                    '<div style="display:block;height:14px;border-bottom:1px solid #EAD098;z-index:50;">' +
                    '<span style="font-size:1px">&nbsp;</span>' +
                    '</div>' +
                    '</td>'  .
            END.
   
            lc-mainText = lc-mainText +
                '</tr>'  .
        END.
    END.
        

    lc-mainText = lc-mainText +
        '</table>'   +   
        '</td>'        +   
        '</tr>'          +   
        '</table>'         +
        '</div>'           +
        '</table>'        
        .




    lc-mainText = lc-mainText +

        '<!--[if IE ]>'  +
        ' <script>'  +
        '   isIE = true;'  +
        ' </script>'  +
        '<![endif]-->'  +
        '<script type="text/javascript">'  +
        '  fixTimeDiv("fixedTimeDiv");'  +
        '  window.setInterval(~'fixTimeDiv("fixedTimeDiv")~', 50);'  +
        '  scrollWindow();'  +
        '</script>'  
        .

    lc-mainText = lc-mainText +
    
        '<script type="text/javascript" language="javascript">'  +
        '// <![CDATA['  +
        '// horizontal slider control with preset values'  +
        'new Control.Slider(~'handle1~', ~'track1~', ~{'  +
        'range: $R(1, 41),'  +
        'values: [1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 25, 31, 41],'  +
        'sliderValue: 15, // wont work if set to 0 due to a bug(?) in script.aculo.us'  +
        'onSlide: function(v)~{ $(~'debug1~').innerHTML = ~'slide: ~' + v ~},'  +
        'onChange: function(v)~{ $(~'debug1~').innerHTML = ~'changed: ~' + v ~},'  +
        '~});'  +
        '// ]]>'  +
        '</script>' 

        .

/* output to "c:\temp\djs.txt".      */
/* put unformatted lc-mainText skip. */
/* output close.                     */
/*                                   */

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
  

    {lib/checkloggedin.i}

   
    ASSIGN 
        lc-search     = get-value("search")
        lc-firstrow   = get-value("firstrow")
        lc-lastrow    = get-value("lastrow")
        lc-navigation = get-value("navigation").
    
    ASSIGN 
        lc-parameters = "search=" + lc-search +
                           "&firstrow=" + lc-firstrow + 
                           "&lastrow=" + lc-lastrow.

    
    
    ASSIGN 
        lc-char = htmlib-GetAttr('system','MNTNoLinesDown').
    
    /*     assign li-max-lines = int(lc-char) no-error. */
    /*     if error-status:error                        */
    /*     or li-max-lines < 1                          */
    /*     or li-max-lines = ? then li-max-lines = 12.  */
    /*                                                  */
    /*     assign                                       */
    /*         li-max-lines = 5.                        */
    /*                                                  */
    /*     run com-GetKBSection(lc-global-company,      */
    /*                          output lc-code,         */
    /*                          output lc-desc).        */
    /*                                                  */
    /*     assign                                       */
    /*         lc-code = "ALL|" + lc-code               */
    /*         lc-desc = "All Sections|" + lc-desc.     */
    /*                                                  */
    /*     assign                                       */
    /*         lc-knbcode = get-value("knbcode")        */
    /*         lc-type    = get-value("type").          */


    RUN outputHeader.
    


    {&out}
    '<style>' skip
           '.hi ~{ color: red; font-size: 10px; margin-left: 15px; font-style: italic;~}' skip
           '</style>' skip 
           '<link href="/style/diary.css" type="text/css" rel="stylesheet" />' skip.

    RUN diaryHeader.



    {&out} htmlib-Header("Diary View") skip.

    {&out} htmlib-JScript-Maintenance() skip.

    {&out} htmlib-StartForm("mainform","post", appurl + '/time/diary01.p' ) skip.

    {&out} htmlib-ProgramTitle("Engineers Time Recording") skip.
    
 
    {&out}

    '<div id="diaryscreen" style="clear: both;" class="toolbar">&nbsp;' skip
    ' <br><br><br><br>' skip
    '</div>' skip
      '<iframe id="diaryinner" name="diaryinner" src="" width="800px" height="600px" >' skip
        '</iframe >' skip
    .



    {&out}
    '<script type="text/javascript" language="javascript">' skip
  ' <!-- ' skip
    .
    
    RUN mainDiary.

    {&out}
    'function populateIframe() ~{' skip
  'var ifrm = document.getElementById("diaryinner");' skip
  'ifrm = (ifrm.contentWindow) ? ifrm.contentWindow : (ifrm.contentDocument.document) ? ifrm.contentDocument.document : ifrm.contentDocument;' skip
  'ifrm.document.open();' skip
  'ifrm.document.write(~'' lc-sliderText " " lc-timeText " " lc-innerText  " " lc-mainText
  '~');' skip
  'ifrm.document.close();' skip
  '~}' skip
  'populateIframe(); ' skip
  ' // -->' skip 
  '</script>' skip
    .



 
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

 

    /*  run createDaySlider. */

    lc-timeText =

        '<div id="fixedTimeDiv" style="position:absolute;top:0px;left:0px;width:54px;z-index:100;">' +

        '<input type="button" onclick="scrollWindow()" value="Today" />'  + 
  

        '<table cellpadding="0" cellspacing="0" border="0" width="0" style="border-left:1px solid #000000;border-right:1px solid #000000;border-bottom:1px solid #000000;">'  +
        '<tr style="height:1px;background-color:#000000;">'  +
        '<td>'  +
        '</td>' +
        '</tr>'  +
        '<tr style="height:21px;">'  +
        '<td valign="bottom" style="background-color:#ECE9D8;cursor:default;">'  +
        '<div style="display:block;border-bottom:1px solid #000000;text-align:right;">'  + 
        '<div style="padding:2px;font-size:6pt;">' +
        '&nbsp;' +
        '</div>'  +
        '</div>'  +
        '</td>'  +
        '</tr>'  .

    DO vx = 01 TO 24 :
        IF vx * 100 > hourFrom AND vx * 100 < hourTo THEN /* or how ever many hours to do... */
        DO:
            IF vx > 11 THEN ASSIGN ap = 2.
            ELSE ASSIGN ap = 1.
            IF vx > 12 THEN ASSIGN yx = vx - 12.
            ELSE ASSIGN yx = vx.

            lc-timeText = lc-timeText +

                '<tr style="height:40px;">' +
                '<td valign="bottom" style="background-color:#ECE9D8;cursor:default;">' +
                '<div id="idMenuFixedInViewport" >' +
                '<div style="display:block;border-bottom:1px solid #ACA899;height:39px;text-align:right;">' +
                '<div style="padding:2px;font-family:Tahoma;font-size:16pt;">' +
                string(yx)   +
                '<span style="font-size:10px; vertical-align: super; ">&nbsp;' +
                string(AMPM[ap])    +
                '</span>' +
                '</div>' +
                '</div>' +
                '</div>' +
                '</td>' +
                '</tr>'  .
        END.
    END.

    lc-timeText = lc-timeText +
        '</table>' +
        '</div>'
        .



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

    DEFINE BUFFER knbText FOR knbText.  
    DEFINE VARIABLE li-count  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-found  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-char   AS CHARACTER NO-UNDO.

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
        mm = substr(STRING(param1,"9999"),3,2).
    RETURN STRING(STRING(hh) + ":" + string(mm) ).

END FUNCTION.


&ENDIF

