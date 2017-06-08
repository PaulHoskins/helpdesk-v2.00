/***********************************************************************

    Program:        rep/issueexportbuild.p
    
    Purpose:        Issue Export - Build Data       
    
    Notes:
    
    
    When        Who         What
    08/06/2017  phoski      Initial  
    
    
***********************************************************************/

{rep/issueexporttt.i}


DEFINE INPUT PARAMETER pc-companycode          AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-loginid              AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-FromAccountNumber    AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-ToAccountNumber      AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pl-allcust              AS LOG               NO-UNDO.

DEFINE INPUT PARAMETER pd-FromDate             AS DATE              NO-UNDO.
DEFINE INPUT PARAMETER pd-ToDate               AS DATE              NO-UNDO.
DEFINE INPUT PARAMETER pc-ClassList            AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-st-num               AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-dtype                AS CHARACTER         NO-UNDO.

DEFINE OUTPUT PARAMETER table              FOR tt-ilog.

{lib/common.i}
{iss/issue.i}


RUN ip-BuildData.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-BuildData) = 0 &THEN

PROCEDURE ip-BuildData :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE BUFFER issue       FOR issue.
    DEFINE BUFFER IssStatus   FOR IssStatus.
    DEFINE BUFFER IssActivity FOR IssActivity.
    DEFINE BUFFER issnote     FOR issnote.
    DEFINE BUFFER customer    FOR Customer.
    

    
    DEFINE VARIABLE li-seconds AS INTEGER  NO-UNDO.
    DEFINE VARIABLE li-min     AS INTEGER  NO-UNDO.
    DEFINE VARIABLE li-hr      AS INTEGER  NO-UNDO.
    DEFINE VARIABLE li-work    AS INTEGER  NO-UNDO.
    DEFINE VARIABLE ldt-Comp   AS DATETIME NO-UNDO.
    
    DEFINE VARIABLE ldt-st     AS DATETIME NO-UNDO.
    DEFINE VARIABLE ldt-en     AS DATETIME NO-UNDO.
    DEFINE VARIABLE ldt-day    AS DATETIME NO-UNDO.
    
    

    

    /*
    ***
    *** All issues created before the hi date
    ***
    */    
    FOR EACH issue NO-LOCK
        WHERE issue.CompanyCode = pc-companyCode
        AND issue.AccountNumber >= pc-FromAccountNumber
        AND issue.AccountNumber <= pc-ToAccountNumber
           
        AND CAN-DO(pc-classList,issue.iClass)
        ,
        EACH IssActivity OF Issue NO-LOCK
        BY issActivity.StartDate
        BY issActivity.StartTime
        :

        IF pc-dType  = "ISS"
            OR pc-dType = "ISSACT" THEN
        DO:
            IF  issue.IssueDate < pd-fromDate
                OR  issue.IssueDate > pd-ToDate THEN NEXT.

        END.
        
        IF pc-dType = "ACT"
            OR pc-dType = "ISSACT" THEN
        DO:
            IF issActivity.StartDate < pd-fromDate
                OR issActivity.StartDate > pd-ToDate THEN NEXT.
                           
        END.
            
        
        FIND customer OF Issue NO-LOCK NO-ERROR.
        IF NOT AVAILABLE Customer THEN NEXT.
        
        IF pl-allcust = NO
            AND Customer.IsActive = NO THEN NEXT.
        
        IF pc-st-num <> "ALL" THEN
        DO:
            IF Customer.st-num <> integer(pc-st-num) THEN NEXT.
        END. 
        
                        
        CREATE tt-ilog.
        BUFFER-COPY issue TO tt-ilog.

        FIND WebIssArea OF Issue NO-LOCK NO-ERROR.
        FIND WebStatus OF Issue NO-LOCK NO-ERROR.
        
        ASSIGN
            tt-ilog.iLongDesc = TRIM(
                        substr(REPLACE(Issue.LongDescription,"~n"," "),1,50)
                                    )
            tt-ilog.cStatus   = IF AVAILABLE WebStatus THEN WebStatus.Description ELSE ""
            tt-ilog.cArea     = IF AVAILABLE WebIssArea THEN WebIssArea.Description ELSE "".
        
        ASSIGN
            tt-ilog.iBillable    = Issue.Billable
            tt-ilog.ContractType = DYNAMIC-FUNCTION("com-ContractDescription",issue.CompanyCode,issue.ContractType).
      
      
        ASSIGN 
            tt-ilog.iType = com-DecodeLookup(Issue.iClass,lc-global-iclass-code,lc-global-iclass-desc).


        ASSIGN
            tt-ilog.isClosed = NOT DYNAMIC-FUNCTION("islib-IssueIsOpen",ROWID(Issue)).

        
        
        IF tt-ilog.SLALevel = ?
            THEN tt-ilog.SLALevel = 0.

        ASSIGN 
            tt-ilog.SLAAchieved = TRUE.


        IF tt-ilog.isClosed THEN
        DO: 
            FIND FIRST IssStatus OF Issue NO-LOCK NO-ERROR.

            IF AVAILABLE issStatus THEN
            DO:
                ASSIGN 
                    tt-ilog.Compdate = issStatus.ChangeDate
                    tt-ilog.CompTime = issStatus.ChangeTime
                    tt-ilog.ClosedBy = DYNAMIC-FUNCTION("com-UserName",issStatus.loginID).
            END.

            FIND FIRST issnote OF issue 
                WHERE issnote.notecode =  'SYS.MISC'
                USE-INDEX IssueNumber
                NO-LOCK NO-ERROR.
            IF AVAILABLE IssNote
                THEN ASSIGN tt-ilog.SLAComment = issnote.CONTENTS.     
                
            IF issue.slaTrip <> ? THEN
            DO:
                ldt-comp = ?.
                IF tt-ilog.Compdate <> ? THEN
                DO:
                    ldt-Comp = DATETIME(
                        STRING(tt-ilog.CompDate,"99/99/9999") + " " + 
                        STRING(tt-ilog.CompTime,"hh:mm")
                        ).
                    ASSIGN
                        tt-ilog.SLAAchieved = ldt-Comp <= issue.SLATrip.


                END.
                
            END.
        END.
        
        FIND slahead WHERE slahead.SLAID = Issue.link-SLAID NO-LOCK NO-ERROR.
        IF AVAILABLE slahead THEN
        DO: 
            
            tt-ilog.SLADesc = slahead.SLACode + "/" + string(tt-ilog.SLALevel).
        END.
        ELSE tt-ilog.SLADesc = "".
        

        ASSIGN 
            tt-ilog.cAssignTo     = DYNAMIC-FUNCTION("com-UserName",Issue.AssignTo)
            tt-ilog.RaisedLoginID = DYNAMIC-FUNCTION("com-UserName",tt-ilog.RaisedLoginID).
        

        FIND IssAction OF issActivity NO-LOCK NO-ERROR.
         
        IF AVAILABLE IssAction THEN
        DO: 
            FIND WebAction OF IssAction NO-LOCK NO-ERROR.
            ASSIGN
             tt-ilog.cActionAssignTo  = DYNAMIC-FUNCTION("com-UserName",IssAction.AssignTo)
             tt-ilog.cActionType    = IF AVAILABLE WebAction THEN WebAction.Description ELSE ""
             tt-ilog.actionDate     = IssAction.actionDate
             tt-ilog.actionStatus  =  IssAction.actionStatus
             tt-ilog.ActionCustomerView = IssAction.CustomerView
             tt-ilog.ActionNote    =  TRIM(
                        substr(REPLACE(IssAction.Notes,"~n"," "),1,50)
                                    ).
             
        END.  
        

                
        ASSIGN
            tt-ilog.actDesc = TRIM(
                        substr(REPLACE(IssActivity.Description,"~n"," "),1,50)
                                    )
            tt-ilog.ActivityType = issActivity.ActivityType
            tt-ilog.siteVisit = issActivity.SiteVisit
            tt-ilog.actDate = issActivity.actDate
            tt-ilog.StartDate = issActivity.StartDate
            tt-ilog.duration = com-TimeToString(IssActivity.Duration)
            tt-ilog.iduration = IssActivity.Duration
            tt-ilog.ActBillable = issActivity.Billable
            tt-ilog.ActivityBy   = DYNAMIC-FUNCTION("com-UserName",IssActivity.ActivityBy).
            
         FIND webActType 
            WHERE WebActType.CompanyCode = issActivity.companyCode
            AND WebActType.ActivityType = issActivity.ActivityType
            NO-LOCK NO-ERROR.
         
         IF AVAILABLE WebActType THEN
         DO:
             ASSIGN
                tt-ilog.isAdmin = WebActType.isAdminTime
                tt-ilog.ActTypeDesc = WebActType.Description.
         END.
    /*
    ***
    *** Time spent 
    ***
    */
    /** PH
    ASSIGN 
        li-seconds = 0.

    FOR EACH IssActivity OF Issue NO-LOCK
        BY issActivity.StartDate
        BY issActivity.StartTime:

        IF pc-dType = "ACT"
            OR pc-dType = "ISSACT" THEN
        DO:
            IF issActivity.StartDate < pd-fromDate
                OR issActivity.StartDate > pd-ToDate THEN NEXT.
                           
        END.
        IF tt-ilog.fActDate = ?
            THEN ASSIGN tt-ilog.fActDate = issActivity.StartDate
                tt-ilog.fActTime = issActivity.StartTime.  

        ASSIGN 
            li-seconds = li-seconds + IssActivity.Duration.

    END.
    IF pc-dType = "ACT" AND tt-ilog.fActDate = ? THEN
    DO:
        DELETE tt-iLog.
        NEXT.
    END.

    li-work = li-seconds.
    ASSIGN
        tt-ilog.iActDuration = li-Seconds.

    IF li-seconds > 0 THEN
    DO:
        li-seconds = ROUND(li-seconds / 60,0).

        li-min = li-seconds MOD 60.

        IF li-seconds - li-min >= 60 THEN
            ASSIGN
                li-hr = ROUND( (li-seconds - li-min) / 60 , 0 ).
        ELSE li-hr = 0.

        ASSIGN
            tt-ilog.ActDuration = STRING(li-hr) + ":" + STRING(li-min,'99')
            .

    END.
        
    **/
        
        
    END.

  
END PROCEDURE.


&ENDIF

