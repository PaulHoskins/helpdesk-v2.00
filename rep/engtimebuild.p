/***********************************************************************

    Program:        rep/engtimebuild.p
    
    Purpose:        Enqineer Time Management - Build Data       
    
    Notes:
    
    
    When        Who         What
    04/12/2014  phoski      Initial  
    12/03/2016  phoski      Engineer in lookup list instead of range
    02/07/2016  phoski      Exclude Admin
   
***********************************************************************/

{rep/engtimett.i}



DEFINE INPUT PARAMETER pc-companycode       AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-loginid           AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pd-FromDate          AS DATE              NO-UNDO.
DEFINE INPUT PARAMETER pd-ToDate            AS DATE              NO-UNDO.
DEFINE INPUT PARAMETER pc-SelectEngineer    AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-engtype           AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pl-ExcludeAdmin      AS LOGICAL           NO-UNDO.


DEFINE OUTPUT PARAMETER table               FOR tt-engtime.



{lib/common.i}
{iss/issue.i}

RUN ip-BuildDefaultInfo.
RUN ip-BuildData.
RUN ip-CleanData.



    





/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-BuildData) = 0 &THEN

PROCEDURE ip-BuildData :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE BUFFER iact FOR issActivity.
    DEFINE BUFFER iss FOR Issue.
    DEFINE BUFFER WebUser FOR WebUser.
    
    FOR EACH iact NO-LOCK
        WHERE iact.companycode = pc-companyCode
        AND iact.startdate >= pd-FromDate
        AND iact.startDate <= pd-ToDate
        ,
        FIRST iss NO-LOCK
        WHERE iss.companycode = iact.companycode
        AND iss.IssueNumber = iact.IssueNumber
        
        :
        IF pl-ExcludeAdmin 
        AND com-IsActivityChargeable(iAct.IssActivityID) = FALSE THEN NEXT.
            
             
        FIND WebUser WHERE WebUser.LoginID = iact.activityBy NO-LOCK NO-ERROR.
        IF NOT AVAILABLE WebUser THEN NEXT.
        IF pc-SelectEngineer <> "ALL" THEN
        DO:
            IF LOOKUP(WebUser.LoginID,pc-SelectEngineer) = 0 THEN NEXT.
        END.
        IF pc-engType <> "" AND pc-engType <> WebUser.engType THEN NEXT.
        
        FIND FIRST tt-engtime 
            WHERE tt-engtime.loginid     = WebUser.LoginID
            AND tt-engtime.startdate     = iact.startdate    
            EXCLUSIVE-LOCK NO-ERROR.
          
        IF NOT AVAILABLE tt-engtime THEN
        DO:
                  
            CREATE tt-engtime.
            ASSIGN
                tt-engtime.loginid       = WebUser.LoginID
                tt-engtime.startdate     = iact.startdate.
                
        END.
            
        ASSIGN
            tt-engTime.billable      = tt-engTime.billable + IF iact.Billable THEN iact.Duration ELSE 0
            tt-engTime.nonbillable   = tt-engTime.nonbillable + IF NOT iact.Billable THEN iact.Duration ELSE 0.
            
    
                   
            
    END.
END PROCEDURE.


&ENDIF

PROCEDURE ip-BuildDefaultInfo:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    
    DEFINE BUFFER WebUser FOR WebUser.
    DEFINE BUFFER WebStdTime FOR WebStdTime.
    
    DEFINE VARIABLE li-loop     AS INTEGER  NO-UNDO.
    DEFINE VARIABLE li-day      AS INTEGER  NO-UNDO.
    
    DEFINE VARIABLE lf-hours    AS DECIMAL  NO-UNDO.
       
    
    FOR EACH WebUser NO-LOCK
        WHERE webuser.companyCode = pc-companyCode
        AND WebUser.UserClass = "INTERNAL"
        : 
        
              
        IF pc-SelectEngineer <> "ALL" THEN
        DO:
            IF LOOKUP(WebUser.LoginID,pc-SelectEngineer) = 0 THEN NEXT.
        END.
             
        IF pc-engType <> "" AND pc-engType <> WebUser.engType THEN NEXT.
        
        
        DO li-loop = 0 TO ( pd-toDate - pd-FromDate):
            CREATE tt-engtime.
            ASSIGN
                tt-engtime.loginid       = WebUser.LoginID
                tt-engtime.startdate     = pd-fromDate + li-loop.
                
            
        END.
        FOR EACH tt-engtime EXCLUSIVE-LOCK 
            WHERE tt-engtime.loginid = WebUser.LoginID :
    
            ASSIGN
                li-day = com-DayOfWeek(tt-engtime.startdate,2).
                           
            FIND WebStdTime
                WHERE WebStdTime.CompanyCode = WebUser.CompanyCode
                AND WebStdTime.LoginID = WebUser.LoginID
                AND WebStdTime.StdWkYear = year(tt-engtime.startdate)
                NO-LOCK NO-ERROR.
            IF AVAILABLE WebStdTime THEN
            DO:
                ASSIGN
                    lf-Hours = 
                    ((TRUNCATE(WebStdTime.StdAMEndTime[li-Day] / 100,0) + dec(WebStdTime.StdAMEndTime[li-Day] MODULO 100 / 60))          /* convert time to decimal  */ 
                    - (TRUNCATE(WebStdTime.StdAMStTime[li-Day] / 100,0) + dec(WebStdTime.StdAMStTime[li-Day] MODULO 100 / 60)))            /* convert time to decimal  */ 
                     + ((TRUNCATE(WebStdTime.StdPMEndTime[li-Day] / 100,0) + dec(WebStdTime.StdPMEndTime[li-Day] MODULO 100 / 60))          /* convert time to decimal  */                               
                      - (TRUNCATE(WebStdTime.StdPMStTime[li-Day] / 100,0) + dec(WebStdTime.StdPMStTime[li-Day] MODULO 100 / 60))) 
                    .     
                          
                ASSIGN
                    tt-engtime.StdMins = (lf-hours * 60) * 60.
                   
            END.
                  
            FIND FIRST WebUserTime 
                WHERE WebUserTime.CompanyCode = WebUser.CompanyCode                   
                AND WebUserTime.LoginID     = WebUser.LoginID                           
                AND WebUserTime.EventDate   = tt-engtime.startdate
                NO-LOCK NO-ERROR.
            IF AVAILABLE WebUserTime THEN
            DO:
                ASSIGN 
                    tt-engtime.AdjTime = (( WebUserTime.EventHours * 60) * 60 ) *
                                            IF  WebUserTime.EventType = "OT" THEN 1 ELSE -1
                    tt-engtime.AdjReason = WebUserTime.EventType.
                    
                CASE WebUserTime.EventType:
                    WHEN 'BANK' THEN 
                        tt-engtime.AdjReason = "Bank Holiday".
                    WHEN 'LEAVE' THEN 
                        tt-engtime.AdjReason = "A/Leave".
                    WHEN 'SICK' THEN 
                        tt-engtime.AdjReason = "Sickness".
                    WHEN 'DOC' THEN 
                        tt-engtime.AdjReason = "Doctor".
                    WHEN 'DENT' THEN 
                        tt-engtime.AdjReason = "Dentist".
                    WHEN 'OT' THEN 
                        tt-engtime.AdjReason = "Overtime".
                END CASE.    
            END.
            ELSE
            DO:
                FIND holiday 
                    WHERE holiday.companyCode = webuser.CompanyCode
                    AND holiday.hDate = tt-engtime.startdate
                    AND Holiday.observed = TRUE
                    NO-LOCK NO-ERROR.
                IF AVAILABLE Holiday
                    THEN ASSIGN
                        tt-engtime.AdjTime = tt-engtime.StdMins * -1
                        tt-engtime.AdjReason = Holiday.descr.     
            
            END.
                          
                       
            ASSIGN 
                tt-engtime.AvailTime = tt-engtime.StdMins + tt-engtime.AdjTime.
                                          
        END.
        
    END.
END PROCEDURE.

PROCEDURE ip-CleanData:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    FOR EACH tt-engtime EXCLUSIVE-LOCK:
    
        IF tt-engtime.StdMins = 0 
            AND tt-engtime.NonBillAble = 0
            AND tt-engtime.BillAble = 0 
            AND tt-engtime.AdjTime = 0 
            THEN DELETE tt-engtime.
        ELSE
            IF tt-engtime.StdMins = 0 
                AND tt-engtime.NonBillAble = 0
                AND tt-engtime.BillAble = 0 
                AND tt-engtime.AdjTime = tt-engtime.AvailTime
                THEN DELETE tt-engtime.
        
    END.
    

END PROCEDURE.
