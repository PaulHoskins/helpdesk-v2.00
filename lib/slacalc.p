/***********************************************************************

    Program:        lib/slacalc.p
    
    Purpose:        Calculate SLA Schedule         
    
    Notes:
    
    
    When        Who         What
    06/05/2006  phoski      Initial
    18/05/2014  phoski      Date/Time Fields
    
***********************************************************************/
{lib/slatt.i}

DEFINE INPUT PARAMETER pd-Date     AS DATE                 NO-UNDO.
DEFINE INPUT PARAMETER pi-Time     AS INTEGER              NO-UNDO.
DEFINE INPUT PARAMETER pf-SLAID    LIKE slahead.SLAID      NO-UNDO.
DEFINE OUTPUT PARAMETER table FOR tt-sla-sched.


DEFINE BUFFER slahead FOR slahead.
DEFINE BUFFER company FOR company.


DEFINE VARIABLE ll-work-day       AS LOG       EXTENT 7 NO-UNDO.
DEFINE VARIABLE li-sla-begin      AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-sla-end        AS INTEGER   NO-UNDO.
DEFINE VARIABLE ll-office         AS LOG       NO-UNDO.
DEFINE VARIABLE li-minutes        AS INTEGER   NO-UNDO.

DEFINE VARIABLE ld-start          AS DATE      NO-UNDO.
DEFINE VARIABLE li-start          AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-level          AS INTEGER   NO-UNDO.


DEFINE VARIABLE li-loop           AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-mins-end-day   AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-mins-begin-day AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-seconds        AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-min-count      AS INTEGER   NO-UNDO.
DEFINE VARIABLE ld-day-count      AS DATE      NO-UNDO.
DEFINE VARIABLE li-counter        AS INTEGER   NO-UNDO.
DEFINE VARIABLE ldt-Level2        AS DATETIME  NO-UNDO.
DEFINE VARIABLE ldt-Amber2        AS DATETIME  NO-UNDO.
DEFINE VARIABLE li-Mill           AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-dt             AS CHARACTER NO-UNDO.




DEFINE BUFFER tt FOR tt-sla-sched.
DEFINE BUFFER tb FOR tt-sla-sched.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-fnConvertHourMin) = 0 &THEN

FUNCTION fnConvertHourMin RETURNS INTEGER
    ( pi-Hours    AS INTEGER,
    pi-Mins     AS INTEGER )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-fnInitialise) = 0 &THEN

FUNCTION fnInitialise RETURNS LOGICAL
    ( /* parameter-definitions */ )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-fnSeconds) = 0 &THEN

FUNCTION fnSeconds RETURNS INTEGER
    ( pc-Unit AS CHARACTER,
    pi-Unit AS INTEGER )  FORWARD.


&ENDIF


/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 15
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */

 




/* ***************************  Main Block  *************************** */


FIND slahead WHERE slahead.SLAID = pf-SLAID NO-LOCK NO-ERROR.
IF NOT AVAILABLE slahead THEN RETURN.
IF slahead.RespDesc[1] = "" THEN RETURN.
FIND company WHERE company.CompanyCode = slahead.CompanyCode NO-LOCK.

DYNAMIC-FUNCTION('fnInitialise':U).

ASSIGN
    ld-start = pd-date
    li-start = TRUNCATE(pi-time / 60,0) * 60.

/*
***
*** Office hours and the SLA starts after office close
*** then set the begin date/time to tomorrow at opening time
***
*/
IF ll-office THEN
DO:
    IF li-start > li-sla-end 
        THEN ASSIGN
            ld-start = ld-start + 1
            li-start = li-sla-begin.  
    IF li-start < li-sla-begin 
        THEN ASSIGN 
            li-start = li-sla-begin.
END.


DO WHILE TRUE:
    IF ll-work-day[WEEKDAY(ld-start)] THEN LEAVE.
    /*
    ***
    *** Not a working day so need to jump forward 
    ***
    */
    ASSIGN 
        ld-start = ld-start + 1.
    IF ll-office 
        THEN li-start = li-sla-begin.
    ELSE li-start = 0.
END.


CREATE tt.
ASSIGN 
    tt.level = 0
    tt.note  = "begin"
    tt.sDate = ld-start
    tt.STime = li-start.

/*
***
*** End of day in minutes
***
*/
ASSIGN
    li-mins-end-day   = fnSeconds("DAY",1) / 60
    li-mins-begin-day = 0.
IF ll-office
    THEN ASSIGN
        li-mins-end-day   = li-sla-end / 60
        li-mins-begin-day = li-sla-begin / 60.

DO li-level = 1 TO 10:
    IF slahead.RespDesc[li-level] = "" THEN LEAVE.

    FIND tt
        WHERE tt.Level = 
        ( IF slahead.AlertBase = "ISSUE" THEN 0 ELSE li-level - 1 ).

    CREATE tb.
    ASSIGN 
        tb.Level = li-level
        tb.note  = slahead.RespDesc[li-level] + ' ' + 
                      slahead.RespUnit[li-level] + ' ' + 
                      string(slahead.RespTime[li-level]) + ' prev = ' 
                      + string(tt.sdate)
                      + ' ' + string(tt.stime,'hh:mm:ss')
        tb.Sdate = tt.Sdate
        tb.STime = tt.Stime.


    /*
    ***
    *** SLA based on 24 hour clock
    ***
    */
    IF NOT ll-office 
        OR ( ll-office AND CAN-DO("DAY,WEEK",slahead.RespUnit[li-level]) = FALSE ) THEN
    DO:
        li-minutes = ( fnSeconds(slahead.RespUnit[li-level],
            slahead.RespTime[li-level]) ) / 60.
    
        ASSIGN 
            tb.note = tb.note + " mi=" + string(li-minutes).
    
        ASSIGN
            li-min-count = tb.STime / 60
            ld-day-count = tb.SDate.
    
        DO li-loop = 1 TO li-minutes:
            ASSIGN 
                li-min-count = li-min-count + 1.   
            IF li-min-count > li-mins-end-day THEN
            DO:
                ASSIGN
                    li-min-count = li-mins-begin-day.
                DO WHILE TRUE:
                    ASSIGN 
                        ld-day-count = ld-day-count + 1.
                    IF ll-work-day[WEEKDAY(ld-day-count)] THEN LEAVE.
                END.
    
            END.
    
        END.
        ASSIGN 
            tb.note = tb.note + " Calc = " + 
            string(ld-day-count,'99/99/9999') + ' ' +  
            string(li-min-count * 60,'hh:mm:ss').
    
        ASSIGN 
            tb.Sdate = ld-day-count
            tb.STime = li-min-count * 60.
    
    END.
    ELSE
    DO:
        ASSIGN
            li-min-count = tb.STime / 60
            ld-day-count = tb.SDate.

        IF CAN-DO("DAY,WEEK",slahead.RespUnit[li-level]) THEN
        DO:
            ASSIGN 
                li-counter = slahead.RespTime[li-level].
            IF slahead.RespUnit[li-level] = "WEEK"
                THEN ASSIGN li-counter = li-counter * 7.
            DO li-loop = 1 TO li-counter:
                DO WHILE TRUE:
                    ASSIGN 
                        ld-day-count = ld-day-count + 1.
                    IF ll-work-day[WEEKDAY(ld-day-count)] THEN LEAVE.
                END.
            END.
        END.
        ELSE 
            IF slahead.RespUnit[li-level] = "HOUR" THEN
            DO:

            END.
            ELSE
                IF slahead.RespUnit[li-level] = "MINUTE" THEN
                DO:

                END.

        ASSIGN 
            tb.Sdate = ld-day-count
            tb.STime = li-min-count * 60.

    END.
    
END.



/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-fnConvertHourMin) = 0 &THEN

FUNCTION fnConvertHourMin RETURNS INTEGER
    ( pi-Hours    AS INTEGER,
    pi-Mins     AS INTEGER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN ( ( pi-hours * 60 ) * 60 ) +
        ( pi-mins * 60 ).
  
END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-fnInitialise) = 0 &THEN

FUNCTION fnInitialise RETURNS LOGICAL
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    EMPTY TEMP-TABLE tt-sla-sched.

    ASSIGN
        ll-work-day = TRUE.

    
    IF slahead.incSat = FALSE
        THEN ASSIGN ll-work-day[7] = FALSE.
    IF slahead.incSun = FALSE
        THEN ASSIGN ll-work-day[1] = FALSE.

    
    ASSIGN 
        li-sla-begin = DYNAMIC-FUNCTION('fnConvertHourMin':U,
                                        company.SLABeginHour,
                                        company.SLABeginMin)
        li-sla-end   = DYNAMIC-FUNCTION('fnConvertHourMin':U,
                                        company.SLAEndHour,
                                        company.SLAEndMin)
        ll-office    = slahead.TimeBase = "OFF".



    RETURN TRUE.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-fnSeconds) = 0 &THEN

FUNCTION fnSeconds RETURNS INTEGER
    ( pc-Unit AS CHARACTER,
    pi-Unit AS INTEGER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    CASE pc-Unit:
        WHEN "MINUTE" THEN 
            RETURN pi-unit * 60.
        WHEN "HOUR"   THEN 
            RETURN pi-unit * ( fnSeconds("MINUTE",1) * 60 ).
        WHEN "DAY"    THEN 
            RETURN pi-unit * ( fnSeconds("HOUR",1) * 24).
        WHEN "WEEK"   THEN 
            RETURN pi-unit * ( fnSeconds("DAY",1) * 7 ).
        OTHERWISE
        DO:
            RETURN 1.
        END.
           
    END CASE.
  

END FUNCTION.


&ENDIF

