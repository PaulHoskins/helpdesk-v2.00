/***********************************************************************

    Program:        sys/webconttime.p
    
    Purpose:        User Maintenance - Contract Time Editor
    
    Notes:
    
    
    When        Who         What
    09/04/2006  phoski      Initial
    10/04/2006  phoski      CompanyCode
    05/09/2015  phoski      DJS Year start problems
    09/04/2017  phoski      Various
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.

DEFINE VARIABLE li-curr-year   AS INTEGER   FORMAT "9999" NO-UNDO.
DEFINE VARIABLE li-end-week    AS INTEGER   FORMAT "99" NO-UNDO.
DEFINE VARIABLE ld-curr-hours  AS DECIMAL   FORMAT "99.99" EXTENT 7 NO-UNDO.
DEFINE VARIABLE lc-day         AS CHARACTER INITIAL "Mon,Tue,Wed,Thu,Fri,Sat,Sun" NO-UNDO.

DEFINE VARIABLE lc-mode        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title       AS CHARACTER NO-UNDO.
                          
DEFINE BUFFER b-valid FOR webuser.
DEFINE BUFFER b-table FOR webuser.
DEFINE BUFFER b-query FOR Customer.

DEFINE VARIABLE lc-search        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-firstrow      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lastrow       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-navigation    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-parameters    AS CHARACTER NO-UNDO.
                          
DEFINE VARIABLE lc-link-label    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit-label  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-url      AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-loginid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-forename      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-surname       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-email         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-usertitle     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-pagename      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-disabled      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-accountnumber AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-jobtitle      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-telephone     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-password      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-userClass     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-usertitleCode AS CHARACTER INITIAL '' NO-UNDO.
DEFINE VARIABLE lc-usertitleDesc AS CHARACTER INITIAL '' NO-UNDO.

DEFINE TEMP-TABLE this-year
    FIELD ty-week-no AS INTEGER
    FIELD ty-hours   AS DECIMAL
    INDEX i-week ty-week-no.

DEFINE TEMP-TABLE this-day
    FIELD td-week-no AS INTEGER
    FIELD td-day-no  AS INTEGER
    FIELD td-hours   AS DECIMAL
    FIELD td-reason  AS CHARACTER
    INDEX i-week td-week-no td-day-no.

DEFINE VARIABLE lc-submitweek   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submitday    AS CHARACTER EXTENT 7 NO-UNDO.
DEFINE VARIABLE lc-submitreason AS CHARACTER EXTENT 7 NO-UNDO.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-Date2Wk) = 0 &THEN

FUNCTION Date2Wk RETURNS CHARACTER
    (INPUT dMyDate AS DATE)  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-dayOfWeek) = 0 &THEN

FUNCTION dayOfWeek RETURNS INTEGER
    (INPUT dMyDate AS DATE)  FORWARD.


&ENDIF


&IF DEFINED(EXCLUDE-Wk2Date) = 0 &THEN

FUNCTION htmlib-SelectDecimalTime RETURNS CHARACTER 
    (pc-name AS CHARACTER,
    pc-selected AS CHARACTER,
    pf-contract AS DECIMAL) FORWARD.

FUNCTION Wk2Date RETURNS CHARACTER
    (cWkYrNo AS CHARACTER) FORWARD.


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

&IF DEFINED(EXCLUDE-ip-build-year) = 0 &THEN

PROCEDURE ip-build-year :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE vx                AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vz                AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-date           AS CHARACTER NO-UNDO.
    DEFINE VARIABLE hi-date           AS DATE      NO-UNDO.
    DEFINE VARIABLE lo-date           AS DATE      NO-UNDO.
    DEFINE VARIABLE std-hours         AS DECIMAL   FORMAT "99.99" NO-UNDO.
    DEFINE VARIABLE tmp-hours         AS DECIMAL   FORMAT "99.99" NO-UNDO.
    DEFINE VARIABLE lc-list-reason-id AS CHARACTER INITIAL "|01|02|03|04|05|10" NO-UNDO.
    DEFINE VARIABLE lc-list-reason    AS CHARACTER INITIAL "Select|BANK|LEAVE|SICK|DOC|DENT|OT" NO-UNDO.
  

    FOR EACH WebStdTime WHERE WebStdTime.CompanyCode = lc-global-company                      
        AND   WebStdTime.LoginID     = lc-loginid                             
        AND   WebStdTime.StdWkYear   = li-curr-year
        NO-LOCK:
        DO vx = 1 TO 7:
            ASSIGN 
                tmp-hours         = ((TRUNCATE(WebStdTime.StdAMEndTime[vx] / 100,0) + dec(WebStdTime.StdAMEndTime[vx] MODULO 100 / 60))          /* convert time to decimal  */ 
                                       - (TRUNCATE(WebStdTime.StdAMStTime[vx] / 100,0) + dec(WebStdTime.StdAMStTime[vx] MODULO 100 / 60)))            /* convert time to decimal  */ 
                                       + ((TRUNCATE(WebStdTime.StdPMEndTime[vx] / 100,0) + dec(WebStdTime.StdPMEndTime[vx] MODULO 100 / 60))          /* convert time to decimal  */                               
                - (TRUNCATE(WebStdTime.StdPMStTime[vx] / 100,0) + dec(WebStdTime.StdPMStTime[vx] MODULO 100 / 60)))            /* convert time to decimal  */ 
                ld-curr-hours[vx] = tmp-hours                                                                                                                                       
                std-hours         = std-hours + tmp-hours.  
        END.
    END.
 

    DO vx = 1 TO li-end-week:
        ASSIGN 
            lc-date = Wk2Date(STRING(STRING(vx,"99") + "-" + string(li-curr-year,"9999")))
            hi-date = DATE(ENTRY(1,lc-date,"|"))
            lo-date = DATE(ENTRY(2,lc-date,"|")).

        CREATE this-year.
        ASSIGN 
            this-year.ty-week-no = vx
            this-year.ty-hours   = std-hours.
       
        FOR EACH WebUserTime WHERE WebUserTime.CompanyCode = lc-global-company                      
            AND   WebUserTime.LoginID     = lc-loginid                             
            AND   WebUserTime.EventDate   >= hi-date
            AND   WebUserTime.EventDate   <= lo-date 
            NO-LOCK:
            CASE WebUserTime.EventType :
                WHEN "BANK"  THEN 
                    ty-hours = ty-hours - WebUserTime.EventHours.
                WHEN "LEAVE" THEN 
                    ty-hours = ty-hours - WebUserTime.EventHours.
                WHEN "SICK"  THEN 
                    ty-hours = ty-hours - WebUserTime.EventHours.
                WHEN "DOC"   THEN 
                    ty-hours = ty-hours - WebUserTime.EventHours.
                WHEN "DENT"  THEN 
                    ty-hours = ty-hours - WebUserTime.EventHours.
                WHEN "OT"    THEN 
                    ty-hours = ty-hours + WebUserTime.EventHours.
            END CASE.
            ASSIGN 
                vz = dayOfWeek(WebUserTime.EventDate).
            CREATE this-day.
            ASSIGN 
                td-week-no = vx
                td-day-no  = vz
                td-hours   = WebUserTime.EventHours 
                td-reason  = ENTRY(LOOKUP(WebUserTime.EventType,lc-list-reason,"|"),lc-list-reason-id,"|")
                .
         
        END.
    END.



END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-ExportAccordion) = 0 &THEN

PROCEDURE ip-ExportAccordion :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    {&out}
        '<style type="text/css">' SKIP
      
        '.clear ~{ /* generic container (i.e. div) for floating buttons */' SKIP
        'overflow: hidden;'    SKIP
        'width: 100%;' SKIP
        '~}' SKIP

        'a.button ~{' SKIP
        'background: transparent url(~'/images/toolbar/bg_button_a.gif~') no-repeat scroll top right;' SKIP
        'color: #444;' SKIP
        'display: block;' SKIP
        'float: left;' SKIP
        'font: normal 12px arial, sans-serif;' SKIP
        'height: 24px;' SKIP
        'margin-right: 6px;' SKIP
        'padding-right: 18px; /* sliding doors padding */' SKIP
        'text-decoration: none;' SKIP
        '~}' SKIP

        'a.button span ~{' SKIP
        'background: transparent url(~'/images/toolbar/bg_button_span1.gif~') no-repeat;' SKIP
        'display: block;' SKIP
        'line-height: 14px;' SKIP
        'padding: 5px 0 5px 18px;' SKIP
        'cursor: pointer;' SKIP
        '~} ' SKIP

        'a.button:active ~{' SKIP
        'background-position: bottom right;' SKIP
        'color: #000;' SKIP
        'outline: none; /* hide dotted outline in Firefox */' SKIP
        'cursor: pointer;' SKIP
        '~}' SKIP

        'a.button:active span ~{' SKIP
        'background-position: bottom left;' SKIP
        'padding: 6px 0 4px 18px; /* push text down 1px */' SKIP
        'cursor: pointer;' SKIP
        '~} ' SKIP

        '.buttonbox ~{' SKIP
        'border: 0px dotted blue;'  SKIP
        'padding: 1px; ' SKIP
        'margin-bottom: 1px;'  SKIP
        'margin-top: 1px; ' SKIP
        'font-weight: bold; ' SKIP
        'background-color: #FFFFFF;' SKIP
        'position: relative;' SKIP
        'width: 100%;' SKIP
        'height: 20px;     ' SKIP
        '~}' SKIP


        '.AccordionTitle, .AccordionTitle1, .AccordionTitle2, .AccordionContent, .AccordionContainer' SKIP
        '~{' SKIP
        'position: relative;' SKIP
        'margin-left:auto;' SKIP
        'margin-right:auto;' SKIP
        'width: 750px; /*changeble*/' SKIP
        'border-bottom: 1px dotted white;' SKIP
        '~}' SKIP


        '.AccordionTitle' SKIP
        '~{' SKIP
        'height: 20px; /*changeble*/' SKIP
        'overflow: hidden;' SKIP
        'cursor: pointer;' SKIP
        'font-family: Verdana; /*changeble*/' SKIP
        'font-size: 12px; /*changeble*/' SKIP
        'font-weight: normal; /*changeble*/' SKIP
        'vertical-align: middle; /*changeble*/' SKIP
        'text-align: center; /*changeble*/' SKIP
        'display: table-cell;' SKIP
        '-moz-user-select: none;' SKIP
        'border-top: none; /*changeble*/' SKIP
        'border-bottom: none; /*changeble*/' SKIP
        'border-left: none; /*changeble*/' SKIP
        'border-right: none; /*changeble*/' SKIP
        'background-color: #0099cc;' SKIP
        'color: White;' SKIP
        '~}' SKIP

        '.AccordionTitle1' SKIP
        '~{' SKIP
        'height: 20px; /*changeble*/' SKIP
        'overflow: hidden;' SKIP
        'cursor: pointer;' SKIP
        'font-family: Verdana; /*changeble*/' SKIP
        'font-size: 12px; /*changeble*/' SKIP
        'font-weight: normal; /*changeble*/' SKIP
        'vertical-align: middle; /*changeble*/' SKIP
        'text-align: center; /*changeble*/' SKIP
        'display: table-cell;' SKIP
        '-moz-user-select: none;' SKIP
        'border-top: none; /*changeble*/' SKIP
        'border-bottom: none; /*changeble*/' SKIP
        'border-left: none; /*changeble*/' SKIP
        'border-right: none; /*changeble*/' SKIP
        'background-color: #E4ECF0;' SKIP
        /*       'background-color: #F5F5F5;' skip */
        'color: Black;' SKIP
        '~}' SKIP

        '.AccordionTitle2' SKIP
        '~{' SKIP
        'height: 20px; /*changeble*/' SKIP
        'overflow: hidden;' SKIP
        'cursor: pointer;' SKIP
        'font-family: Verdana; /*changeble*/' SKIP
        'font-size: 12px; /*changeble*/' SKIP
        'font-weight: normal; /*changeble*/' SKIP
        'vertical-align: middle; /*changeble*/' SKIP
        'text-align: center; /*changeble*/' SKIP
        'display: table-cell;' SKIP
        '-moz-user-select: none;' SKIP
        'border-top: none; /*changeble*/' SKIP
        'border-bottom: none; /*changeble*/' SKIP
        'border-left: none; /*changeble*/' SKIP
        'border-right: none; /*changeble*/' SKIP
        'background-color: #A4C1F4;' SKIP
        'color: Black;' SKIP
        '~}' SKIP

        '.AccordionContent' SKIP
        '~{' SKIP
        'height: 0px;' SKIP
        'overflow: hidden; /*display: none;  */' SKIP
        '~}' SKIP


        '.AccordionContent_' SKIP
        '~{' SKIP
        'height: auto;' SKIP
        '~}' SKIP


        '.AccordionContainer' SKIP
        '~{' SKIP
        'border-top: solid 1px #C1C1C1; /*changeble*/' SKIP
        'border-bottom: solid 1px #C1C1C1; /*changeble*/' SKIP
        'border-left: solid 1px #C1C1C1; /*changeble*/' SKIP
        'border-right: solid 1px #C1C1C1; /*changeble*/' SKIP
        '~}' SKIP


        '.ContentTable' SKIP
        '~{' SKIP
        'width: 100%;' SKIP
        'text-align: center;' SKIP
        'color: White;' SKIP
        '~}' SKIP

        '.ContentCell' SKIP
        '~{' SKIP
        'background-color: #666666;' SKIP
        '~}' SKIP

        '.ContentTable a:link, a:visited' SKIP
        '~{' SKIP
        'color: White;' SKIP
        'text-decoration: none;' SKIP
        '~}' SKIP

        '.ContentTable a:hover' SKIP
        '~{' SKIP
        'color: Yellow;' SKIP
        'text-decoration: none;' SKIP
        '~}' SKIP

        '</style>' SKIP

        '<script type="text/javascript" language="JavaScript">' SKIP
        'var ContentHeight = 0;' SKIP
        'var TimeToSlide = 200;' SKIP
        'var openAccordion = "";' SKIP
        'var inEdit = false;' SKIP
        'var totalAcc = 0 ;' SKIP
        'var firstTime = ' IF lc-mode = 'display' OR lc-mode = 'insert' THEN 'true' ELSE 'false' SKIP
      
        'function runAccordion(index)' SKIP
        '~{' SKIP
        /*
        'if (inEdit) ' skip
        '~{' skip
        ' alert("You have made changes to this week~'s times\n Please update or cancel before continuing" ); ' skip
        ' return; ' skip
        '~}' skip
        */
        'var nID = "Accordion" + index + "Content";' SKIP
        'if(openAccordion == nID)' SKIP
        'nID = "";' SKIP
        'ContentHeight = document.getElementById("Accordion" + index + "Content"+"_").offsetHeight;' SKIP
        'setTimeout("animate(" + new Date().getTime() + "," + TimeToSlide + ",~'"' SKIP
        '+ openAccordion + "~',~'" + nID + "~')", 33);' SKIP
        'openAccordion = nID;' SKIP
        '~}' SKIP

        'function animate(lastTick, timeLeft, closingId, openingId)' SKIP
        '~{' SKIP
        'var curTick = new Date().getTime();' SKIP
        'var elapsedTicks = curTick - lastTick;' SKIP
        'var opening = (openingId == "") ? null : document.getElementById(openingId);' SKIP
        'var closing = (closingId == "") ? null : document.getElementById(closingId);' SKIP
        'if(timeLeft <= elapsedTicks)' SKIP
        '~{' SKIP
        'if(opening != null)' SKIP
        'opening.style.height = ~'auto~';' SKIP
        'if(closing != null)' SKIP
        '~{' SKIP
        '//closing.style.display = ~'none~';' SKIP
        'closing.style.height = ~'0px~';' SKIP
        '~}' SKIP
        'return;' SKIP
        '~}' SKIP
        'timeLeft -= elapsedTicks;' SKIP
        'var newClosedHeight = Math.round((timeLeft/TimeToSlide) * ContentHeight);' SKIP
        'if(opening != null)' SKIP
        '~{' SKIP
        'if(opening.style.display != ~'block~')' SKIP
        'opening.style.display = ~'block~';' SKIP
        'opening.style.height = (ContentHeight - newClosedHeight) + ~'px~';' SKIP
        '~}' SKIP
        'if(closing != null)' SKIP
        'closing.style.height = newClosedHeight + ~'px~';' SKIP
        'setTimeout("animate(" + curTick + "," + timeLeft + ",~'"' SKIP
        '+ closingId + "~',~'" + openingId + "~')", 33);' SKIP
        '~}' SKIP

        'function checkLoad()' SKIP
        '~{' SKIP
        'if (window.onLoad)' SKIP
        '~{' SKIP
        'window.resizeBy(0, totalAcc * 20);' SKIP
        '~}' SKIP
        'else ~{' SKIP
        'setTimeout("checkLoad();", 1000);' SKIP
        '~}' SKIP
        /*         'alert(firstTime);' skip */
        'if ( firstTime )' SKIP
        '~{' SKIP
        'firstTime = false;' SKIP
        'fitWindow();' SKIP
        '~}' SKIP
        '~}' SKIP


        'function FitBody() ~{' SKIP
        'var iSize = getSizeXY();' SKIP
        'var iScroll = getScrollXY();' SKIP
        /*       'window.alert( 'Width = ' + iSize[0]  +  '   Height = ' + iSize[1] );' skip     */
        /*       'window.alert( 'Width = ' + iScroll[0]  +  '   Height = ' + iScroll[1] );' skip */
        'iWidth = iSize[0] + iScroll[0] + 28 ;' SKIP
        'iHeight = iSize[1] + iScroll[1] + iScroll[1] + 20 ;' SKIP
        /*       'window.alert( 'Width = ' + iWidth  +  '   Height = ' + iHeight );' skip */
        'if (iScroll[1] != 0 ) window.resizeTo(iWidth, iHeight);' SKIP
        'self.focus();' SKIP
        '~};' SKIP

        'function getSizeXY() ~{' SKIP
        'var myWidth = 0, myHeight = 0;' SKIP
        'if( typeof( window.innerWidth ) == "number" ) ~{' SKIP
        '//Non-IE' SKIP
        'myWidth = window.innerWidth;' SKIP
        'myHeight = window.innerHeight;' SKIP
        '//window.alert("NON IE");' SKIP
        '~} else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) ~{' SKIP
        '//IE 6+ in standards compliant mode' SKIP
        'myWidth = document.documentElement.clientWidth;' SKIP
        'myHeight = document.documentElement.clientHeight;' SKIP
        '//window.alert("IE 6");' SKIP
        '~} else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) ~{' SKIP
        '//IE 4 compatible' SKIP
        'myWidth = document.body.clientWidth;' SKIP
        'myHeight = document.body.clientHeight;' SKIP
        '//window.alert("IE 4");' SKIP
        '~}' SKIP
        /*       '//window.alert( 'Width = ' + myWidth  +  '   Height = ' + myHeight );' skip */
        'return [ myWidth, myHeight ];' SKIP
        '~}' SKIP

        'function getScrollXY() ~{' SKIP
        'var scrOfX = 0, scrOfY = 0;' SKIP
        'if( typeof( window.pageYOffset ) == "number" ) ~{' SKIP
        '//Netscape compliant' SKIP
        'scrOfY = window.pageYOffset;' SKIP
        'scrOfX = window.pageXOffset;' SKIP
        '~} else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) ~{' SKIP
        '//DOM compliant' SKIP
        'scrOfY = document.body.scrollTop;' SKIP
        'scrOfX = document.body.scrollLeft;' SKIP
        '~} else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) ~{' SKIP
        '//IE6 standards compliant mode' SKIP
        'scrOfY = document.documentElement.scrollTop;' SKIP
        'scrOfX = document.documentElement.scrollLeft;' SKIP
        '~}' SKIP
        /*       '//window.alert( 'Width = ' + scrOfX  +  '   Height = ' + scrOfY );' skip */
        'return [ scrOfX, scrOfY ];' SKIP
        '~}' SKIP
      
        '</script>' SKIP
        .



END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-time-display) = 0 &THEN

PROCEDURE ip-time-display :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE vx                AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vz                AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-h              AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE lc-date           AS CHARACTER NO-UNDO.
    DEFINE VARIABLE hi-date           AS DATE      NO-UNDO.
    DEFINE VARIABLE lo-date           AS DATE      NO-UNDO.
    DEFINE VARIABLE lc-list-reason-id AS CHARACTER INITIAL "|01|02|03|04|05|10" NO-UNDO.
    DEFINE VARIABLE lc-list-reason    AS CHARACTER INITIAL "Select|B.Hol|A/Leave|Sick|Doctor|Dentist|Overtime" NO-UNDO.
    DEFINE VARIABLE lc-saved-reason   AS CHARACTER INITIAL "00" NO-UNDO.
    DEFINE VARIABLE lc-src-hr         AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-src-opt        AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-dst-hr         AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-dst-opt        AS CHARACTER NO-UNDO.
        
    
    FOR EACH this-year :

   
        ASSIGN 
            lc-date = Wk2Date(STRING(STRING(this-year.ty-week-no,"99") + "-" + string(li-curr-year,"9999")))
            hi-date = DATE(ENTRY(1,lc-date,"|")).
           

        {&out}
            '<div onclick="runAccordion(' STRING(this-year.ty-week-no) ');">' SKIP
            '  <div class="AccordionTitle' STRING(IF this-year.ty-week-no MODULO 2 = 0 THEN 1 ELSE 2)  '"  onselectstart="return false;">' SKIP
            '    <span style="float:left;margin-left:20px;text-align:bottom;"><strong>Week ' STRING(this-year.ty-week-no,"99") '</strong> (' REPLACE(lc-date,"|"," - ") ')'
            '    </span><span style="float:right;margin-right:20px;text-align:bottom;">Total Hours: ' STRING(ty-hours,">9.99-") '</span>' SKIP
            '  </div>' SKIP
            '</div>' SKIP
            '<div id="Accordion' STRING(this-year.ty-week-no) 'Content" class="AccordionContent">' SKIP
            '   <div id="Accordion' STRING(this-year.ty-week-no) 'Content_" class="AccordionContent_">' SKIP  .

 
 
        {&out} 
 
         
            '   <div id="weekdiv' STRING(this-year.ty-week-no) '" name="weekdiv' STRING(this-year.ty-week-no) '"  >' SKIP
            '      <table   style="border:5px solid ' IF this-year.ty-week-no MODULO 2 = 0 THEN "#E4ECF0" ELSE "#A4C1F4" ';"  ><tr><td>&nbsp;' SKIP
            '</td>'
            ''
            '      <td>' STRING(ENTRY(1,lc-day)) ' - ' STRING(DAY(hi-date + 0))     '</td>'
            '      <td>' STRING(ENTRY(2,lc-day)) ' - ' STRING(DAY(hi-date + 1)) '</td>' 
            '      <td>' STRING(ENTRY(3,lc-day)) ' - ' STRING(DAY(hi-date + 2)) '</td>' 
            '      <td>' STRING(ENTRY(4,lc-day)) ' - ' STRING(DAY(hi-date + 3)) '</td>' 
            '      <td>' STRING(ENTRY(5,lc-day)) ' - ' STRING(DAY(hi-date + 4)) '</td>' 
            '      <td>' STRING(ENTRY(6,lc-day)) ' - ' STRING(DAY(hi-date + 5)) '</td>' 
            '      <td>' STRING(ENTRY(7,lc-day)) ' - ' STRING(DAY(hi-date + 6)) '</td>'  
            '      </tr>' SKIP
            '      <tr><td width="50px" align="right">Contracted Hours:</td> ' SKIP.
          
        DO vx = 1 TO 7:


            {&out} 
                '     <td>'       STRING(ld-curr-hours[vx],"99.99-") '</td>'  SKIP.
        END.


        {&out}  
            '      <tr><td width="50px" align="right">Change Hours:</td> ' SKIP.

        DO vx = 1 TO 7:

            FIND FIRST this-day 
                WHERE this-day.td-week-no = this-year.ty-week-no
                AND this-day.td-day-no  = vx
                NO-LOCK NO-ERROR.

            lc-h  =   htmlib-SelectDecimalTime(
                "weekno" + string(this-year.ty-week-no) + "-" + string(vx,"99"),
                IF AVAILABLE this-day THEN STRING(this-day.td-hours) ELSE "0.00",
                ld-curr-hours[vx]
                
                ) .
            IF AVAILABLE this-day THEN
            DO:
                IF INTEGER(this-day.td-reason) < 10 
                    THEN ASSIGN lc-h = REPLACE(lc-h,'<select','<select style="color:red;"').
                ELSE ASSIGN lc-h = REPLACE(lc-h,'<select','<select style="color:green;"').
            END.
            {&out} 
                '<td>' lc-h '</td>' SKIP.
        END.

        {&out} 
            '     </tr><tr><td align="right"> Reason:</td> ' SKIP.

        DO vx = 1 TO 7:
         
            FIND FIRST this-day WHERE this-day.td-week-no = this-year.ty-week-no
                AND   this-day.td-day-no  = vx
                NO-LOCK NO-ERROR.

            {&out} 
                '       <td width="40px" >' htmlib-Select("reasonno" + string(this-year.ty-week-no) + "-" + string(vx,"99"),lc-list-reason-id,lc-list-reason,
                IF AVAILABLE this-day THEN this-day.td-reason ELSE "")  '</td>'  SKIP.
              
        END.
        
       
        
        ASSIGN
            lc-src-hr = "weekno" + STRING(this-year.ty-week-no) + "-01".
        lc-src-opt = "reasonno" + STRING(this-year.ty-week-no) + "-01".
        
        
        {&out} SKIP 
            '<script>' SKIP
            'function copyDays' this-year.ty-week-no '() ~{' SKIP
            ' var shr = document.getElementById("' lc-src-hr '").value;' SKIP
            ' var sopt = document.getElementById("' lc-src-opt '").value;' SKIP.
               
        DO vx = 2 TO 7:
            IF ld-curr-hours[vx] = 0.00 THEN NEXT.
            ASSIGN
                lc-dst-hr = "weekno" + STRING(this-year.ty-week-no) + "-" + string(vx,"99").
            lc-dst-opt = "reasonno" + STRING(this-year.ty-week-no)  + "-" + string(vx,"99").
            {&out}
                'document.getElementById("' lc-dst-hr '").value = shr;' SKIP
                'document.getElementById("' lc-dst-opt '").value = sopt;' SKIP
                .
            
           
        END.
             
        {&out} SKIP 
            '~}' SKIP 
            '</script>' SKIP  .
        
        {&out} 
            '</tr><tr><td>&nbsp;</td><td>' SKIP
            '<input class="submitbutton" type="button" onclick="javascript:copyDays' this-year.ty-week-no '();"  value="Copy >>" />' SKIP
            '</td>' SKIP.

        {&out}  
            '</tr>' SKIP
            '<tr><td cellpadding="2px" height="20px" colspan=8 >'
            '<div style="width:100%; height:20px; margin-right:auto; margin-left:auto; ">'
            '<input class="submitbutton" type="button" onclick="javascript:inEdit=false;runAccordion(' STRING(this-year.ty-week-no) ');"  value="Cancel" />' SKIP
     
            '<input class="submitbutton" type="button" onclick="javascript:updateHours(' STRING(this-year.ty-week-no) ');"  value="Update" />' SKIP
            '</div></td>'          
            '     </tr></table></div>' SKIP.
     
        {&out}
          
            ' </div>' SKIP
            '</div>' SKIP.

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
    
    DEFINE VARIABLE lc-object         AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vx                AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-date           AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-list-reason-id AS CHARACTER INITIAL "|01|02|03|04|05|10" NO-UNDO.
    DEFINE VARIABLE lc-list-reason    AS CHARACTER INITIAL "Select|BANK|LEAVE|SICK|DOC|DENT|OT" NO-UNDO.

    DEFINE VARIABLE lc-selacc         AS CHARACTER NO-UNDO.
    

    {lib/checkloggedin.i} 




    ASSIGN 
        lc-selacc          = get-value("selacc")
        lc-mode            = get-value("mode")
        lc-rowid           = get-value("rowid")
        lc-search          = get-value("search")
        lc-firstrow        = get-value("firstrow")
        lc-lastrow         = get-value("lastrow")
        lc-navigation      = get-value("navigation")
        li-curr-year       = INTEGER(get-value("submityear"))
        lc-submitweek      = get-value("submitweek")
        lc-submitday[1]    = get-value("submitday1")
        lc-submitday[2]    = get-value("submitday2")
        lc-submitday[3]    = get-value("submitday3")
        lc-submitday[4]    = get-value("submitday4")
        lc-submitday[5]    = get-value("submitday5")
        lc-submitday[6]    = get-value("submitday6")
        lc-submitday[7]    = get-value("submitday7")
        lc-submitreason[1] = get-value("submitreason1")
        lc-submitreason[2] = get-value("submitreason2")
        lc-submitreason[3] = get-value("submitreason3")
        lc-submitreason[4] = get-value("submitreason4")
        lc-submitreason[5] = get-value("submitreason5")
        lc-submitreason[6] = get-value("submitreason6")
        lc-submitreason[7] = get-value("submitreason7")
        .
    IF li-curr-year = ? OR li-curr-year = 0 THEN li-curr-year = YEAR(TODAY).
  
    ASSIGN  
        li-end-week = INTEGER(ENTRY(2,Date2Wk(DATE("01/01/" + string(li-curr-year + 1 )) - 1) ,"|")). /* work out the number of weeks for this year */
    /*
    **
    ** PH Always 52 
    **
    */
    ASSIGN 
        li-end-week = 52.
    

    IF lc-mode = "" 
        THEN ASSIGN lc-mode       = get-field("savemode")
            lc-rowid      = get-field("saverowid")
            lc-search     = get-value("savesearch")
            lc-firstrow   = get-value("savefirstrow")
            lc-lastrow    = get-value("savelastrow")
            lc-navigation = get-value("savenavigation").

    ASSIGN 
        lc-parameters = "search=" + lc-search +
                           "&firstrow=" + lc-firstrow + 
                           "&lastrow=" + lc-lastrow.
  

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
    ASSIGN 
        lc-loginid = b-table.loginid.
    ASSIGN 
        lc-title        = 'Contracted Times For ' + 
           html-encode(b-table.forename + " " + b-table.surname)
           + " - " + string(li-curr-year) + '</b>'
        lc-link-label   = "Back"
        lc-submit-label = "Update Times".
      
    ASSIGN 
        lc-link-url = appurl + '/sys/webuser.p' + 
                                  '?search=' + lc-search + 
                                  '&firstrow=' + lc-firstrow + 
                                  '&lastrow=' + lc-lastrow + 
                                  '&navigation=refresh' +
                                  '&submityear=' + string(li-curr-year) +
                                  '&selacc=' + lc-selacc +
                                  '&time=' + string(TIME).
   

    IF request_method = "POST" THEN
    DO:
 

        DO vx = 1 TO 7:
 
            ASSIGN 
                lc-object = STRING(INTEGER(lc-submitweek),"99") + "-" + string(li-curr-year)
                lc-date   = ENTRY(1,Wk2Date(lc-object),"|")
                lc-date   = STRING(DATE(lc-date) - 1 + vx).

            IF lc-submitreason[vx] <> "" THEN
            DO:
               
                FIND FIRST WebUserTime WHERE WebUserTime.CompanyCode = lc-global-company                      
                    AND   WebUserTime.LoginID     = lc-loginid                             
                    AND   WebUserTime.EventDate   = date(lc-date)
                    EXCLUSIVE-LOCK NO-ERROR.
               
                 
                IF AVAILABLE WebuserTime THEN
                DO:
                    ASSIGN 
                        WebUserTime.EventHours = dec(lc-submitday[vx])
                        WebUserTime.EventType  = ENTRY(LOOKUP(lc-submitreason[vx],lc-list-reason-id,"|"),lc-list-reason,"|").
                END.
                ELSE
                DO:
                    CREATE WebUserTime.
                    ASSIGN 
                        WebUserTime.CompanyCode = lc-global-company           
                        WebUserTime.LoginID     = lc-loginid                  
                        WebUserTime.EventDate   = DATE(lc-date) 
                        WebUserTime.EventHours  = dec(lc-submitday[vx])
                        WebUserTime.EventType   = ENTRY(LOOKUP(lc-submitreason[vx],lc-list-reason-id,"|"),lc-list-reason,"|").      
                END.
            END.
            ELSE
            DO:
                FIND FIRST WebUserTime WHERE WebUserTime.CompanyCode = lc-global-company                      
                    AND   WebUserTime.LoginID     = lc-loginid                             
                    AND   WebUserTime.EventDate   = date(lc-date)
                    EXCLUSIVE-LOCK NO-ERROR.
                IF AVAILABLE WebUserTime
                    THEN DELETE WebUserTime.
                
            END.
        END.          
    END.



    RUN outputHeader.
    
    {&out} htmlib-OpenHeader(lc-title) SKIP
        htmlib-StartForm("mainform","post", selfurl )
        htmlib-ProgramTitle(lc-title) SKIP.

    RUN ip-ExportAccordion.
/*
    {&out} '<script language="JavaScript" src="/scripts/js/debug.js"></script>' skip
           '<script language="JavaScript" src="/scripts/js/validate.js"></script>' skip.
*/           

    {&out} htmlib-CloseHeader("") SKIP.

    {&out} htmlib-Hidden ("mode", lc-mode) SKIP
        htmlib-Hidden ("selacc", lc-selacc) SKIP
        htmlib-Hidden ("rowid", lc-rowid) SKIP
        htmlib-Hidden ("search", lc-search) SKIP
        htmlib-Hidden ("firstrow", lc-firstrow) SKIP
        htmlib-Hidden ("lastrow", lc-lastrow) SKIP
        htmlib-Hidden ("navigation", lc-navigation) SKIP
        htmlib-Hidden ("nullfield", lc-navigation) SKIP
        htmlib-Hidden ("submityear", STRING(li-curr-year)) SKIP
        htmlib-Hidden ("submitweek", "") SKIP
        htmlib-Hidden ("submitday1", "") SKIP
        htmlib-Hidden ("submitday2", "") SKIP
        htmlib-Hidden ("submitday3", "") SKIP
        htmlib-Hidden ("submitday4", "") SKIP
        htmlib-Hidden ("submitday5", "") SKIP
        htmlib-Hidden ("submitday6", "") SKIP
        htmlib-Hidden ("submitday7", "") SKIP
        htmlib-Hidden ("submitreason1", "") SKIP
        htmlib-Hidden ("submitreason2", "") SKIP
        htmlib-Hidden ("submitreason3", "") SKIP
        htmlib-Hidden ("submitreason4", "") SKIP
        htmlib-Hidden ("submitreason5", "") SKIP
        htmlib-Hidden ("submitreason6", "") SKIP
        htmlib-Hidden ("submitreason7", "") SKIP 
        .
        
    {&out} htmlib-TextLink(lc-link-label,lc-link-url) '<BR><BR>' SKIP.

    
    {&out} SKIP
        htmlib-StartMntTable().
   

    {&out}
        '<tr><td><br><div id="AccordionContainer" class="AccordionContainer">' SKIP.

    RUN ip-build-year.
    RUN ip-time-display.

    {&out} SKIP 
        '</div></td></tr>' SKIP.


    {&out} SKIP 
        htmlib-EndTable()
        SKIP.
    
    
             
    {&out} htmlib-EndForm() SKIP
        htmlib-Footer() SKIP.




    
  
END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-Date2Wk) = 0 &THEN

FUNCTION Date2Wk RETURNS CHARACTER
    (INPUT dMyDate AS DATE) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE cYear    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iWkNo    AS INTEGER   NO-UNDO.
    DEFINE VARIABLE iDayNo   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE dYrBegin AS DATE      NO-UNDO.
    DEFINE VARIABLE WkOne    AS INTEGER   NO-UNDO.
    ASSIGN 
        cYear = ENTRY(3,STRING(dMyDate),"/")
        WkOne = WEEKDAY(DATE("01/01/" + cYear)).
    IF WkOne <= 5 THEN dYrBegin = DATE("01/01/" + cYear).
    ELSE dYrBegin = DATE("01/01/" + cYear) + WkOne.
    ASSIGN 
        iDayNo = INTEGER(dMyDate - dYrBegin) + 1  
        iWkNo  = ROUND(iDayNo / 7,0) + 1 . 
    RETURN STRING(STRING(iDayNo) + "|" + string(iWkNo) + "|" + cYear).

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-dayOfWeek) = 0 &THEN

FUNCTION dayOfWeek RETURNS INTEGER
    (INPUT dMyDate AS DATE) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE rDate   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE WkSt    AS INTEGER   INITIAL 2 NO-UNDO. /* 1=Sun,2=Mon */
    DEFINE VARIABLE DayList AS CHARACTER NO-UNDO.
    IF WkSt = 1 THEN DayList = "1,2,3,4,5,6,7".
    ELSE DayList = "7,1,2,3,4,5,6".

    rDate = WEEKDAY(dMyDate).
    rDate = INTEGER(ENTRY(rDate,DayList)).
    RETURN  rDate.

END FUNCTION.


&ENDIF


&IF DEFINED(EXCLUDE-Wk2Date) = 0 &THEN

FUNCTION htmlib-SelectDecimalTime RETURNS CHARACTER 
    ( pc-name AS CHARACTER ,
    pc-selected AS CHARACTER,
    pf-contract AS DECIMAL ) :
    /*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/    
    DEFINE VARIABLE lc-data     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-loop     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-hour     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-min      AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-value    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-display  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-selected AS CHARACTER NO-UNDO.
    DEFINE VARIABLE pc-value    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE pc-display  AS CHARACTER NO-UNDO.
    
    DO li-hour = 0 TO 23:
        
        DO li-min = 0 TO 59 BY 25:
            lc-value = STRING(li-hour,"99")  + "." + string(li-min,"99").
            IF pc-display = ""
                THEN ASSIGN pc-display = lc-value.
            ELSE ASSIGN pc-display = pc-display + "|" + lc-value.
        END.
       
    END.
    
    ASSIGN 
        pc-value = pc-display.
    

    IF pf-contract > 0 AND DEC(pc-selected) = 0.00 THEN
    DO:
                              
        ASSIGN
            pc-value   = STRING(pf-contract,"99.99") + "|" + pc-value
            pc-display = "All Day|" + pc-display.    
    
    END.
    
    ASSIGN 
        lc-data = '<select class="inputfield" id="' + pc-name + '" name="' + pc-name + '">'.

    DO li-loop = 1 TO NUM-ENTRIES(pc-value,'|'):
        ASSIGN 
            lc-value   = ENTRY(li-loop,pc-value,'|')
            lc-display = ENTRY(li-loop,pc-display,'|').
        IF dec(lc-value) = dec(pc-selected)
            THEN lc-selected = 'selected'.
        ELSE lc-selected = "".
        ASSIGN 
            lc-data = lc-data + 
                       '<option ' +
                       lc-selected + 
                       ' value="' + 
                       lc-value + 
                       '">' + 
                       lc-display +
                       '</option>'.
    END.
  
    ASSIGN 
        lc-data = lc-data + '</select>'.

    RETURN lc-data.

		
END FUNCTION.

FUNCTION Wk2Date RETURNS CHARACTER
    (cWkYrNo AS CHARACTER):
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE cYear    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iWkNo    AS INTEGER   NO-UNDO.
    DEFINE VARIABLE iDayNo   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE iSDayNo  AS DATE      NO-UNDO.
    DEFINE VARIABLE iEDayNo  AS DATE      NO-UNDO.
    DEFINE VARIABLE dYrBegin AS DATE      NO-UNDO.
    DEFINE VARIABLE WkOne    AS INTEGER   NO-UNDO.
    DEFINE VARIABLE WkSt     AS INTEGER   INITIAL 2 NO-UNDO. /* 1=Sun,2=Mon */
    IF INDEX(cWkYrNo,"-") <> 3 THEN RETURN "Format should be xx-xxxx".
    ASSIGN 
        cYear = ENTRY(2,cWkYrNo,"-")
        WkOne = WEEKDAY(DATE("01/01/" + cYear)).
    /*    
    IF WkOne <= 5 THEN dYrBegin = DATE("01/01/" + cYear).
    ELSE dYrBegin = DATE("01/01/" + cYear) + WkOne.
    MESSAGE "PAYLH  dYrBegin ="  dYrBegin " WkOne= " wkOne " cWkYrNo= " cWkYrNo.
    ASSIGN 
        iWkNo  = INTEGER(ENTRY(1,cWkYrNo,"-"))
        iDayNo = (iWkNo * 7) - 7
        iSDayNo = dYrBegin + iDayNo - WkOne + WkSt 
        iEDayNo = iSDayNo + 6 .
    */
    ASSIGN 
        dYrBegin = DATE("01/01/" + cYear).
    
    DO WHILE WEEKDAY(dYrBegin) <> 2:
        dYrBegin = dYrBegin + 1.
    END. 
    ASSIGN 
        iWkNo   = INTEGER(ENTRY(1,cWkYrNo,"-"))
        iDayNo  = (iWkNo * 7) - 7
        iSDayNo = dYrBegin + iDayNo 
        iEDayNo = iSDayNo + 6.
        
    
         
    RETURN STRING(STRING(iSDayNo,"99/99/9999") + "|" + string(iEDayNo,"99/99/9999")).

END FUNCTION.


&ENDIF

