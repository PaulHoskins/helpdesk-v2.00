/***********************************************************************

    Program:        rep/engrep01-build.p
    
    Purpose:        Enginner Time Report - Build Data
    
    Notes:
    
    
    When        Who         What
    10/11/2010  DJS         Initial
    14/06/2014  phoski      fix customer read
    21/11/2014  phoski      re-write all code
    17/03/2015  phoski      fix problem with totals
    23/10/2015  phoski      Date Range instead of DJS drivel and
                            removed all period week/month stuff
    02/07/2016  phoski      Exclude Admin
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */


{lib/common.i}
{lib/constants.i}
{rep/engrep01-build.i}


DEFINE INPUT PARAMETER pc-CompanyCode       AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER pd-FromDate          AS DATE         NO-UNDO.
DEFINE INPUT PARAMETER pd-toDate            AS DATE         NO-UNDO.

/* 1=Detailed , 2=SummaryDetail, 3=Summary */ 
DEFINE INPUT PARAMETER pc-ViewType          AS CHARACTER    NO-UNDO.
/* 1=Customer, 2=Engineer, 3=Issues */  

DEFINE INPUT PARAMETER pc-ReportType        AS CHARACTER    NO-UNDO.

DEFINE INPUT PARAMETER pc-Engineers         AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER pc-Customers         AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER pl-ExcludeAdmin      AS LOGICAL      NO-UNDO.

DEFINE OUTPUT PARAMETER TABLE FOR tt-IssRep.
DEFINE OUTPUT PARAMETER TABLE FOR tt-IssTime.
DEFINE OUTPUT PARAMETER TABLE FOR tt-IssTotal.
DEFINE OUTPUT PARAMETER TABLE FOR tt-IssUser.
DEFINE OUTPUT PARAMETER TABLE FOR tt-IssCust.
DEFINE OUTPUT PARAMETER TABLE FOR tt-IssTable.
DEFINE OUTPUT PARAMETER TABLE FOR tt-ThisPeriod.


DEFINE BUFFER b-issue     FOR issue.
DEFINE BUFFER issue       FOR issue.
DEFINE BUFFER issAction   FOR issAction.
DEFINE BUFFER IssActivity FOR IssActivity.
DEFINE BUFFER webuser     FOR WebUser.
DEFINE BUFFER ro-user     FOR WebUser.


DEFINE VARIABLE li-tot-billable            AS INTEGER NO-UNDO.
DEFINE VARIABLE li-tot-nonbillable         AS INTEGER NO-UNDO.
DEFINE VARIABLE li-tot-productivity        AS DECIMAL NO-UNDO.
DEFINE VARIABLE li-tot-period-billable     AS INTEGER NO-UNDO.
DEFINE VARIABLE li-tot-period-nonbillable  AS INTEGER NO-UNDO.
DEFINE VARIABLE li-tot-period-productivity AS DECIMAL NO-UNDO.

DEFINE BUFFER b-tt-IssRep   FOR tt-IssRep.
DEFINE BUFFER b-tt-IssTime  FOR tt-IssTime.
DEFINE BUFFER b-tt-IssTotal FOR tt-IssTotal.
DEFINE BUFFER b-tt-IssUser  FOR tt-IssUser.
DEFINE BUFFER b-tt-IssCust  FOR tt-IssCust.


DEFINE VARIABLE vx                 AS INTEGER    NO-UNDO.
DEFINE VARIABLE vc                 AS CHARACTER  NO-UNDO.   
                           

DEFINE VARIABLE viewType           AS INTEGER    NO-UNDO.
DEFINE VARIABLE reportType         AS INTEGER    NO-UNDO.

DEFINE VARIABLE ld-curr-hours      AS DECIMAL    FORMAT "9999.99" EXTENT 7 NO-UNDO.
DEFINE VARIABLE lc-day             AS CHARACTER  INITIAL "Mon,Tue,Wed,Thu,Fri,Sat,Sun" NO-UNDO.


DEFINE VARIABLE pi-array           AS INTEGER    EXTENT 2 NO-UNDO.




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


&IF DEFINED(EXCLUDE-getDate) = 0 &THEN

FUNCTION getDate RETURNS CHARACTER
    (INPUT dMyDate AS DATE)  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-Mth2Date) = 0 &THEN

FUNCTION Mth2Date RETURNS CHARACTER
    (cMthYrNo AS CHARACTER) FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-percentage-calc) = 0 &THEN

FUNCTION percentage-calc RETURNS DECIMAL
    ( p-one AS DECIMAL,
    p-two AS DECIMAL )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-safe-Chars) = 0 &THEN

FUNCTION safe-Chars RETURNS CHARACTER
    (  char_in AS CHARACTER )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-ThisDate) = 0 &THEN

FUNCTION ThisDate RETURNS CHARACTER
    (INPUT thisday AS DATE)  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-Wk2Date) = 0 &THEN

FUNCTION Wk2Date RETURNS CHARACTER
    (cWkYrNo AS CHARACTER) FORWARD.


&ENDIF


/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 9.23
         WIDTH              = 34.57.
/* END WINDOW DEFINITION */
                                                                        */

/* ************************* Included-Libraries *********************** */



 




/* ************************  Main Code Block  *********************** */



/* Process the latest Web event. */
RUN ipBuildData NO-ERROR.

/**
OUTPUT TO c:\temp\report.txt PAGED.

FOR EACH tt-isscust NO-LOCK WITH DOWN STREAM-IO:
    
    DISPLAY tt-isscust.AccountNumber
            tt-isscust.period-of 
            tt-isscust.billable ( TOTAL )
            tt-isscust.nonbillable ( TOTAL )
            tt-isscust.billable + tt-isscust.nonbillable (total)
            .
    
    
END.


FOR EACH tt-issrep NO-LOCK WITH DOWN STREAM-IO:
    
    DISPLAY tt-issrep.period-of tt-IssRep.Duration (total).
END.

FOR EACH tt-isstime NO-LOCK WITH DOWN STREAM-IO:
 DISPLAY tt-isstime.AccountNumber
            tt-isstime.period-of 
            tt-isstime.billable ( TOTAL )
            tt-isstime.nonbillable ( TOTAL )
            tt-isstime.billable + tt-isstime.nonbillable (total)
            .
                
END.
    
OUTPUT CLOSE.
**/

    


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-Build-Year) = 0 &THEN

PROCEDURE Build-Year :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER lc-loginid            AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER lc-period             AS CHARACTER NO-UNDO.

    DEFINE VARIABLE vx                AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vz                AS INTEGER   NO-UNDO.
    DEFINE VARIABLE zx                AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-date           AS CHARACTER NO-UNDO.
    DEFINE VARIABLE hi-pc-date        AS DATE      NO-UNDO.
    DEFINE VARIABLE lo-pc-date        AS DATE      NO-UNDO.
    DEFINE VARIABLE std-hours         AS DECIMAL   FORMAT "99.99" NO-UNDO.
    DEFINE VARIABLE tmp-hours         AS DECIMAL   FORMAT "99.99" NO-UNDO.
    DEFINE VARIABLE lc-list-reason-id AS CHARACTER INITIAL "|01|02|03|04|05|10" NO-UNDO.
    DEFINE VARIABLE lc-list-reason    AS CHARACTER INITIAL "Select|BANK|LEAVE|SICK|DOC|DENT|OT" NO-UNDO.
    DEFINE VARIABLE lc-beg-wk         AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-end-wk         AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-tot-wk         AS INTEGER   NO-UNDO.

    EMPTY TEMP-TABLE tt-ThisPeriod.

    FOR EACH WebStdTime WHERE WebStdTime.CompanyCode = pc-CompanyCode                      
        AND   WebStdTime.LoginID     = lc-loginid                             
        AND   WebStdTime.StdWkYear   = integer(lc-period)
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

    DO vx = /*INTEGER(ENTRY(1,lc-period-array,",")) TO INTEGER(ENTRY(NUM-ENTRIES(lc-period-array,","),lc-period-array,",")) */
        1 TO 1:
        ASSIGN 
            lc-date    = ""
            hi-pc-date = pd-ToDate
            lo-pc-date = pd-FromDate
            lc-beg-wk  = 0
            lc-end-wk  = 0
            lc-tot-wk  = 0
            tmp-hours  = 0.
        /*
                IF periodType = 2 THEN /* Month */ 
                DO:
                    ASSIGN 
                        lc-date    = Mth2Date(STRING(STRING(vx,"99") + "-" + lc-period))
                        hi-pc-date = DATE(ENTRY(1,lc-date,"|"))
                        lo-pc-date = DATE(ENTRY(2,lc-date,"|"))
        
                        lc-end-wk  = INTEGER(ENTRY(1,ENTRY(2,lc-date,"|"),"/"))
                        zx         = dayOfWeek(hi-pc-date)  /* if lc-beg-wk = 1 then 7 else lc-beg-wk - 1 */
                        .
                    DO vz = 1 TO lc-end-wk:
                        tmp-hours = tmp-hours + ld-curr-hours[zx].
                        IF zx >= 7 THEN zx = 0.
                        zx = zx + 1.
                    END.
                END.
                ELSE
                    ASSIGN lc-date    = Wk2Date(STRING(STRING(vx,"99") + "-" + lc-period))
                        hi-pc-date = DATE(ENTRY(1,lc-date,"|"))
                        lo-pc-date = DATE(ENTRY(2,lc-date,"|"))
                        tmp-hours  = std-hours.
        */
        tmp-hours = std-hours.
        
        CREATE tt-ThisPeriod.
        ASSIGN 
            td-id     = lc-loginid
            td-period = vx
            td-hours  = tmp-hours.
       
        FOR EACH WebUserTime WHERE WebUserTime.CompanyCode = pc-CompanyCode                      
            AND   WebUserTime.LoginID     = lc-loginid                             
            AND   WebUserTime.EventDate   >= hi-pc-date
            AND   WebUserTime.EventDate   <= lo-pc-date
            NO-LOCK:
            CASE WebUserTime.EventType :
                WHEN "BANK"  THEN 
                    td-hours = td-hours - WebUserTime.EventHours.
                WHEN "LEAVE" THEN 
                    td-hours = td-hours - WebUserTime.EventHours.
                WHEN "SICK"  THEN 
                    td-hours = td-hours - WebUserTime.EventHours.
                WHEN "DOC"   THEN 
                    td-hours = td-hours - WebUserTime.EventHours.
                WHEN "DENT"  THEN 
                    td-hours = td-hours - WebUserTime.EventHours.
                WHEN "OT"    THEN 
                    td-hours = td-hours + WebUserTime.EventHours.
            END CASE.
  
       
        END.
    END.
     
END PROCEDURE.


&ENDIF







&IF DEFINED(EXCLUDE-ipBuildData) = 0 &THEN

PROCEDURE ipBuildData:
    /*------------------------------------------------------------------------------
      Purpose:     Process the web request.
      Parameters:  <none>
      emails:       
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE vc       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vx       AS INTEGER   NO-UNDO.
    DEFINE VARIABLE typedesc AS CHARACTER INITIAL "Detail,Summary_Detail,Summary" NO-UNDO. 
    DEFINE VARIABLE engcust  AS CHARACTER INITIAL "Customer,Engineer,Issues" NO-UNDO.
   
    ASSIGN
        viewType             = INTEGER(pc-ViewType)         /* pc-ViewType    1=Detailed , 2=SummaryDetail, 3=Summary */   
        reportType           = INTEGER(pc-ReportType)       /* pc-ReportType  1=Customer, 2=Engineer, 3=Issues */            
        pc-ViewType   = ENTRY(viewType,typedesc)  /* set these to descriptions  */ 
        pc-ReportType = ENTRY(reportType,engcust) /* set these to descriptions  */
        .
    
    IF reportType = 1 THEN
    DO:
        FOR EACH IssActivity NO-LOCK
            WHERE IssActivity.companycode = pc-CompanyCode
            AND   IssActivity.StartDate >= pd-FromDate
            AND   IssActivity.StartDate <= pd-toDate,
            FIRST ro-user NO-LOCK
            WHERE ro-user.companycode = pc-CompanyCode
            AND ro-user.LoginID = IssActivity.ActivityBy 
            AND ro-user.UserClass = "internal"
            :
            INNER: 
            DO:
                IF pl-ExcludeAdmin 
                AND com-IsActivityChargeable(issActivity.IssActivityID) = FALSE THEN NEXT.
                
                FIND FIRST issAction OF issActivity NO-LOCK NO-ERROR.
                IF NOT AVAILABLE issAction THEN NEXT.

                FIND Issue NO-LOCK
                    WHERE issue.companycode = pc-CompanyCode
                    AND   Issue.IssueNumber = issAction.IssueNumber
                    AND   IF pc-Customers = "ALL" THEN TRUE  ELSE LOOKUP(Issue.AccountNumber,pc-Customers,",") > 0
                    NO-ERROR.
                IF NOT AVAILABLE Issue THEN LEAVE INNER.
                RUN ReportA(reportType) .
      
            END.
        END.
        RUN ReportC .
 
    END.
    ELSE IF reportType = 2 THEN
        DO:
            FOR EACH webuser NO-LOCK
                WHERE webuser.companycode = pc-CompanyCode
                AND   webuser.UserClass = "internal"
                AND IF pc-Engineers = "ALL" THEN TRUE ELSE  LOOKUP(webuser.loginid,pc-Engineers,",") > 0
                :
                FOR EACH IssActivity NO-LOCK
                    WHERE IssActivity.CompanyCode = webuser.CompanyCode
                    AND IssActivity.ActivityBy  = webuser.loginid
                    AND IssActivity.StartDate >= pd-FromDate
                    AND IssActivity.StartDate <= pd-toDate
                    :
                    IF pl-ExcludeAdmin 
                    AND com-IsActivityChargeable(issActivity.IssActivityID) = FALSE THEN NEXT.
                
                    FIND FIRST issAction OF issActivity NO-LOCK NO-ERROR.
                    IF NOT AVAILABLE issAction THEN NEXT.

                    FIND FIRST issue NO-LOCK WHERE issue.CompanyCode = webuser.CompanyCode
                        AND issue.IssueNumber = IssActivity.IssueNumber NO-ERROR.
                    RUN ReportA(reportType).
                END.             
            END.               
            RUN ReportB.
     
        END.
        ELSE  
        DO:
            FOR EACH IssActivity NO-LOCK
                WHERE IssActivity.CompanyCode = pc-CompanyCode
                AND IssActivity.StartDate >= pd-FromDate
                AND IssActivity.StartDate <= pd-ToDate,
                FIRST ro-user NO-LOCK
                WHERE ro-user.companycode = pc-CompanyCode
                AND ro-user.LoginID = IssActivity.ActivityBy 
                AND ro-user.UserClass = "internal"
              
                :
                    
                IF pl-ExcludeAdmin 
                AND com-IsActivityChargeable(issActivity.IssActivityID) = FALSE THEN NEXT.
                

                FIND FIRST issAction OF issActivity NO-LOCK NO-ERROR.
                IF NOT AVAILABLE issAction THEN NEXT.

                FIND FIRST issue NO-LOCK WHERE issue.CompanyCode = pc-CompanyCode
                    AND issue.IssueNumber = IssActivity.IssueNumber NO-ERROR.
                RUN ReportA(reportType).
            END.             
            RUN ReportB.              
        
        END.

  
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ReportA) = 0 &THEN

PROCEDURE ReportA :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER reportType  AS INTEGER  NO-UNDO.

    DEFINE VARIABLE pi-period-of           AS INTEGER NO-UNDO.
    DEFINE VARIABLE pi-period-billable     AS INTEGER NO-UNDO. 
    DEFINE VARIABLE pi-period-nonbillable  AS INTEGER NO-UNDO.
    DEFINE VARIABLE pi-period-productivity AS DECIMAL NO-UNDO.
    DEFINE VARIABLE pi-period-num-issues   AS INTEGER NO-UNDO.

    FIND FIRST ContractType 
        WHERE ContractType.CompanyCode  = Issue.CompanyCode
        AND ContractType.ContractNumber = Issue.ContractType NO-LOCK NO-ERROR.

    ASSIGN 
        pi-period-of = 1.


    FIND FIRST tt-IssRep 
        WHERE tt-IssRep.IssueNumber   = IssActivity.IssueNumber 
        AND   tt-IssRep.IssActionID   = IssActivity.IssActionID
        AND   tt-IssRep.IssActivityID = IssActivity.IssActivityID
        AND   tt-IssRep.AccountNumber = Issue.AccountNumber 
        AND   tt-IssRep.period-of     = pi-period-of NO-LOCK NO-ERROR.
    IF NOT AVAILABLE tt-IssRep THEN
    DO:
        CREATE tt-IssRep.
        BUFFER-COPY issActivity TO tt-IssRep.
    END.
    ASSIGN 
        tt-IssRep.AccountNumber = issue.AccountNumber
        tt-IssRep.ActionDesc    = /*issAction.Notes */ ""
        tt-IssRep.ActivityType  = IssActivity.ActDescription
        tt-IssRep.ContractType  = IF AVAILABLE ContractType THEN ContractType.Description ELSE "Ad Hoc" 
        tt-IssRep.IssueDate     = issue.IssueDate
        tt-IssRep.period-of     = pi-period-of.
    /* TIME RECORDS */
    IF reportType = 1 THEN 
        FIND FIRST tt-isstime WHERE tt-IssTime.IssueNumber   = IssActivity.IssueNumber 
            AND   tt-IssTime.period-of     = pi-period-of  
            AND   tt-IssTime.AccountNumber = issue.AccountNumber 
            NO-ERROR.
    ELSE
        FIND FIRST tt-isstime WHERE tt-IssTime.IssueNumber   = IssActivity.IssueNumber 
            AND   tt-IssTime.period-of     = pi-period-of  
            AND   tt-IssTime.ActivityBy    = IssActivity.ActivityBy 
            NO-ERROR.
        
        
        
    IF NOT AVAILABLE tt-IssTime THEN
    DO: 
        CREATE tt-IssTime.                    
        ASSIGN 
            tt-IssTime.IssueNumber   = IssActivity.IssueNumber
            tt-IssTime.AccountNumber = issue.AccountNumber
            tt-IssTime.ActivityBy    = IssActivity.ActivityBy
            tt-IssTime.period-of     = pi-period-of
            tt-IssTime.billable      = IF IssActivity.Billable THEN IssActivity.Duration ELSE 0
            tt-IssTime.nonbillable   = IF NOT IssActivity.Billable THEN IssActivity.Duration ELSE 0.
    END.
    ELSE
        ASSIGN tt-IssTime.billable    = IF IssActivity.Billable THEN tt-IssTime.billable + IssActivity.Duration ELSE tt-IssTime.billable
            tt-IssTime.nonbillable = IF NOT IssActivity.Billable THEN tt-IssTime.nonbillable + IssActivity.Duration ELSE tt-IssTime.nonbillable.

    /* TOTAL RECORDS */
    ASSIGN 
        li-tot-billable    = IF IssActivity.Billable THEN li-tot-billable + IssActivity.Duration ELSE li-tot-billable              
        li-tot-nonbillable = IF NOT IssActivity.Billable THEN li-tot-nonbillable + IssActivity.Duration ELSE li-tot-nonbillable. 

    IF reportType = 1 THEN FIND FIRST tt-IssTotal WHERE tt-IssTotal.AccountNumber = issue.AccountNumber NO-ERROR.
    IF reportType = 2 THEN FIND FIRST tt-IssTotal WHERE tt-IssTotal.ActivityBy = IssActivity.ActivityBy NO-ERROR.
    IF NOT AVAILABLE tt-IssTotal THEN
    DO: 
        CREATE tt-IssTotal.                    
        ASSIGN 
            tt-IssTotal.AccountNumber = IF reportType = 1 THEN issue.AccountNumber ELSE ""
            tt-IssTotal.ActivityBy    = IF reportType = 2 THEN IssActivity.ActivityBy ELSE ""
            tt-IssTotal.billable      = IF IssActivity.Billable THEN IssActivity.Duration ELSE 0
            tt-IssTotal.nonbillable   = IF NOT IssActivity.Billable THEN IssActivity.Duration ELSE 0. 
    END.
    ELSE
        ASSIGN tt-IssTotal.billable    = IF IssActivity.Billable THEN tt-IssTotal.billable + IssActivity.Duration ELSE tt-IssTotal.billable
            tt-IssTotal.nonbillable = IF NOT IssActivity.Billable THEN tt-IssTotal.nonbillable + IssActivity.Duration ELSE tt-IssTotal.nonbillable.    

    /* USER RECORDS */
    FIND tt-IssUser WHERE tt-IssUser.ActivityBy = IssActivity.ActivityBy 
        AND   tt-IssUser.period-of  = pi-period-of NO-ERROR.
    IF NOT AVAILABLE tt-IssUser THEN 
    DO:
        CREATE tt-IssUser.
        ASSIGN 
            tt-IssUser.ActivityBy = IssActivity.ActivityBy
            tt-IssUser.period-of  = pi-period-of.
    END.
    ASSIGN 
        tt-IssUser.billable    = IF IssActivity.Billable THEN tt-IssUser.billable + IssActivity.Duration ELSE tt-IssUser.billable              
        tt-IssUser.nonbillable = IF NOT IssActivity.Billable THEN tt-IssUser.nonbillable + IssActivity.Duration ELSE tt-IssUser.nonbillable.
    /* CUSTOMER RECORDS */
    FIND tt-IssCust WHERE tt-IssCust.AccountNumber = issue.AccountNumber 
        AND   tt-IssCust.period-of     = pi-period-of NO-ERROR.
    IF NOT AVAILABLE tt-IssCust THEN 
    DO:
        CREATE tt-IssCust.
        ASSIGN 
            tt-IssCust.AccountNumber = issue.AccountNumber
            tt-IssCust.period-of     = pi-period-of.
    END.                                                 
    ASSIGN 
        tt-IssCust.billable    = IF IssActivity.Billable THEN tt-IssCust.billable + IssActivity.Duration ELSE tt-IssCust.billable              
        tt-IssCust.nonbillable = IF NOT IssActivity.Billable THEN tt-IssCust.nonbillable + IssActivity.Duration ELSE tt-IssCust.nonbillable.


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ReportB) = 0 &THEN

PROCEDURE ReportB :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/



    FOR EACH webuser NO-LOCK
        WHERE webuser.companycode = pc-CompanyCode
        AND WebUser.UserClass = "Internal"
        AND IF pc-Engineers = "ALL" THEN TRUE ELSE LOOKUP(webuser.loginid,pc-Engineers,",") > 0
        :
        li-tot-productivity = 0.
        RUN Build-Year( webuser.loginid ,
            STRING(YEAR(pd-fromDate))) NO-ERROR.
        FOR EACH tt-ThisPeriod:
            
            FIND tt-IssUser WHERE tt-IssUser.ActivityBy = webuser.loginid
                AND   tt-IssUser.period-of  = td-period
                NO-ERROR.
            IF AVAILABLE tt-IssUser 
                THEN ASSIGN tt-IssUser.productivity = td-hours
                    li-tot-productivity  = li-tot-productivity + td-hours. 
        END.
        FIND tt-IssTotal WHERE tt-IssTotal.ActivityBy = webuser.loginid NO-ERROR.
        IF AVAILABLE tt-IssTotal 
            THEN ASSIGN tt-IssTotal.productivity = li-tot-productivity.
    END.
 
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ReportC) = 0 &THEN

PROCEDURE ReportC :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE pi-num-issues AS INTEGER EXTENT 55 NO-UNDO.     
    DEFINE VARIABLE pi-period-of  AS INTEGER NO-UNDO.
  
    FOR EACH Customer NO-LOCK
        WHERE Customer.companycode = pc-CompanyCode
        AND  IF pc-Customers = "ALL" THEN TRUE ELSE  LOOKUP(Customer.AccountNumber,pc-Customers,",") > 0
        BREAK BY Customer.AccountNumber: 
    
        ASSIGN 
            pi-num-issues = 0.
    
        FOR EACH issue OF customer NO-LOCK 
            WHERE issue.IssueDate >= pd-fromDate
            AND   issue.IssueDate <= pd-Todate  
            BREAK BY issue.IssueNumber :
            pi-period-of = 1. 
            pi-num-issues[pi-period-of] = pi-num-issues[pi-period-of]  + 1.

        END.

        FOR EACH tt-IssCust WHERE tt-IssCust.AccountNumber = Customer.AccountNumber:
            ASSIGN 
                tt-IssCust.num-issues = pi-num-issues[tt-IssCust.period-of].
        END.

    END.

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
    /* returns DAY WEEK YEAR */
    DEFINE VARIABLE cYear    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iWkNo    AS INTEGER   NO-UNDO.
    DEFINE VARIABLE iDayNo   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE dYrBegin AS DATE      NO-UNDO.
    DEFINE VARIABLE WkOne    AS INTEGER   NO-UNDO.
    DEFINE VARIABLE WkSt     AS INTEGER   INITIAL 2 NO-UNDO. /* 1=Sun,2=Mon */
    DEFINE VARIABLE DayList  AS CHARACTER NO-UNDO.
    IF WkSt = 1 THEN DayList = "1,2,3,4,5,6,7".
    ELSE DayList = "7,1,2,3,4,5,6".
    ASSIGN 
        cYear = STRING(YEAR(dMyDate))
        WkOne = WEEKDAY(DATE("01/01/" + cYear))
        WkOne = INTEGER(ENTRY(WkOne,DayList)).
    IF WkOne < 5 
        OR WkOne = 1 THEN dYrBegin = DATE("01/01/" + cYear).
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


&IF DEFINED(EXCLUDE-getDate) = 0 &THEN

FUNCTION getDate RETURNS CHARACTER
    (INPUT dMyDate AS DATE) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    /* returns WEEK MONTH YEAR */
    DEFINE VARIABLE cMonth AS CHARACTER NO-UNDO.
    DEFINE VARIABLE rDate  AS CHARACTER NO-UNDO.
    cMonth = STRING(MONTH(dMyDate)).
    rDate = Date2WK(dMyDate).
    IF ENTRY(2,rDate,"|") = "0"  THEN rDate = Date2WK(dMyDate - 5).
    RETURN STRING(ENTRY(2,rDate,"|") + "|" + cMonth + "|" + string(YEAR(dMyDate))).

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-Mth2Date) = 0 &THEN

FUNCTION Mth2Date RETURNS CHARACTER
    (cMthYrNo AS CHARACTER):
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE iYear     AS INTEGER NO-UNDO FORMAT "9999".
    DEFINE VARIABLE iMthNo    AS INTEGER NO-UNDO.
    DEFINE VARIABLE iDate     AS DATE    NO-UNDO EXTENT 12 FORMAT "99/99/99".
    DEFINE VARIABLE iMonthNum AS INTEGER NO-UNDO. 
    IF INDEX(cMthYrNo,"-") <> 3 THEN RETURN "Format should be xx-xxxx".
    ASSIGN 
        iMonthNum = INTEGER(ENTRY(1,cMthYrNo,"-")).     /* set month */
    iYear     = INTEGER(ENTRY(2,cMthYrNo,"-")).         /* set year  */
    DO iMthNo = 2 TO 13:
        IF iMthNo <> 13 THEN iDate[iMthNo - 1] = DATE(iMthNo,1,iYear) - 1.
        ELSE iDate[12] = DATE(1,1,iYear + 1) - 1.
    END.
    RETURN STRING("01/" + string(iMonthNum) + "/" + string(iYear) + "|" + string(iDate[iMonthNum],"99/99/9999")).
END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-percentage-calc) = 0 &THEN

FUNCTION percentage-calc RETURNS DECIMAL
    ( p-one AS DECIMAL,
    p-two AS DECIMAL ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE p-result AS DECIMAL.
    /*  p-one =   billable/nonbillable total      */
    /*  p-two =   productivity / contarcted hours */
    p-result = ROUND(( p-one * 100) / p-two , 2).
    RETURN p-result.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-safe-Chars) = 0 &THEN

FUNCTION safe-Chars RETURNS CHARACTER
    (  char_in AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    IF TRIM(char_in) BEGINS "-" THEN
        ASSIGN char_in = REPLACE(char_in, "-":U, " ~ ":U)  .     /* minuss mess with cell entry */
    RETURN char_in. 

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-ThisDate) = 0 &THEN

FUNCTION ThisDate RETURNS CHARACTER
    (INPUT thisday AS DATE) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE td AS CHARACTER NO-UNDO.
    DEFINE VARIABLE dd AS CHARACTER NO-UNDO.
    DEFINE VARIABLE mm AS CHARACTER NO-UNDO.
    DEFINE VARIABLE yy AS CHARACTER NO-UNDO.
    DEFINE VARIABLE da AS CHARACTER NO-UNDO.
    ASSIGN  
        dd = STRING(DAY(thisday))
        mm = ENTRY(MONTH(thisday),"Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec",",")
        yy = STRING(YEAR(thisday))
        da = ENTRY(WEEKDAY(thisday),"Sun,Mon,Tue,Wed,Thu,Fri,Sat",",")
        td = da + " " + dd + " " + mm + " " + yy .

    RETURN td.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-Wk2Date) = 0 &THEN

FUNCTION Wk2Date RETURNS CHARACTER
    (cWkYrNo AS CHARACTER):
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

   
    DEFINE VARIABLE cYear     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iWkNo     AS INTEGER  NO-UNDO.
    DEFINE VARIABLE iDayNo    AS INTEGER  NO-UNDO.
    DEFINE VARIABLE iSDayNo   AS DATE NO-UNDO.
    DEFINE VARIABLE iEDayNo   AS DATE NO-UNDO.
    DEFINE VARIABLE dYrBegin  AS DATE NO-UNDO.
    DEFINE VARIABLE WkOne     AS INTEGER  NO-UNDO.
    DEFINE VARIABLE WkSt      AS INTEGER  INITIAL 2 NO-UNDO. /* 1=Sun,2=Mon */
    IF INDEX(cWkYrNo,"-") <> 3 THEN RETURN "Format should be xx-xxxx".
    ASSIGN 
        cYear  = ENTRY(2,cWkYrNo,"-")
        WkOne  = WEEKDAY(DATE("01/01/" + cYear)).
      
    IF WkOne <= 5 THEN dYrBegin = DATE("01/01/" + cYear).
    ELSE dYrBegin = DATE("01/01/" + cYear) + WkOne.
    MESSAGE "PAYLH  dYrBegin ="  dYrBegin " WkOne= " wkOne " cWkYrNo= " cWkYrNo.
    ASSIGN 
        iWkNo  = INTEGER(ENTRY(1,cWkYrNo,"-"))
        iDayNo = (iWkNo * 7) - 7
        iSDayNo = dYrBegin + iDayNo - WkOne + WkSt 
        iEDayNo = iSDayNo + 6 .
   
    
        
            
    RETURN STRING(STRING(iSDayNo,"99/99/9999") + "|" + string(iEDayNo,"99/99/9999")).

END FUNCTION.


&ENDIF

